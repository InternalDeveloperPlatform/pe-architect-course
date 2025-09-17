export const environment = {
  production: false,
  apiUrl: "http://teams-api.127.0.0.1.sslip.io", // Use proxy path instead of direct URL
  keycloak: {
    url: "http://platform-auth.127.0.0.1.sslip.io",
    realm: "teams",
    clientId: "teams-ui",
  },
};
