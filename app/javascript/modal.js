/*
 * Implement a simple confirm/deny modal system on top of the `modal-`
 * classes. This relies on the .js-shared-modal div in the application
 * layout.
 *
 * To use this system you'll need a template and a trigger. For example:
 *
 * ```html
 * <script type="text/html" id="my-template">
 *   <h3>This headline appears in a modal!</h3>
 * </script>
 * <a href="/some-destination" data-js-confirm-with-modal="my-template">
 *   Visit /some-destination, but first confirm
 * </a>
 * ```
 *
 * When the trigger is clicked the value of `data-js-confirm-with-modal` is
 * used to find a template. That template is rendered in the modal popup.
 * Any default behavior or other click event handlers on the trigger do
 * not fire. This means you can use the confirmable trigger not only with
 * plain href links, but also with Rails deletion links.
 *
 * Add handlers with the classes `js-confirm` and `js-deny` to allow the
 * user to accept or reject a proposed action. Popups always have a close
 * button on the top right which is equivilent to `js-deny`.
 *
 * For example, this modal offer the user the chance to confirm a disable
 * action:
 *
 * ```slim
 * = link_to \
 *     "Disable Wobble",
 *     wobble_path,
 *     method: :delete,
 *     data: { "js-confirm-with-modal": "disable-wobble" }
 * script#disable-wobble type="text/html"
 *   h4 Disable Wobble?
 *   p Are you sure?
 *   .modal-buttons
 *     = link_to "Do Not Disable", "#", class: "btn js-deny"
 *     = link_to "Disable it for now", "#", class: "btn js-confirm"
 * ```
 *
 * Using string interpolation in the template `id` field can be useful when
 * a list of confirmations must be created. For exmaple:
 *
 * ```slim
 * - @widgets.each do |widget|
 *   = link_to \
 *       "Delete Widget #{widget.name}",
 *       widget_path(widget),
 *       method: :delete,
 *       data: { "js-confirm-with-modal": "delete-widget-#{widget.id}" }
 *   script id="delete-widget-#{widget.id} type="text/html"
 *     h4 = "Delete Widget #{widget.name}?"
 *     p Are you sure?
 *     .modal-buttons
 *       = link_to "No", "#", class: "btn js-deny"
 *       = link_to "Yes", "#", class: "btn js-confirm"
 * ```
 *
 * Additionally, the identifier for the modal template will be added to the
 * `.modal-container` element of the modal with a prefix. For example:
 *
 * ```slim
 * = link_to \
 *     "Disable Wobble",
 *     wobble_path,
 *     method: :delete,
 *     data: { "js-confirm-with-modal": "disable-wobble" }
 * ```
 *
 * Would open the modal inside an element:
 *
 * ```slim
 * .modal-container.modal-container--modal-identifier--disable-wobble
 * ```
 *
 */

var MODAL_SHOW_CLASS = "modal-show";

/*
 * On demand open a modal.
 */
self.openModal = function openModal(
  html,
  confirmCallback,
  denyCallback,
  identifier
) {
  var modalElement = document.querySelector(".js-shared-modal");
  var contentElement = modalElement.querySelector(".modal-panel--content");
  var containerElement = modalElement.querySelector(".modal-container");

  contentElement.innerHTML = html;

  let identifierClass =
    identifier && `modal-container--modal-identifier--${identifier}`;
  if (identifierClass) {
    containerElement.classList.add(identifierClass);
    containerElement.classList.add(MODAL_SHOW_CLASS);
  } else {
    containerElement.classList.add(MODAL_SHOW_CLASS);
  }

  function closeModal(event) {
    modalElement.removeEventListener("click", confirmationEventDelegate);
    contentElement.innerHTML = "";
    if (identifierClass) {
      containerElement.classList.remove(identifierClass);
    }
    containerElement.classList.remove(MODAL_SHOW_CLASS);

    if (event) {
      event.preventDefault();
    }
  }

  function confirmationEventDelegate(event) {
    var target = event.target;

    while (target.parentNode && target.tagName.toLowerCase() !== "a") {
      target = target.parentNode;
    }

    if (target === document) {
      return;
    }

    if (target.classList.contains("js-confirm")) {
      closeModal(event);
      confirmCallback();
    } else if (target.classList.contains("js-deny")) {
      closeModal(event);
      if (denyCallback) {
        denyCallback();
      }
    }
  }

  function keyupDelegate(event) {
    if (event.keyCode === 27) {
      closeModal(event);
    }
  }

  // Always attempt to remove the listener, ensuring that two
  // calls to openModal don't create duplicate listeners.
  modalElement.removeEventListener("click", confirmationEventDelegate);
  modalElement.addEventListener("click", confirmationEventDelegate);

  document.removeEventListener("keyup", keyupDelegate);
  document.addEventListener("keyup", keyupDelegate);

  return closeModal;
};

/*
 * Open a modal based on the template specified by the confirmed link
 */
function confirmWithModal(confirmableLink) {
  let identifier = confirmableLink.getAttribute("data-js-confirm-with-modal");
  var template = document.getElementById(identifier);

  openModal(
    template.innerHTML,
    function() {
      confirmableLink.setAttribute("data-user-verified", "");
      confirmableLink.click();
    },
    function() {
      confirmableLink.blur();
    },
    identifier
  );
}

function detectModals() {
  var confirmableLinks = document.querySelectorAll(
    "[data-js-confirm-with-modal]"
  );
  for (var i = 0; i < confirmableLinks.length; i++) {
    let confirmableLink = confirmableLinks[i];
    confirmableLink.addEventListener("click", function(event) {
      var userVerified = confirmableLink.getAttribute("data-user-verified");
      if (userVerified === null) {
        event.preventDefault();
        event.stopPropagation();
        confirmWithModal(confirmableLink);
      }
    });
  }

  var modalTemplate = document.getElementById("js-open-modal-on-load");
  if (modalTemplate) {
    openModal(
      modalTemplate.innerHTML,
      function() {},
      function() {
        modalTemplate.parentNode.removeChild(modalTemplate);
      }
    );
  }
}


/*
 * Setup the DOM event listeners on links requesting confirmation.
 */
document.addEventListener("DOMContentLoaded", detectModals);

if (!window.detectModals) {
  window.detectModals = detectModals
};
