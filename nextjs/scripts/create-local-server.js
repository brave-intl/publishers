const { createProxyMiddleware } = require('http-proxy-middleware');
const httpProxy = require('http-proxy');
const chalk = require('chalk');
const next = require('next');
const path = require('path');
const fs = require('fs');
const express = require('express');
const dev = process.env.NODE_ENV === 'development';
const { createServer } = dev ? require('https') : require('http');
const PORT = 5001;
const app = next({ dev });
const handle = app.getRequestHandler();
const basicAuth = require('express-basic-auth')

const nextAllowRoutes = ['_next', '^icons', 'favicon'];
const nextAllowPageRoutes = [
  'publishers/settings',
  'publishers/security',
  'publishers/totp_registrations/new',
  'publishers/u2f_registrations/new',
  'publishers/home',
];
const routeMatch = [
  nextAllowPageRoutes.map((r) => `ja/${r}`).join('|'),
  nextAllowPageRoutes.join('|'),
  nextAllowRoutes.join('|'),
].join('|');

app
  .prepare()
  .then(() => {
    const expressApp = express();
    // use the express app to serve static files
    expressApp.use(express.static('public'));

    // use the express app to serve static assets, necessary for Nala icons to work
    expressApp.use(express.static('public'));

    const pubHost = new URL(`https://${process.env.PUBLISHERS_HOST}`);
    const nextHost = `https://${process.env.NEXT_HOST}`;

    const middlewareToRouteToRails = createProxyMiddleware('**', {
      logger: console,
      target: pubHost,
      changeOrigin: true,
      secure: !dev,
      onProxyReq: (proxyReq, request, response) => {
        const ip = (request.headers['x-forwarded-for'] || request.socket.remoteAddress).split(':').pop()
        proxyReq.setHeader('originalIP', ip );
        proxyReq.setHeader('origin', pubHost.origin );
      },
      onProxyRes: (proxyRes, request, response) => {
        const redir = proxyRes.headers['location'];
        if (redir) {
          try {
            const redirUrl = new URL(redir);
            if (redirUrl.protocol === pubHost.protocol && redirUrl.host === pubHost.host) {
              const newRedirUrlToProxy = `${nextHost}${redirUrl.pathname}${redirUrl.search}`;
              proxyRes.headers['location'] = newRedirUrlToProxy;
            }
          } catch (e) {
            if (!e.code || e.code != "ERR_INVALID_URL") throw e;
          }
        }
      },
    })

    // Pull out the health check in particular as not needed http auth
    expressApp.use('/health-check', middlewareToRouteToRails);

    // Then add http auth to everything else
    // const basicAuthUser = process.env.BASIC_AUTH_USER;
    // const basicAuthPass = process.env.BASIC_AUTH_PASSWORD;
    // if (basicAuthUser && basicAuthPass) {
    //   expressApp.use(basicAuth({
    //     users: { [process.env.BASIC_AUTH_USER]: process.env.BASIC_AUTH_PASSWORD },
    //     challenge: true
    //   }))
    // }

    // Then handle the next specific routes

    // Paths next will handle, route them explicitly, everything else goes to rails
    expressApp.get(routeMatch, (req, res) => {
      return handle(req, res);
    });

    // Then the rest proxy over to Rails
    expressApp.use(
      '*',
      middlewareToRouteToRails,
    );

    let server;
    if (dev) {
      server = createServer(
        {
          key: fs.readFileSync(
            path.join(__dirname, '..', '..', 'ssl', 'server.key'),
          ),
          cert: fs.readFileSync(
            path.join(__dirname, '..', '..', 'ssl', 'server.crt'),
          ),
        },
        expressApp,
      );
    } else {
      server = createServer(
        {},
        expressApp,
      );
    }

    return server.listen(PORT, (err) => {
      if (err) throw err;

      console.log(
        chalk.green(
          `> Server started on ${chalk.bold.green(
            `https://localhost:${PORT}`,
          )}`,
        ),
      );
    });
  })
  .catch((err) => {
    console.log('Error:::::', err);
  });