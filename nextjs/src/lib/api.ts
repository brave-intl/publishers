import axios from 'axios';

export async function apiRequest(
  path: string,
  data?: unknown,
  method: string = 'GET',
  apiVersion: string = 'v1',
) {
  try {
    const url = `/api/next${apiVersion}/${path}`;
    const response = await axios({ method, url, data });

    // verify request had 2xx status code
    if (response.statusText !== 'OK') {
      // Imperatively navigate to Unauthorized page on 403
      if (response.status === 403) {
        // TODO: This path doesn't exist yet
        window.location.replace('/unauthorized');
      }

      if (response.status >= 500) {
        throw new Error('Server error occurred. Try again later.');
      }
      throw response.data;
    }

    return response.data;
  } catch (err) {
    return { errors: [err] };
  }
}
