// config/webpack/webpack.config.js
const path = require("path");
const { webpackConfig, merge } = require("shakapacker");
const ForkTSCheckerWebpackPlugin = require("fork-ts-checker-webpack-plugin");

const customConfig = {
  resolve: {
    alias: {
      "brave-ui": path.resolve(__dirname, "../../node_modules/brave-ui/src"),
    },
    fallback: {
      stream: require.resolve("stream-browserify"),
      vm: require.resolve("vm-browserify"),
    },
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
