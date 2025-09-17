// import { Component, OnInit } from '@angular/core';
// import { AuthService } from '../../services/auth.service';
// import { KeycloakProfile } from 'keycloak-js';
//
// @Component({
//   selector: 'app-header',
//   templateUrl: './header.component.html',
//   styleUrls: ['./header.component.css']
// })
// export class HeaderComponent implements OnInit {
//   userProfile: KeycloakProfile | null = null;
//   isLoggedIn = false;
//   userRoles: string[] = [];
//   isLoading = true;
//
//   constructor(public authService: AuthService) {}
//
//   async ngOnInit() {
//     try {
//       // Ensure auth state is refreshed
//       await this.authService.refreshAuthState();
//
//       this.isLoggedIn = this.authService.isLoggedInSync();
//
//       if (this.isLoggedIn) {
//         try {
//           this.userProfile = await this.authService.loadUserProfile();
//           this.userRoles = this.authService.getUserRoles();
//         } catch (error) {
//           console.error('Failed to load user profile', error);
//         }
//       }
//     } catch (error) {
//       console.error('Failed to initialize auth state', error);
//     } finally {
//       this.isLoading = false;
//     }
//   }
//
//   async login() {
//     try {
//       await this.authService.login();
//     } catch (error) {
//       console.error('Login failed', error);
//     }
//   }
//
//   async logout() {
//     try {
//       await this.authService.logout();
//       this.isLoggedIn = false;
//       this.userProfile = null;
//       this.userRoles = [];
//     } catch (error) {
//       console.error('Logout failed', error);
//     }
//   }
//
//   get canManageTeams(): boolean {
//     return this.authService.hasRole('team-leader') || this.authService.hasRole('admin');
//   }
// }
//

// src/app/components/header/header.component.ts
import { Component, OnInit } from "@angular/core";
import { AuthService } from "../../services/auth.service";
import { KeycloakProfile } from "keycloak-js";

@Component({
  selector: "app-header",
  templateUrl: "./header.component.html",
  styleUrls: ["./header.component.css"],
})
export class HeaderComponent implements OnInit {
  userProfile: KeycloakProfile | null = null;
  isLoggedIn = false;
  userRoles: string[] = [];
  isLoading = true;

  constructor(public authService: AuthService) {}

  async ngOnInit() {
    const tokenInfo = this.authService.getUserInfoFromToken();
    console.log(tokenInfo);

    try {
      // Ensure auth state is refreshed
      await this.authService.refreshAuthState();

      this.isLoggedIn = this.authService.isLoggedInSync();

      if (this.isLoggedIn) {
        try {
          // this.userProfile = await this.authService.loadUserProfile();
          // this.userRoles = this.authService.getUserRoles();
          this.userProfile = tokenInfo;
          this.userRoles = tokenInfo.roles;
        } catch (error) {
          console.error("Failed to load user profile", error);
        }
      }
    } catch (error) {
      console.error("Failed to initialize auth state", error);
    } finally {
      this.isLoading = false;
    }
  }

  async login() {
    try {
      await this.authService.login();
    } catch (error) {
      console.error("Login failed", error);
    }
  }

  async logout() {
    try {
      await this.authService.logout();
      this.isLoggedIn = false;
      this.userProfile = null;
      this.userRoles = [];
    } catch (error) {
      console.error("Logout failed", error);
    }
  }

  get canManageTeams(): boolean {
    return (
      this.authService.hasRole("team-leader") ||
      this.authService.hasRole("admin")
    );
  }
}
