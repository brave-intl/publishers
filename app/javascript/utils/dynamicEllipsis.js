let ellipsisIntervals = {};
let tempId = 0;

export default {
  start: function(elementOrId, durationBetween, maxEllipsis) {
    let elementId;
    let element;
    let text;
    let count = 0;
    let max = maxEllipsis || 5;
    let duration = durationBetween || 200;

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
      let displayText = text;
      count++;
      if (count > max) count = 0;
      for (let i = 0; i < count; i++) displayText += '.';
      element.innerText = displayText;
    }, duration);
  },

  stop: function(elementOrId) {
    let elementId = typeof elementOrId === 'string' ? elementOrId : elementOrId.id;
    clearInterval(ellipsisIntervals[elementId]);
  }
};
