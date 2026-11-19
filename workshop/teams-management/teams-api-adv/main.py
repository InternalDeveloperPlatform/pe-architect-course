from contextlib import asynccontextmanager
from datetime import datetime, timezone
import os
from typing import Iterator, List
from uuid import uuid4

from fastapi import Depends, FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, ConfigDict, Field
from sqlalchemy import DateTime, Index, String, URL, create_engine, func, select, text
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import DeclarativeBase, Mapped, Session, mapped_column, sessionmaker


database_url = URL.create(
    drivername="postgresql+psycopg",
    username=os.getenv("DB_USER", "teams_api_adv"),
    password=os.getenv("DB_PASSWORD", "teams-api-adv-demo-only"),
    host=os.getenv("DB_HOST", "localhost"),
    port=int(os.getenv("DB_PORT", "5432")),
    database=os.getenv("DB_NAME", "teams_api_adv"),
)
engine = create_engine(database_url, pool_pre_ping=True)
SessionLocal = sessionmaker(bind=engine, autoflush=False, expire_on_commit=False)


class Base(DeclarativeBase):
    pass


class TeamRecord(Base):
    __tablename__ = "teams"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid4()))
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc)
    )

    __table_args__ = (Index("uq_teams_name_lower", func.lower(name), unique=True),)


@asynccontextmanager
async def lifespan(_: FastAPI):
    # Serialize initial schema creation when multiple API replicas start together.
    with engine.begin() as connection:
        connection.execute(text("SELECT pg_advisory_xact_lock(742013915)"))
        Base.metadata.create_all(bind=connection)
    yield

app = FastAPI(
    title="Teams API",
    description="A simple API for team leads to create and manage teams",
    version="1.0.0",
    lifespan=lifespan,
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

class TeamCreate(BaseModel):
    name: str = Field(min_length=1, max_length=255)

class Team(BaseModel):
    id: str
    name: str
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


def get_db() -> Iterator[Session]:
    with SessionLocal() as session:
        yield session

@app.get("/")
async def root():
    return {"message": "Teams API is running"}

@app.post("/teams", response_model=Team)
def create_team(team: TeamCreate, session: Session = Depends(get_db)):
    """Create a new team"""
    record = TeamRecord(name=team.name)
    session.add(record)
    try:
        session.commit()
    except IntegrityError as error:
        session.rollback()
        raise HTTPException(status_code=400, detail="Team name already exists") from error
    session.refresh(record)
    return record

@app.get("/teams", response_model=List[Team])
def get_teams(session: Session = Depends(get_db)):
    """Get all teams"""
    return session.scalars(select(TeamRecord).order_by(TeamRecord.created_at)).all()

@app.get("/teams/{team_id}", response_model=Team)
def get_team(team_id: str, session: Session = Depends(get_db)):
    """Get a specific team by ID"""
    record = session.get(TeamRecord, team_id)
    if record is None:
        raise HTTPException(status_code=404, detail="Team not found")
    return record

@app.delete("/teams/{team_id}")
def delete_team(team_id: str, session: Session = Depends(get_db)):
    """Delete a team"""
    record = session.get(TeamRecord, team_id)
    if record is None:
        raise HTTPException(status_code=404, detail="Team not found")
    session.delete(record)
    session.commit()
    return {"message": f"Team '{record.name}' deleted successfully"}

@app.get("/health")
async def health_check():
    """Health check endpoint for Kubernetes"""
    return {"status": "healthy"}

@app.get("/ready")
def readiness_check(session: Session = Depends(get_db)):
    """Verify the API can reach its database."""
    teams_count = session.scalar(select(func.count()).select_from(TeamRecord))
    return {"status": "ready", "teams_count": teams_count}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
