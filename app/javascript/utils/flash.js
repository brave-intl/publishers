let _flashElement;

function flashElement() {
  return _flashElement || document.getElementById('flash');
}

export default {
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
    containerElement.classList.remove('hidden');
  },

  hide: function() {
    var containerElement = flashElement();
    containerElement.classList.add('hidden');
  }
};
