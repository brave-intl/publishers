// config/webpack/webpack.config.js
const path = require("path");
const { generateWebpackConfig, merge } = require("shakapacker");
const ForkTSCheckerWebpackPlugin = require("fork-ts-checker-webpack-plugin");

const customConfig = {
  resolve: {
    fallback: {
      stream: require.resolve("stream-browserify"),
      vm: require.resolve("vm-browserify"),
    },
    extensions: [".css"],
  },
  module: {
    rules: [
      {
        test: /\.m?js$/,
        resolve: {
          fullySpecified: false,
        },
      },
    ],
  },
};

module.exports = merge(generateWebpackConfig(customConfig), {
  plugins: [new ForkTSCheckerWebpackPlugin()],
});
