let ellipsisIntervals = {};
let tempId = 0;

export default {
  start: function(elementOrId, durationBetween, maxEllipsis) {
    var elementId;
    var element;
    var text;
    var count = 0;
    var max = maxEllipsis || 5;
    var duration = durationBetween || 200;

    if (typeof elementOrId === 'string') {
      elementId = elementOrId;
      element = document.getElementById(elementId);
    } else {
      element = elementOrId;
      if (element.id) {
        elementId = element.id;
      } else {
        elementId = element.id = 'temp-' + tempId++;
      }
    }

    text = element.innerText;

    ellipsisIntervals[elementId] = setInterval(function() {
      var displayText = text;
      count++;
      if (count > max) count = 0;
      for (let i = 0; i < count; i++) displayText += '.';
      element.innerText = displayText;
    }, duration);
  },

  stop: function(elementOrId) {
    var elementId = typeof elementOrId === 'string' ? elementOrId : elementOrId.id;
    clearInterval(ellipsisIntervals[elementId]);
  }
};
