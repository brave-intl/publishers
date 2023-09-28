const { createProxyMiddleware } = require('http-proxy-middleware');
const httpProxy = require('http-proxy');
const chalk = require('chalk');
const { parse } = require('url');
const next = require('next');
const path = require('path');
const fs = require('fs');
const express = require('express');
const { createServer } = require('https');
var url=require('url');
const PORT = 5001;
const dev = process.env.NODE_ENV !== 'production';
const app = next({ dev });
const handle = app.getRequestHandler();
const isDevelopment = process.env.NODE_ENV !== 'production';

const nextAllowRoutes = ['_next', 'icons', 'favicon', 'api'];
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

    // Paths next will handle, route them explicitly, everything else goes to rails
    expressApp.get(routeMatch, (req, res) => {
      return handle(req, res);
    });

    // Proxy over to Rails
    expressApp.use(
      '*',
      createProxyMiddleware('**', {
        logger: console,
        target: 'https://localhost:3000',
        changeOrigin: true,
        secure: !isDevelopment,
        onProxyReq: (proxyReq, request, response) => {
          proxyReq.setHeader('origin', 'https://localhost:3000');
        },
        onProxyRes: (proxyRes, request, response) => {
          const redir = proxyRes.headers['location'];
          if(redir) {
            const host = parse(redir).host
            if(`https://${host}` == 'https://localhost:3000') {
              const newRedirUrlToProxy = `https://localhost:5001${parse(redir).pathname}`
              proxyRes.headers['location'] = newRedirUrlToProxy
            }
          }
        },
      }),
    );

    const server = createServer(
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

    return server.listen(PORT, (err) => {
      if (err) throw err;

    console.log(
      chalk.green(
        `> Server started on ${chalk.bold.green(`https://localhost:${PORT}`)}`,
      ),
    );
    });
  })
  .catch((err) => {
    console.log('Error:::::', err);
  });
