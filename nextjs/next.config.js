/** @type {import('next').NextConfig} */
const StylelintPlugin = require('stylelint-webpack-plugin');
const withNextIntl = require('next-intl/plugin')('./i18n.ts');

const dns = require('dns');
dns.setDefaultResultOrder('ipv4first');

const nextConfig = {
  eslint: {
    dirs: ['src'],
    ignoreDuringBuilds: true,
  },

  output: 'standalone',
  reactStrictMode: true,
  swcMinify: true,

  // TODO: remove this code once Proxy is no longer needed
  images: { unoptimized: process.env.NODE_ENV === 'development' },

  webpack(config) {
    // Grab the existing rule that handles SVG imports
    const fileLoaderRule = config.module.rules.find((rule) =>
      rule.test?.test?.('.svg'),
    );

    // Add stylelint plugin
    config.plugins.push(new StylelintPlugin());

    config.module.rules.push(
      // Reapply the existing rule, but only for svg imports ending in ?url
      {
        ...fileLoaderRule,
        test: /\.svg$/i,
        resourceQuery: /url/, // *.svg?url
      },
      // Convert all other *.svg imports to React components
      {
        test: /\.svg$/i,
        issuer: { not: /\.(css|scss|sass)$/ },
        resourceQuery: { not: /url/ }, // exclude if *.svg?url
        loader: '@svgr/webpack',
        options: {
          dimensions: false,
          titleProp: true,
        },
      },
    );

    // Modify the file loader rule to ignore *.svg, since we have it handled now.
    fileLoaderRule.exclude = /\.svg$/i;

    return config;
  },
};

module.exports = withNextIntl(nextConfig);
