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
          return {
            key: p.name,
            value: p.email.split("@")[0],
            avatarColor: p.avatar_color
          };
        });

        var tribute = new Tribute({
          values: list,
          menuItemTemplate: function(item) {
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
