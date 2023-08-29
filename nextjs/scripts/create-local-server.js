import express from 'express';
import { readFileSync } from 'fs';
import { createProxyMiddleware } from 'http-proxy-middleware';
import { createServer as createHttpsServer } from 'https';
import next from 'next';
import path from 'path';
import { fileURLToPath } from 'url';

const dev = process.env.NODE_ENV !== 'production';
const app = next({ dev, config: '../next.config.js' });
const handle = app.getRequestHandler();
const PORT = process.env.PORT || 5000;
const isDevelopment = process.env.NODE_ENV !== 'production';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

app
  .prepare()
  .then(() => {
    const expressApp = express();

    // Paths next will handle, route them explicitly, everything else goes to rails
    expressApp.get('/publishers/settings', (req, res) => {
      return handle(req, res);
    });
    expressApp.get('*_next*', (req, res) => {
      return handle(req, res);
    });

    // Proxy over to Rails
    expressApp.use(
      '*',
      createProxyMiddleware('**', {
        logger: console,
        target: 'https://127.0.0.1:3000',
        changeOrigin: true,
        secure: !isDevelopment,
        // https://stackoverflow.com/a/58752889  since changeOrigin doesn't work for the type of request we actually need, PUT
        onProxyReq: function (request) {
          request.setHeader('origin', 'https://127.0.0.1:3000');
        },
      }),
    );

    const server = createHttpsServer(
      {
        key: readFileSync(
          path.join(__dirname, '..', '..', 'ssl', 'server.key'),
        ),
        cert: readFileSync(
          path.join(__dirname, '..', '..', 'ssl', 'server.crt'),
        ),
      },
      expressApp,
    );

    return server.listen(PORT, (err) => {
      if (err) throw err;

      console.log('> Ready on https://localhost:5000');
    });
  })
  .catch((err) => {
    console.log('Error:::::', err);
  });
