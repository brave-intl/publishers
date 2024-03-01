const { createProxyMiddleware } = require('http-proxy-middleware');
const httpProxy = require('http-proxy');
const chalk = require('chalk');
const next = require('next');
const path = require('path');
const fs = require('fs');
const express = require('express');
const dev = process.env.NODE_ENV == 'development';
const { createServer } = dev ? require('https') : require('http');
const PORT = 5001;
const app = next({ dev });
const handle = app.getRequestHandler();

const nextAllowRoutes = ['_next', '^icons', 'favicon', 'api'];
const nextAllowPageRoutes = [
  'publishers/settings',
  'publishers/security',
  'publishers/totp_registrations/new',
  'publishers/u2f_registrations/new',
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

    // use the express app to serve static assets, necessary for Nala icons to work
    expressApp.use(express.static('public'));
    // Paths next will handle, route them explicitly, everything else goes to rails
    expressApp.get(routeMatch, (req, res) => {
      return handle(req, res);
    });

    const pubHost = new URL(`https://${process.env.PUBLISHERS_HOST}`);
    const nextHost = `https://${process.env.NEXT_HOST}`;

    // Proxy over to Rails
    expressApp.use(
      '*',
      createProxyMiddleware('**', {
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
                const newRedirUrlToProxy = `${nextHost}${redirUrl.pathname}`;
                proxyRes.headers['location'] = newRedirUrlToProxy;
              }
            } catch (e) {
              if (!e.code || e.code != "ERR_INVALID_URL") throw e;
            }
          }
        },
      }),
    );

    const createServerOpts = dev ? {
      key: fs.readFileSync(
        path.join(__dirname, '..', '..', 'ssl', 'server.key'),
      ),
      cert: fs.readFileSync(
        path.join(__dirname, '..', '..', 'ssl', 'server.crt'),
      ),
    } : {};
    const server = createServer(createServerOpts, expressApp);

    return server.listen(PORT, (err) => {
      if (err) throw err;

      console.log(
        chalk.green(
          `> Server started on ${chalk.bold.green(
            `http://localhost:${PORT}`,
          )}`,
        ),
      );
    });
  })
  .catch((err) => {
    console.log('Error:::::', err);
  });
