const webpackConfig = require('./config/webpack/test.js');

module.exports = function(config) {
  config.set({
    frameworks: ['qunit'],
    plugins: [
      'karma-qunit',
      'karma-webpack',
      'karma-chrome-launcher'
    ],
    files: [
      'test/javascript/*-test.js'
    ],
    webpack: webpackConfig,
    preprocessors: {"test/javascript/*-test.js": ["webpack"]},
    client: {
      clearContext: false,
      qunit: {
        showUI: true,
        testTimeout: 5000
      }
    }
  });
}
