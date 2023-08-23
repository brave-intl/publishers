/** @type {import('next').NextConfig} */
const StylelintPlugin = require('stylelint-webpack-plugin');
// const withNextIntl = require('next-intl/plugin')('./i18n.ts');

const nextConfig = {
  eslint: {
    dirs: ['src'],
  },

  // https://nextjs.org/docs/migrating/incremental-adoption#rewrites
  async rewrites() {
    return {
      // After checking all Next.js pages (including dynamic routes)
      // and static files we proxy any other requests
      fallback: [
        {
          source: '/en/:path*',
          destination: `http://localhost:3000/:path*`,
        },
        {
          source: '/:path*',
          destination: `http://localhost:3000/:path*`,
        },
      ],
    }
  },

  output: 'standalone',

  reactStrictMode: true,
  swcMinify: true,

  // Uncoment to add domain whitelist
  // images: {
  //   domains: [
  //     'res.cloudinary.com',
  //   ],
  // },

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

module.exports = nextConfig;
// module.exports = withNextIntl(nextConfig);
