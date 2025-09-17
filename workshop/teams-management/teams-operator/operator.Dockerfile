FROM python:3.11-slim

WORKDIR /app

# Create non-root user for security
RUN groupadd -r teamsop -g 1001 && \
    useradd -u 1001 -r -g teamsop -m -d /app -s /sbin/nologin -c "Teams operator user" teamsop

# Copy requirements first to leverage Docker cache
COPY operator-requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r operator-requirements.txt

# Copy operator code
COPY teams_operator.py .

# Change ownership to non-root user
RUN chown -R teamsop:teamsop /app

# Switch to non-root user
USER 1001

# Run the operator
CMD ["python", "teams_operator.py"]
