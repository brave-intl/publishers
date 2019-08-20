import Rails from "@rails/ujs";

const shiftClick = () => {
  // get array of items
  var list = document.querySelector(".dynamic-table");
  var items = list.querySelectorAll(".gradeX");

  // create vars for tracking clicked items
  var firstItem, lastItem;

  // method for ticking all items between first and last
  function tick(first, last) {
    // items is a nodeList, so we do some prototype trickery
    Array.prototype.forEach.call(items, function(el, i) {
      // find each checkbox
      var checkbox = el.getElementsByTagName("input")[0];
      // tick all within first to last range
      if ((i >= first && i <= last) || (i <= first && i >= last)) {
        checkbox.checked = true;
      }
    });
  }

  // method for unticking all items except current item
  function untickAllExcept(first) {
    Array.prototype.forEach.call(items, function(el, i) {
      var cb = el.querySelectorAll("input[type='checkbox']");
      if (i !== first) {
        cb[0].checked = false;
      }
    });
  }

  // click listener on list
  list.addEventListener("click", function(e) {
    if (e.target.type === "checkbox" || e.target.nodeName === "SPAN") {
      var item = e.target.parentNode.parentNode;
      if (e.target.nodeName === "SPAN") {
        const checked = e.target.parentNode.firstChild.checked;
        e.target.parentNode.firstChild.checked = !checked;
      }

      if (e.shiftKey) {
        // store as last item clicked
        lastItem = Array.prototype.indexOf.call(items, item);
      } else {
        // store as first item clicked
        firstItem = Array.prototype.indexOf.call(items, item);
        // unset last item
        lastItem = null;
      }

      // do magic
      if (lastItem != null) {
        tick(firstItem, lastItem);
      } else {
        untickAllExcept(firstItem);
      }
    }
  });
};

function selected(e) {
  console.log(
    "Original event that triggered text replacement:",
    e.detail.event
  );
  console.log("Matched item:", e.detail.item);

  const form = event.target.closest("form");
  if (event.target.id == "tableheader") {
    const existingSearch = document.getElementsByName("q")[0].value;
    event.target.value =
      existingSearch + " assigned:" + e.detail.item.original.value;
    form.submit();
  } else {
    Rails.fire(form, "submit");
  }

  event.target.value = "";

  const assignedHTML = `<div class="text-dark">${
    e.detail.item.original.key
  }</div>`;

  assignCheckboxes(e, event.target, assignedHTML);

  const parent = event.target.closest("div");
  if (parent.id) {
    parent.classList.toggle("w-100");
    parent.closest("td").innerHTML = assignedHTML;
  }

  const search = document.getElementById("assignSearch");
  if (search) {
    search.classList.toggle("d-none");
  }
  const assigned = document.getElementById("assigned");
  if (assigned) {
    assigned.innerHTML = assignedHTML;
  }
}

function assignCheckboxes(e, target, assignedHTML) {
  const checkbox = target
    .closest("tr")
    .querySelectorAll("input[type='checkbox']");

  if (checkbox && checkbox[0].checked) {
    const inputChecked = target
      .closest("table")
      .querySelectorAll("input[type='checkbox']:checked");

    inputChecked.forEach(checked => {
      const checkedForm = checked.closest("tr").querySelector("form");

      checkedForm.querySelector(".assignee-input").value =
        e.detail.item.original.value;
      Rails.fire(checkedForm, "submit");

      let parentDiv = checkedForm.closest("div");
      if (parentDiv.id) {
        parentDiv.classList.toggle("w-100");
        parentDiv.closest("td").innerHTML = assignedHTML;
      }
    });
  }
}

function toggleForm(event) {
  const form = event.target.parentElement.parentElement.querySelector("form");
  form.classList.toggle("d-none");
  form.querySelector(".assignee-input").focus();
}

document.addEventListener("DOMContentLoaded", function() {
  document
    .querySelectorAll(".assignee-input")
    .forEach(element => element.addEventListener("tribute-replaced", selected));

  const assignee = document.getElementById("assignee");
  if (assignee) {
    assignee.onclick = function() {
      document.getElementById("assignSearch").classList.toggle("d-none");
      document.querySelector(".assignee-input").focus();
    };
  }

  shiftClick();

  document
    .querySelectorAll(".filter")
    .forEach(element => element.addEventListener("click", toggleForm));
});
