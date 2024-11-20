import axios from 'axios';

export async function apiRequest(
  path: string,
  method: string = 'GET',
  data?: unknown,
  apiVersion: string = 'v1',
) {
  axios.defaults.xsrfCookieName = 'CSRF-TOKEN';
  axios.defaults.xsrfHeaderName = 'X-CSRF-Token';
  axios.defaults.withCredentials = true;

  try {
    const url = `/api/next${apiVersion}/${path}`;
    const response = await axios({ method, url, data });
    return response.data;
  } catch (err) {
    // all response codes that aren't 200s or 300s get sent here
    // Imperatively navigate to Unauthorized page on 403
    if (
      (err.response && err.response.status === 403) ||
      err.response.status === 422
    ) {
      window.location.replace('/log-in');
    } else if ( err.response && err.response.status === 404 ) {
      window.location.replace('/404');
    } else if ( err.response && err.response.status === 302 ){
      err.response.data && err.response.data.location && window.location.replace(err.response.data.location);
    } else {
      console.log(err);
    }

    return { errors: [err] };
  }
}
