import "utils/request";
import "admin/dashboard/index";
import "admin/stats/index";
import "admin/dashboard/unattached_promo_registration";
import Rails from "rails-ujs";
import Tribute from "tributejs";
import "tributejs/dist/tribute.css";

import Avatar from "../views/admin/components/userNavbar/components/TopNav/Avatar.svg";

document.addEventListener("DOMContentLoaded", function() {
  if (window.location.href.indexOf("admin/publishers/") !== -1) {
    fetch("/admin/publishers?role=admin")
      .then(function(response) {
        return response.json();
      })
      .then(function(publishers) {
        const list = publishers.map(p => {
          console.log(p);
          return {
            key: p.name,
            value: p.email.split("@")[0],
            avatarColor: p.avatar_color
          };
        });

        var tribute = new Tribute({
          values: list,
          menuItemTemplate: function(item) {
            console.log(item);
            return (
              `<div class="d-flex align-items-center">` +
              `<div class="user-avatar-dropdown" style="background: #${
                item.original.avatarColor
              };">` +
              `<img src=${Avatar} />` +
              `</div>` +
              `${item.string}` +
              `</div>`
            );
          }
        });

        tribute.attach(document.querySelectorAll(".note-form"));
      });
  }
});

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
document.addEventListener(
  "DOMContentLoaded",
  function() {
    let sidebarToggles = document.getElementsByClassName("sidebar-toggle");
    for (var i = 0; i < sidebarToggles.length; i++) {
      sidebarToggles[i].addEventListener("click", function(event) {
        var item = event.target || event.srcElement;
        // If the clicked element doesn't have the right selector, bail
        document.activeElement.blur();
        event.preventDefault();

        //    let icon = document.querySelector('#sidebar-toggle > .fa');
        let icon = item.children[0];

        // Toggle the menu
        let element = item.parentElement.querySelector(".sub-menu");
        if (element.style.display === "none") {
          icon.classList.remove("fa-chevron-down");
          icon.classList.add("fa-chevron-up");
          element.style.display = "";
        } else {
          icon.classList.remove("fa-chevron-up");
          icon.classList.add("fa-chevron-down");
          element.style.display = "none";
        }
      });
    }
  },
  false
);
