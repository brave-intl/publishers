let spinnerElements = {};
let spinnerShown = {};
let tempId = 0;

export default {
  show: function(elementOrId, parentElementOrId) {
    var elementId;
    var element;

    if (typeof elementOrId === 'string') {
      elementId = elementOrId;
    } else if (elementOrId) {
      element = elementOrId;
      if (element.id) {
        elementId = element.id;
      } else {
        elementId = element.id = 'spinner-temp-' + tempId++;
      }
    } else {
      elementId = 'cssload-container';
    }

    if (!element) {
      element = document.getElementById(elementId);
      if (!element) {
        element = document.createElement('div');
        element.id = elementId;

        const outerDiv = document.createElement('div')
        outerDiv.setAttribute('class', 'cssload-container')
        const innerDiv = document.createElement('div')
        innerDiv.setAttribute('class', 'cssload-loading')

        element.appendChild(outerDiv)
        outerDiv.appendChild(innerDiv)
        innerDiv.appendChild(document.createElement('i'))
        innerDiv.appendChild(document.createElement('i'))

        let parentElement;
        if (parentElementOrId) {
          if (typeof parentElementOrId === 'string') {
            parentElement = document.getElementById(parentElementOrId);
          } else {
            parentElement = parentElement;
          }
        } else {
          parentElement = document.body;
        }
        parentElement.appendChild(element);
      }
    }

    spinnerElements[elementId] = element;
    spinnerShown[elementId] = Date.now();

    element.style.display = 'block';
  },

  hide: function(elementOrId) {
    var elementId;

    if (typeof elementOrId === 'string') {
      elementId = elementOrId;
    } else if (elementOrId) {
      elementId = elementOrId.id;
    } else {
      elementId = 'cssload-container';
    }

    var element = spinnerElements[elementId];
    var shown = spinnerShown[elementId];

    if (shown) {
      var minTime = 500;
      var now = Date.now();

      if (now - shown > minTime) {
        element.style.display = 'none';
      } else {
        setTimeout(function() {
          element.style.display = 'none';
        }, minTime - (now - shown));
      }
    }
  }
};
