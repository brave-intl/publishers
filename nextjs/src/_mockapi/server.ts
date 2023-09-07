import { createServer, Model } from 'miragejs';

import factories from './factories';

export function makeServer() {
  const server = createServer({
    models: {
      user: Model,
    },

    factories,

    seeds(server) {
      // Load all fixture & model data into the development db
      server.create('user');
    },

    routes() {
      this.urlPrefix = 'https://localhost:3001';
      this.namespace = '/api/v1/';

      this.get('user/me', (schema) => {
        return schema!.first('user')!.attrs;
      });
    },
  });

  return server;
}
