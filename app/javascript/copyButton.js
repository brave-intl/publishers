import ClipboardJS from 'clipboard';

window.ClipboardJS = ClipboardJS;
document.addEventListener('DOMContentLoaded', function() {
  // Turn all elements with class .copy-button into clipboard.js objects
  var copyButtons = document.querySelectorAll('.copy-button')
  new ClipboardJS(copyButtons)
});
