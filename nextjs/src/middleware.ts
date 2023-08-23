/* eslint-disable */
import { NextResponse } from 'next/server';
import createIntlMiddleware from 'next-intl/middleware';

export function middleware(request) {

  const handledPaths = [
    "/publishers/settings"
  ]

  console.log(request.nextUrl.pathname)
  console.log(handledPaths.some((path) => request.nextUrl.pathname.startsWith(path)))

  if (handledPaths.some((path) => request.nextUrl.pathname.startsWith(path))) {
    console.log("STARSZZZZ@@@@")
     // console.log(request);

  const pathname = request.nextUrl.pathname;
  const locale = request.nextUrl.searchParams.get('locale');
  if (locale === 'ja') {
    return NextResponse.redirect(
      new URL(`/${locale}/${pathname}`, request.url),
    );
  }

  // next-intl middleware
  const defaultLocale = request.headers.get('x-default-locale') || 'en';
  const handleI18nRouting = createIntlMiddleware({
    locales: ['en', 'ja'],
    defaultLocale: 'en', 
    localePrefix: 'never',
  });
  const response = handleI18nRouting(request);
  response.headers.set('x-default-locale', defaultLocale);

  return response;

  }

    // console.log(request.method);
  // console.log(request.method.toUpperCase());
  // console.log(request.method.toUpperCase() == 'GET');
  // debugger;
  if (!requestIsGet(request)) {
    // debugger;
    // const axiosInstance = axios.create()
    console.log('GHERERER!!');
    const requestHeaders = new Headers(request.headers);
    requestHeaders.set('host', 'http://localhost:3000');
    requestHeaders.set('origin', 'http://localhost:3000');
    requestHeaders.set('x-forwarded-host', 'http://localhost:3000');
    console.log(request);
    // debugger;
    return NextResponse.rewrite(request.nextUrl, {
      request: {
        headers: requestHeaders,
      },
    });
  }


  
 
}

function requestIsGet(request) {
  return request.method.toUpperCase() == 'GET';
}

export const config = {
  // Skip all paths that should not be internationalized. This example skips the
  // folders "api", "_next" and all files with an extension (e.g. favicon.ico)
  // matcher: ['/((?!api|_next|.*\\..*).*)'],
};
