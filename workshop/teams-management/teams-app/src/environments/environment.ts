export const environment = {
  production: false,
  // Use proxy path instead of direct URL or in coder use "http://<workspace-name>.coder:<port>" with the port of forward of the api service
//  apiUrl: "http://pe-course-architect-ws-1.coder:8080",
  apiUrl: "http://localhost:8083",
  keycloak: {
    // same as above, but with keycloak forward port
//    url: "http://pe-course-architect-ws-1.coder:8082",
    url: "http://localhost:8082",
    realm: "teams",
    clientId: "teams-ui",
  },
};
