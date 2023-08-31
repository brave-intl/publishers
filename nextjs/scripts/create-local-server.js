var https = require('https');
var next = require('next');
var express = require('express');
var fs = require('fs');
var path = require('path');
var { createProxyMiddleware } = require('http-proxy-middleware');

var dev = process.env.NODE_ENV !== 'production';
var app = next({ dev, config: '../next.config.js' });
var handle = app.getRequestHandler();
var PORT = process.env.PORT || 5001;
var isDevelopment = process.env.NODE_ENV !== 'production';

app
  .prepare()
  .then(function () {
    var expressApp = express();

    expressApp.get('/publishers/settings', function (req, res) {
      return handle(req, res);
    });
    expressApp.get('*_next*', function (req, res) {
      return handle(req, res);
    });

    expressApp.use(
      '*',
      createProxyMiddleware('**', {
        logger: console,
        target: 'https://web:3000',
        changeOrigin: true,
        secure: !isDevelopment,
        onProxyReq: function (request) {
          request.setHeader('origin', 'https://web:3000');
        },
      }),
    );

    var server = https.createServer(
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

    return server.listen(PORT, function (err) {
      if (err) throw err;

      console.log('> Ready on https://localhost:5001');
    });
  })
  .catch(function (err) {
    console.log('Error:::::', err);
  });
