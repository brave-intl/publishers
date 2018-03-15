document.addEventListener('DOMContentLoaded', function () {
  let userMenu = document.getElementsByClassName('user-menu')[0];
  let userMenuTrigger = document.getElementsByClassName('user-menu-trigger')[0];
  let userDropdown = document.getElementsByClassName('user-dropdown')[0];

  // close the dropdown menu, if open
  document.addEventListener('click', function (event) {
    if (!userMenu.contains(event.srcElement) && userDropdown.offsetParent !== null) {
      userMenuTrigger.click();
    }
  });
});