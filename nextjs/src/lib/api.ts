export async function apiRequest(
  path: string,
  params?: unknown,
  method: string = 'GET',
  apiVersion: string = 'v1',
) {
  try {
    const options = {
      method,
      params,
    };
    const endpoint = `/api/next${apiVersion}/${path}`;
    const result = await fetch(endpoint, options);
    const payload = await result.json();

    // verify request had 2xx status code
    if (!result.ok) {
      // Imperatively navigate to Unauthorized page on 403
      if (result.status === 403) {
        // TODO: This path doesn't exist yet
        window.location.replace('/unauthorized');
      }

      if (result.status >= 500) {
        throw new Error('Server error occurred. Try again later.');
      }
      throw payload;
    }

    return payload;
  } catch (err) {
    return { errors: [err] };
  }
}
