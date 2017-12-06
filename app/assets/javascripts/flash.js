(function() {

  var _flashElement;

  function flashElement() {
    return _flashElement || document.getElementById('flash');
  }

  this.flash = {
    clear: function() {
      var containerElement = flashElement();
      containerElement.innerHTML = '';
    },

    append: function(type, message) {
      var containerElement = flashElement();
      var messageElement = document.createElement('div');
      messageElement.className = 'alert flash alert-' + type;
      messageElement.innerHTML = message;
      containerElement.appendChild(messageElement);
    },

    show: function() {
      var containerElement = flashElement();
      containerElement.style.display = 'block';
    },

    hide: function() {
      var containerElement = flashElement();
      containerElement.style.display = 'none';
    }
  };

}).call(window);
