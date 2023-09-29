import { NextResponse } from 'next/server';
import createIntlMiddleware from 'next-intl/middleware';

function secureUrl(url: string): string {
  return url.replace(/http:\/\//g, 'https://');
}

export function middleware(request) {
  const pathname = request.nextUrl.pathname;
  const locale = request.nextUrl.searchParams.get('locale');
  if (locale === 'ja') {
    return NextResponse.redirect(
      new URL(`/ja/${pathname}`, request.url),
    );
  }

  // next-intl middleware
  const defaultLocale = request.headers.get('x-default-locale') || 'en';
  const handleI18nRouting = createIntlMiddleware({
    locales: ['en', 'ja'],
    defaultLocale: 'en',
  });
  const response = handleI18nRouting(request);
  response.headers.set('x-default-locale', defaultLocale);

  // NextJS will pre-compile middleware routes in HTTP. To use SSL, we need to set all rewrites to
  // the appropriate url scheme
  if (process.env.NODE_ENV === 'development') {
    const rewriteUrl = response.headers.get('x-middleware-rewrite');
    const locationUrl = response.headers.get('location');

    if (rewriteUrl) {
      response.headers.set('x-middleware-rewrite', secureUrl(rewriteUrl));
    } else if (locationUrl) {
      response.headers.set('location', secureUrl(locationUrl));
    }
  }

  return response;
}

export const config = {
  // Skip all paths that should not be internationalized. This example skips the
  // folders "api", "_next" and all files with an extension (e.g. favicon.ico)
  matcher: ['/((?!api|_next|.*\\..*).*)'],
};
