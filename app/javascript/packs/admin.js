import 'utils/request';
import 'publishers/statements';
import Rails from 'rails-ujs';

/*
 * Override the default way Rails picks an href for a data-method link. This
 * allows you to provide both a non-JS and a JS URL to a UJS link.
 *
 * For exmaple this link would delete when JS is present, but without JS
 * a click would take you to the URL `/publishers`:
 *
 *     <a href="/publishers" data-method="delete">delete</a>
 *
 * These two behaviors are very different. To provide a URL for non-JS, pass
 * the JS URL as `data-href`:
 *
 *     <a
 *       href="/publishers/confirm_delete_page"
 *       data-href="/publishers"
 *       data-method="delete"
 *    >delete</a>
 *
 * Now a non-JS user will be sent to `/publishers/confirm_delete_page` while
 * a JS user will have the deletion occur immediately.
 */
Rails.href = function Rails_href_override(element) {
  let dataHref = element.dataset.href;
  return dataHref || element.href;
};

Rails.start();
