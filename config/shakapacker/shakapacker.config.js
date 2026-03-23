// config/webpack/webpack.config.js
const path = require("path");
const { webpackConfig, merge } = require("shakapacker");
const ForkTSCheckerWebpackPlugin = require("fork-ts-checker-webpack-plugin");

const customConfig = {
  resolve: {
    extensions: [".css"],
  },
};

module.exports = merge(
  webpackConfig,
  {
    plugins: [new ForkTSCheckerWebpackPlugin()],
  },
  customConfig,
);
