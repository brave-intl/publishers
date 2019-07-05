import Rails from "rails-ujs";

function selected(e) {
  console.log(
    "Original event that triggered text replacement:",
    e.detail.event
  );
  console.log("Matched item:", e.detail.item);

  const form = event.target.closest("form");
  if (event.target.id == "tableheader") {
    event.target.value = "assigned:" + e.detail.item.original.value;
    form.submit();
  } else {
    Rails.fire(form, "submit");
  }

  event.target.value = "";

  const assignedHTML = `<div class="text-dark">${
    e.detail.item.original.key
  }</div>`;

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

  document
    .querySelectorAll(".filter")
    .forEach(element => element.addEventListener("click", toggleForm));
});
