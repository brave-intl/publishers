(function() {

  var ellipsisIntervals = {};

  this.dynamicEllipsis = {
    start: function(elementId, durationBetween, maxEllipsis) {
      var element = document.getElementById(elementId);
      var text = element.innerText;
      var count = 0;
      var max = maxEllipsis || 5;
      var duration = durationBetween || 200;

      ellipsisIntervals[elementId] = setInterval(function() {
        var displayText = text;
        count++;
        if (count > max) count = 0;
        for (i = 0; i < count; i++) displayText += '.';
        element.innerText = displayText;
      }, duration);
    },

    stop: function(elementId) {
      clearInterval(ellipsisIntervals[elementId]);
    }
  };

}).call(window);
