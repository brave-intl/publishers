import Rails from "rails-ujs";

function selected(e) {
  console.log(
    "Original event that triggered text replacement:",
    e.detail.event
  );
  console.log("Matched item:", e.detail.item);

  const form = event.target.closest("form");
  Rails.fire(form, "submit");

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
});
