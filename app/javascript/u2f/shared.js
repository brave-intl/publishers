export function clearErrors(errorGroupClassName) {
  var errorElements = document.querySelectorAll('.js-'+errorGroupClassName+' > div');
  var i;
  for (i=0;i<errorElements.length;i++) {
    errorElements[i].classList.remove('show');
  }
}

export function showError(errorClassName) {
  document.querySelector('.js-'+errorClassName).classList.add('show');
}
