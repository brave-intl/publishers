;(function() {
  'use strict';

  window.U2FShared = {
    clearErrors: function clearErrors(errorGroupClassName) {
      let errorElements = document.querySelectorAll('.js-'+errorGroupClassName+' > div');
      for (let i=0;i<errorElements.length;i++) {
        errorElements[i].classList.remove('show');
      }
    },

    showError: function showError(errorClassName) {
      document.querySelector('.js-'+errorClassName).classList.add('show');
    }
  };
})();
