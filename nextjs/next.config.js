/** @type {import('next').NextConfig} */
import nextIntl from 'next-intl/plugin';
import StylelintPlugin from 'stylelint-webpack-plugin';

if ('development' == process.env.NODE_ENV) {
  console.log('Rejecting node tls');
  process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';
  process.env['NODE_TLS_REJECT_UNAUTHORIZED'] = '0';
}

const withNextIntl = nextIntl('./i18n.ts');

const nextConfig = {
  eslint: {
    dirs: ['src'],
  },

  reactStrictMode: false,
  swcMinify: true,
  output: 'standalone',

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

export default withNextIntl(nextConfig);
