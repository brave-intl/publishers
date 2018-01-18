export class ErrorManager {
  constructor(errorGroupName) {
    this._errorGroupName = errorGroupName;
  }

  get _errorGroupClassName() {
    return `js-${this._errorGroupName}`;
  }

  show(errorClassName) {
    /*
     * Set class of `show` on all error objects.
     */
    let selector = `.${this._errorGroupClassName} > .js-${errorClassName}`;
    document.querySelector(selector).classList.add('show');

    /*
     * Set class of `has-error` on the group element.
     */
    document.querySelector(`.${this._errorGroupClassName}`).classList.add('error-group--wrapper--has-error');
  }

  clear() {
    /*
     * Clear the class of `show` from all error objects.
     */
    let selector = `.${this._errorGroupClassName} > div`;
    let errorElements = document.querySelectorAll(selector);
    for (let i=0;i<errorElements.length;i++) {
      errorElements[i].classList.remove('show');
    }

    /*
     * Clear the class of `has-error` from the group element.
     */
    document.querySelector(`.${this._errorGroupClassName}`).classList.remove('error-group--wrapper--has-error');
  }
}
