// // Send a GET API requests to the API server and send results
// // to the `success` callback
// // =================
// //
// // When sending a request to the API server, all headers received from
// // the browser will be relayed, as is, to the API server with the following exceptions.
// //
// // 1. The "Accept:" header will be set to "application/json"
// //
// // When receiving a response from the API server, all headers received from
// // the API server will be relayed, as is, to the Browser.
// //
// // 1. The "content-type" header will not ignored and will not be sent to the browser.
// // 1. The "content-encoding" header will be ignored and will not be sent to the browser.
// //
// // Managing errors
// // =====================
// //
// // Errors are handled inside `apiGetProps()`.
// //
// // Example
// // ===================
// //   return apiGetProps({
// //     context: context,
// //     url: `http://web:3000/categories/${context.params.cid}`,
// //     options: {},
// //     success: (response, category) => {
// //       return {
// //         props: {
// //           category,
// //           breadcrumbs,
// //           actionButton: {url: `/categories/${context.params.cid}/edit`, text: "Edit Category"}
// //         }
// //       }
// //     }
// //   })
// export async function apiGetProps({ context, url, options = {}, success }) {
//   const apiHeaders = apiRequestHeaders(context);
//   const response = await fetch(url, { headers: apiHeaders, ...options });

//   if (response.status == 200) {
//     const headers = await response.headers;
//     const json = await response.json();

//     setBrowserResponseHeaders(headers, context);

//     return success(response, json);
//   } else if (response.status == 401) {
//     return {
//       redirect: {
//         destination: '/users/sign_in',
//         permanent: false,
//       },
//     };
//   } else if (response.status == 404) {
//     return {
//       notFound: true,
//     };
//   } else {
//     return {
//       notFound: true,
//     };
//   }
// }

// // Asynchronously fetch from multiple APIs and send
// // json results to the `success` callback.
// // ===============
// //
// // Acting as a pass-through
// // ===============
// // This acts in much the same way as `apiGetProps` above. Note that the
// // headers from each API are combined. We may need to change this in the future.
// //
// // Managing errors
// // ===================
// //
// // Error handing is similar to `apiGetProps` above and is managed within the
// // apiGetMultiple() function.
// //
// // Example
// // =====================
// // return apiGetMuliple({
// //   context: context,
// //   requests: [
// //     {url: "http://web:3000/categories", options: {}},
// //     {url: "http://web:3000/frameworks", options: {}},
// //   ],
// //   success: (jsonResponses) => {
// //     const [categories, frameworks] = jsonResponses
// //     return {
// //       props: {
// //         categories: categories,
// //         frameworks: frameworks,
// //         breadcrumbs,
// //         actionButton: {url: `/categories/${context.params.cid}/edit`, text: "Edit Category"}
// //       }
// //     }
// //   }
// // })
// //
// export async function apiGetMultiple({ context, requests, success }) {
//   const apiHeaders = apiRequestHeaders(context);

//   const jsonPromises = requests.map(async ({ url, options }) => {
//     const response = await fetch(url, { headers: apiHeaders, ...options });

//     if (response.status == 200) {
//       const headers = await response.headers;
//       const json = await response.json();

//       setBrowserResponseHeaders(headers, context);

//       return json;
//     } else {
//       return { errorStatus: response.status };
//     }
//   });

//   const jsonResponses = await Promise.all(jsonPromises);

//   if (jsonResponses.every((jr) => !jr.errorStatus)) {
//     return success(jsonResponses);
//   } else if (jsonResponses.some((jr) => jr.errorStatus == 401)) {
//     return {
//       redirect: {
//         destination: '/users/sign_in',
//         permanent: false,
//       },
//     };
//   } else if (jsonResponses.some((jr) => jr.errorStatus == 404)) {
//     return {
//       notFound: true,
//     };
//   } else {
//     return {
//       notFound: true,
//     };
//   }
// }

// function apiRequestHeaders(context) {
//   const ignoredReqestHeaders = ['host'];
//   let passedToServer = {};

//   // pass through headers
//   const headers = context.req.headers;
//   Object.keys(context.req.headers).forEach((key) => {
//     if (ignoredReqestHeaders.includes(key)) {
//       return;
//     }

//     passedToServer[key] = headers[key];
//   });

//   // additional headers to set/override
//   passedToServer['accept'] = 'application/json';

//   return passedToServer;
// }

// function setBrowserResponseHeaders(headers, context) {
//   const ignoredResponseHeaders = [
//     'content-type',
//     'content-encoding',
//     'transfer-encoding',
//   ];

//   // pass through headers
//   headers.forEach((value, key) => {
//     if (ignoredResponseHeaders.includes(key)) {
//       return;
//     }

//     context.res.setHeader(key, value);
//   });
// }
