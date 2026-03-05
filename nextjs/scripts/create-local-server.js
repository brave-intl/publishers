const { createProxyMiddleware } = require('http-proxy-middleware');
const chalk = require('chalk');
const next = require('next');
const path = require('path');
const fs = require('fs');
const express = require('express');
const selfsigned = require('selfsigned');

const dev = process.env.NODE_ENV === 'development';
const { createServer } = dev ? require('https') : require('http');

const testMode = process.env.TEST_MODE === 'true';
const PORT = 5001;
const app = next({ dev });
const handle = app.getRequestHandler();


const nextAllowPageRoutes = [
  '/publishers/settings',
  '/publishers/security',
  '/publishers/totp_registrations/new',
  '/publishers/u2f_registrations/new',
  '/publishers/home',
  '/publishers/contribution_page',
  '/c/*name',
  '/sign-up',
  '/log-in',
];
const routeMatch = [
  ...nextAllowPageRoutes.map((r) => `/ja${r}`),
  ...nextAllowPageRoutes.map((r) => `/en${r}`),
  ...nextAllowPageRoutes,
  '/_next/*splat'
];

app
  .prepare()
  .then( async () => {
    const expressApp = express();

    // use the express app to serve static assets, necessary for Nala icons to work
    expressApp.use(express.static('public'));

    let pubHost, nextHost;
    if (testMode) {
      pubHost = new URL(`http://${process.env.TEST_MODE_PUBLISHERS_HOST}`);
      nextHost = `https://${process.env.TEST_MODE_NEXT_HOST}`;
    } else {
      pubHost = new URL(`https://${process.env.PUBLISHERS_HOST}`);
      nextHost = `https://${process.env.NEXT_HOST}`;
    }

    console.log('pubHost', pubHost);
    console.log('nextHost', nextHost);

    const middlewareToRouteToRails = createProxyMiddleware({
      logger: console,
      target: pubHost,
      changeOrigin: true,
      prependPath: true,
      secure: testMode ? false : !dev,
      on: {
        proxyReq: (proxyReq, request, response) => {
          const ip = (
            request.headers['x-forwarded-for'] || request.socket.remoteAddress
          )
            .split(':')
            .pop();
          proxyReq.setHeader('originalIP', ip);
          proxyReq.setHeader('origin', pubHost.origin);
        },
        proxyRes: (proxyRes, request, response) => {
          const redir = proxyRes.headers['location'];
          if (redir) {
            try {
              const redirUrl = new URL(redir);
              if (
                redirUrl.protocol === pubHost.protocol &&
                redirUrl.host === pubHost.host
              ) {
                const newRedirUrlToProxy = `${nextHost}${redirUrl.pathname}${redirUrl.search}`;
                proxyRes.headers['location'] = newRedirUrlToProxy;
              }
            } catch (e) {
              if (!e.code || e.code != 'ERR_INVALID_URL') throw e;
            }
          }
        },
      }
    });

    // Then handle the next specific routes
    // Paths next will handle, route them explicitly, everything else goes to rails
    expressApp.get(routeMatch, (req, res) => {
      return handle(req, res);
    });

    // Handle root path - proxy to Rails
    expressApp.get('/', middlewareToRouteToRails);

    // Then the rest proxy over to Rails
    expressApp.all('/*any', middlewareToRouteToRails);

    let server;
    if (dev) {
      // Generate a self-signed certificate and key
      const attrs = [{ name: 'commonName', value: 'localhost' }];
      const pems = await selfsigned.generate(attrs, { days: 365 });

      const serverOptions = {
        key: pems.private,
        cert: pems.cert,
      };
      server = createServer(serverOptions, expressApp);
    } else {
      server = createServer({}, expressApp);
    }

    return server.listen(PORT, (err) => {
      if (err) throw err;

      console.log(
        chalk.green(`> Server started on ${chalk.bold.green(`${nextHost}`)}`),
      );
    });
  })
  .catch((err) => {
    console.log('Error:::::', err);
  });
