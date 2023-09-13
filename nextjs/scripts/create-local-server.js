const { createServer } = require('https');
const httpProxy = require('http-proxy');
const chalk = require('chalk');
const { parse } = require('url');
const next = require('next');
const path = require('path');
const fs = require('fs');

const PORT = 5001;
const dev = process.env.NODE_ENV !== 'production';
const app = next({ dev });
const handle = app.getRequestHandler();

const httpsOptions = {
  key: fs.readFileSync(path.join(__dirname, '..', '..', 'ssl', 'server.key')),
  cert: fs.readFileSync(path.join(__dirname, '..', '..', 'ssl', 'server.crt')),
};

app.prepare().then(() => {
  createServer(httpsOptions, (req, res) => {
    const parsedUrl = parse(req.url, true);

    handle(req, res, parsedUrl);
  }).listen(PORT, (err) => {
    if (err) throw err;
    console.log(
      chalk.green(
        `> Server started on ${chalk.bold.green(`https://localhost:${PORT}`)}`,
      ),
    );
  });
});
