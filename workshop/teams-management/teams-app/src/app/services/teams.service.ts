import { Injectable } from '@angular/core';
import { HttpClient, HttpErrorResponse } from '@angular/common/http';
import { Observable, throwError } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { Team, TeamCreate } from '../models/team.model';
import { environment } from '../../environments/environment';
import { AuthService } from './auth.service';

@Injectable({
  providedIn: 'root'
})
export class TeamsService {
  private apiUrl = environment.apiUrl;

  constructor(
    private http: HttpClient,
    private authService: AuthService
  ) {}

  getTeams(): Observable<Team[]> {
    const url = `${this.apiUrl}/teams`;
    console.log('🔍 Making API call to:', url);
    console.log('🔐 User authenticated:', this.authService.isLoggedIn());
    
    return this.http.get<Team[]>(url)
      .pipe(catchError(this.handleError));
  }

  createTeam(team: TeamCreate): Observable<Team> {
    const url = `${this.apiUrl}/teams`;
    console.log('📝 Creating team via API:', url);
    
    return this.http.post<Team>(url, team)
      .pipe(catchError(this.handleError));
  }

  deleteTeam(teamId: string): Observable<any> {
    const url = `${this.apiUrl}/teams/${teamId}`;
    console.log('🗑️ Deleting team via API:', url);
    
    return this.http.delete(url)
      .pipe(catchError(this.handleError));
  }

  private handleError = (error: HttpErrorResponse) => {
    let errorMessage = 'An error occurred';
    
    console.error('API Error:', error);
    
    if (error.status === 401) {
      errorMessage = 'Unauthorized. Please log in again.';
      this.authService.login();
    } else if (error.status === 403) {
      errorMessage = 'Forbidden. You don\'t have permission for this action.';
    } else if (error.error instanceof ErrorEvent) {
      // Client-side error
      errorMessage = error.error.message;
    } else {
      // Server-side error
      errorMessage = error.error?.detail || error.message || `HTTP ${error.status}`;
    }
    
    return throwError(() => errorMessage);
  };
}
