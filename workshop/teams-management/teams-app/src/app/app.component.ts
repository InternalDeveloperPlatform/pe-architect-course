import { Component, OnInit } from '@angular/core';
import { AuthService } from './services/auth.service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent implements OnInit {
  isLoggedIn = false;
  isLoading = true;

  constructor(public authService: AuthService) {}

  async ngOnInit() {
    try {
      // Ensure auth state is properly initialized
      await this.authService.refreshAuthState();
      this.isLoggedIn = this.authService.isLoggedInSync();
    } catch (error) {
      console.error('Failed to initialize app auth state', error);
      this.isLoggedIn = false;
    } finally {
      this.isLoading = false;
    }
  }

  async login() {
    try {
      await this.authService.login();
      this.isLoggedIn = true;
    } catch (error) {
      console.error('Login failed', error);
    }
  }
}

