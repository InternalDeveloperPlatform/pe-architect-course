export const environment = {
  production: false,
  // Use proxy path instead of direct URL or in coder use "http://<workspace-name>.coder:<port>" with the port of forward of the api service
  apiUrl: "http://teams-api.127.0.0.1.sslip.io",
  keycloak: {
    // same as above, but with keycloak forward port
    url: "http://platform-auth.127.0.0.1.sslip.io",
    realm: "teams",
    clientId: "teams-ui",
  },
};
