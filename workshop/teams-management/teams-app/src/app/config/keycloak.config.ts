import { KeycloakConfig } from 'keycloak-js';

const keycloakConfig: KeycloakConfig = {
  url: 'http://platform-auth.127.0.0.1.sslip.io',
  realm: 'teams',
  clientId: 'teams-ui',
};

export default keycloakConfig;
