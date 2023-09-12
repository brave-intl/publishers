/** @type {import('next').NextConfig} */
const StylelintPlugin = require('stylelint-webpack-plugin');
const withNextIntl = require('next-intl/plugin')('./i18n.ts');

const nextAllowList = [
  '_next',
  'publishers/settings',
  'publishers/security',
  'publishers/totp_registrations/new',
  'publishers/u2f_registrations/new',
  'icons',
  'favicon',
  'api',
];

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

  async rewrites() {
    return [
      {
        source: `/api/:path*`,
        destination: `https://web:3000/api/:path*`,
      },
    ];
  },

  async redirects() {
    return [
      {
        source: `/:path((?!${nextAllowList.join('|')}).*)`,
        destination: `https://localhost:3000/:path*`,
        permanent: false,
      },
    ];
  },
  //

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
