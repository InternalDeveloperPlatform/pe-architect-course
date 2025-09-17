// import { Injectable } from '@angular/core';
// import { KeycloakService } from 'keycloak-angular';
// import { KeycloakProfile } from 'keycloak-js';
//
// @Injectable({
//   providedIn: 'root'
// })
// export class AuthService {
//   private _isLoggedIn = false;
//   private _token = '';
//
//   constructor(private keycloak: KeycloakService) {
//     // Initialize the cached values
//     this.initializeAuth();
//   }
//
//   private async initializeAuth() {
//     try {
//       this._isLoggedIn = await this.keycloak.isLoggedIn();
//       if (this._isLoggedIn) {
//         this._token = await this.keycloak.getToken();
//       }
//     } catch (error) {
//       console.error('Failed to initialize auth state:', error);
//       this._isLoggedIn = false;
//       this._token = '';
//     }
//   }
//
//   public isLoggedInSync(): boolean {
//     return this._isLoggedIn;
//   }
//
//   public async isLoggedIn(): Promise<boolean> {
//     this._isLoggedIn = await this.keycloak.isLoggedIn();
//     return this._isLoggedIn;
//   }
//
//   public async loadUserProfile(): Promise<KeycloakProfile> {
//     return this.keycloak.loadUserProfile();
//   }
//
//   public async login(): Promise<void> {
//     await this.keycloak.login();
//     await this.initializeAuth(); // Refresh cached values after login
//   }
//
//   public async logout(): Promise<void> {
//     await this.keycloak.logout();
//     this._isLoggedIn = false;
//     this._token = '';
//   }
//
//   public getTokenSync(): string {
//     return this._token;
//   }
//
//   public async getToken(): Promise<string> {
//     this._token = await this.keycloak.getToken();
//     return this._token;
//   }
//
//   public hasRole(role: string): boolean {
//     try {
//       return this.keycloak.isUserInRole(role);
//     } catch {
//       return false;
//     }
//   }
//
//   public getUserRoles(): string[] {
//     try {
//       return this.keycloak.getUserRoles();
//     } catch {
//       return [];
//     }
//   }
//
//   // Helper method to refresh auth state
//   public async refreshAuthState(): Promise<void> {
//     await this.initializeAuth();
//   }
// }
//
// src/app/services/auth.service.ts (Enhanced with token refresh)
import { Injectable } from "@angular/core";
import { KeycloakService } from "keycloak-angular";
import { KeycloakProfile } from "keycloak-js";

@Injectable({
  providedIn: "root",
})
export class AuthService {
  private _isLoggedIn = false;
  private _token = "";

  constructor(private keycloak: KeycloakService) {
    this.initializeAuth();
  }

  private async initializeAuth() {
    try {
      this._isLoggedIn = await this.keycloak.isLoggedIn();
      if (this._isLoggedIn) {
        // Ensure token is fresh
        await this.refreshTokenIfNeeded();
        this._token = await this.keycloak.getToken();
      }
    } catch (error) {
      console.error("Failed to initialize auth state:", error);
      this._isLoggedIn = false;
      this._token = "";
    }
  }

  private async refreshTokenIfNeeded(): Promise<void> {
    try {
      // Check if token needs refresh (refresh if expires in next 30 seconds)
      const refreshed = await this.keycloak.updateToken(30);
      if (refreshed) {
        console.log("🔄 Token refreshed");
        this._token = await this.keycloak.getToken();
      } else {
        console.log("✅ Token is still valid");
      }
    } catch (error) {
      console.error("❌ Token refresh failed:", error);
      // Token refresh failed - user needs to login again
      this._isLoggedIn = false;
      this._token = "";
      throw error;
    }
  }

  public isLoggedInSync(): boolean {
    return this._isLoggedIn;
  }

  public async isLoggedIn(): Promise<boolean> {
    try {
      this._isLoggedIn = await this.keycloak.isLoggedIn();
      if (this._isLoggedIn) {
        await this.refreshTokenIfNeeded();
      }
      return this._isLoggedIn;
    } catch (error) {
      console.error("Error checking login status:", error);
      return false;
    }
  }

  public async loadUserProfile(): Promise<KeycloakProfile> {
    try {
      // Ensure we have a fresh token
      await this.refreshTokenIfNeeded();
      return await this.keycloak.loadUserProfile();
    } catch (error) {
      console.error("Failed to load user profile:", error);
      throw error;
    }
  }

  public async login(): Promise<void> {
    await this.keycloak.login();
    await this.initializeAuth();
  }

  public async logout(): Promise<void> {
    await this.keycloak.logout();
    this._isLoggedIn = false;
    this._token = "";
  }

  public getTokenSync(): string {
    return this._token;
  }

  public async getToken(): Promise<string> {
    try {
      await this.refreshTokenIfNeeded();
      this._token = await this.keycloak.getToken();
      return this._token;
    } catch (error) {
      console.error("Failed to get token:", error);
      return "";
    }
  }

  // ADD THIS METHOD to your src/app/services/auth.service.ts file
  public getUserInfoFromToken(): any {
    try {
      const token = this.getTokenSync();
      if (!token) {
        console.log("🔍 Debug - No token available");
        return null;
      }

      // Decode JWT payload
      const payload = JSON.parse(atob(token.split(".")[1]));
      console.log("🔍 Debug - Token payload:", payload);

      return {
        username: payload.preferred_username,
        email: payload.email,
        firstName: payload.given_name,
        lastName: payload.family_name,
        name: payload.name,
        roles: payload.realm_access?.roles || [],
      };
    } catch (error) {
      console.error("❌ Failed to decode token:", error);
      return null;
    }
  }

  public hasRole(role: string): boolean {
    try {
      return this.keycloak.isUserInRole(role);
    } catch {
      return false;
    }
  }

  public getUserRoles(): string[] {
    try {
      return this.keycloak.getUserRoles();
    } catch {
      return [];
    }
  }

  public async refreshAuthState(): Promise<void> {
    await this.initializeAuth();
  }

  // Debug method to check token validity
  public async debugTokenInfo(): Promise<any> {
    try {
      const token = await this.getToken();
      if (!token) {
        return { error: "No token available" };
      }

      // Decode JWT payload (just for debugging - don't do this in production)
      const payload = JSON.parse(atob(token.split(".")[1]));
      const now = Math.floor(Date.now() / 1000);

      return {
        hasToken: !!token,
        tokenLength: token.length,
        expires: new Date(payload.exp * 1000),
        expiresInSeconds: payload.exp - now,
        isExpired: payload.exp < now,
        audience: payload.aud,
        subject: payload.sub,
        roles: payload.realm_access?.roles || [],
      };
    } catch (error) {
      return { error: error };
    }
  }
}
