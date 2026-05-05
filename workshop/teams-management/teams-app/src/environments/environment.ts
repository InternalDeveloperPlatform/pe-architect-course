export const environment = {
  production: false,
  // Use proxy path instead of direct URL or in coder use "http://<workspace-name>.coder:<port>" with the port of forward of the api service
  apiUrl: "http://localhost:3002",
  keycloak: {
    // same as above, but with keycloak forward port
    url: "http://localhost:3002",
    realm: "teams",
    clientId: "teams-ui",
  },
};
