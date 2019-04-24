const fs = require("fs");

const pathToEntry = "./build/index.html";
const bundlesRegExp = /\/static\/\w+\/\w+.[a-z0-9]+.[a-z0-9]+.\w{2,3}"/g;

let builtHTMLContent = fs.readFileSync(pathToEntry).toString();

builtHTMLContent.match(bundlesRegExp).map(bundle => {
  if (bundle.indexOf(".js") !== -1) {
    builtHTMLContent = builtHTMLContent.replace(bundle, `${bundle} async`);
  }
});

fs.writeFileSync(pathToEntry, builtHTMLContent);
