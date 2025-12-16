import { NextResponse } from 'next/server';
import createMiddleware from 'next-intl/middleware';

function secureUrl(url: string): string {
  return url.replace(/http:\/\//g, 'https://');
}

export function middleware(request) {
  console.log("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
  console.log("request: ", request)
  const pathname = request.nextUrl.pathname;
  const locale = request.nextUrl.searchParams.get('locale');
  console.log('***************************************************************')
  console.log('pathname: ', pathname)
  console.log('locale: ', locale)
  if (locale === 'ja') {
    console.log('japanese locale param detected')
    return NextResponse.redirect(new URL(`/ja/${pathname}`, request.url));
  }

  // next-intl middleware
  const defaultLocale = request.headers.get('x-default-locale') || 'en';
  console.log("defaultLocale: ", defaultLocale)
  console.log("pathname match: ", pathname === '/')
  if (pathname === '/' ) {
    console.log("root path detected in middleware")
    const rootLocale = ['en', 'ja'].includes(defaultLocale) ? defaultLocale : null;
    console.log("root locale: ", rootLocale)
    console.log('redirect url: ', new URL(`/${rootLocale}`, request.url))
    return NextResponse.redirect(new URL(`/${rootLocale}`, request.url));
  }

  console.log("testing statements next intl middleware will run:")
  const unsafeExternalPathname = decodeURI(request.nextUrl.pathname);
  console.log(unsafeExternalPathname)
  console.log("base path: ", request.nextUrl.basePath)

  const handleI18nRouting = createMiddleware({
    locales: ['en', 'ja'],
    defaultLocale: 'en',
  });

  console.log("handleI18nRouting: ", handleI18nRouting)
  const response = handleI18nRouting(request);
  response.headers.set('x-default-locale', defaultLocale);
  console.log("response: ", response)

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
  matcher: ['/((?!api|_next|.*\\..*).*)', '/'],
};
