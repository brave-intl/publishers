(function() {

  this.submitForm = function(formId, method, showSpinners) {
    var form = document.getElementById(formId);
    var options = {
      headers: {
        'Accept': 'application/json'
      },
      credentials: 'same-origin',
      method: method,
      body: new FormData(form)
    };
    if (showSpinners) { spinner.show(); }
    return window.fetch(form.action, options)
      .then(function(response) {
        if (showSpinners) { spinner.hide(); }
        if (response.status === 401) {
          // Force a page reload if the user is no longer authenticated.
          window.location.reload();
        }
        return response;
      })
      .catch(function(e) {
        if (showSpinners) { spinner.hide(); }
        window.alert("An unexpected error occurred. Please try reloading this page.")
      });
  }

  this.pollUntilSuccess = function(url, delay, backoff, attempts) {
    return new Promise(function(resolve, reject) {
      var attempt = 0;
      var currentDelay = delay;

      function fetchAttempt() {
        attempt++;

        if (attempt > attempts) {
          reject(new Error('Attempts exceeded!'));
          return;
        }

        fetchAfterDelay(url, currentDelay)
          .then(function(response) { resolve(response); })
          .catch(function(e) {
            currentDelay += backoff;
            fetchAttempt();
          });
      }

      fetchAttempt();
    });
  }

  this.fetchAfterDelay = function(url, delay) {
    return new Promise(function(resolve, reject) {
      setTimeout(function() {
        var options = {
          headers: {
            'Accept': 'application/json'
          },
          credentials: 'same-origin',
          method: 'GET'
        };
        window.fetch(url, options)
          .then(function(response) {
            if (response.status >= 200 && response.status < 300) {
              resolve(response);
            } else {
              reject(response);
            }
          }, function(e) {
            reject(e);
          });
      }, delay);
    });
  }

}).call(window);
