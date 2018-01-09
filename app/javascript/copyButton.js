import Clipboard from 'clipboard';

document.addEventListener('DOMContentLoaded', function() {
  // Turn all elements with class .copy-button into clipboard.js objects
  var copyButtons = document.querySelectorAll('.copy-button')
  var clipboard = new Clipboard(copyButtons)
});
