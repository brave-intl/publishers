import {getRequestConfig} from 'next-intl/server';
 
export default getRequestConfig(async ({requestLocale}) => {
  const requested = await requestLocale;
  const locale = requested || 'en';
  
  return {
    locale,
    messages: (await import(`./src/messages/${locale}.json`)).default
  };
});