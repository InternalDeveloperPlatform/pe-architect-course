import { KeycloakConfig } from 'keycloak-js';

const keycloakConfig: KeycloakConfig = {
  url: 'http://localhost:8888',
  realm: 'teams',
  clientId: 'teams-ui',
};

export default keycloakConfig;
