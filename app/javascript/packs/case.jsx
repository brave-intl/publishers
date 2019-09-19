import React from "react";
import * as ReactDOM from "react-dom";
import Rails from "rails-ujs";

import { DirectUpload } from "@rails/activestorage";

export default class FileUpload extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      filesToUpload: [],
      progress: 0
    };
  }

  onChange = event => {
    const file = event.target.files[0];

    if (!file) return;

    const form = document.querySelector("form");
    Rails.fire(form, "submit");

    this.setState({
      filesToUpload: [...this.state.filesToUpload, file]
    });
  };

  render() {
    const files = this.state.filesToUpload.map(f => (
      <div className="m-3 c-4 shadow-sm rounded p-3" key={f.name}>
        {f.type.match("image.*") && (
          <img
            className="mr-2"
            src={URL.createObjectURL(f)}
            width="60"
            height="60"
          />
        )}

        {f.name}
      </div>
    ));

    return (
      <div>
        <input type="file" name="case[files][]" onChange={this.onChange} />
        {this.state.progress > 0 && (
          <div className="progress mt-2">
            <div
              className="progress-bar"
              role="progressbar"
              style={{ width: `${this.state.progress}%` }}
              aria-valuenow={this.state.progress}
              aria-valuemin="0"
              aria-valuemax="100"
            />
          </div>
        )}

        {files.length > 0 && <div className="row">{files}</div>}
        {this.state.error && (
          <div className="alert alert-warning">{this.state.error}</div>
        )}
      </div>
    );
  }
}

// Show the saving label before we save to show progress is being made
document.body.addEventListener("ajax:before", function(event) {
  document.getElementById("saving").classList.toggle("d-none");
});

// Let the user know when errors happen
document.body.addEventListener("ajax:error", function(event) {
  const errorMessage = document.createElement("div");
  errorMessage.classList = "mt-3 alert alert-warning";
  errorMessage.innerHTML =
    'An unknown error occurred 😳. Try refreshing the page or letting a team member know at <a href="community.brave.com">the Brave Community</a>';

  const form = document.querySelector("form");
  form.appendChild(errorMessage);
});

async function autoSave() {
  const form = document.querySelector("form");
  Rails.fire(form, "submit");
}

// Creates a hidden field for html status
const openCase = () => {
  const form = document.querySelector("form");
  const hiddenField = document.createElement("input");
  hiddenField.setAttribute("type", "hidden");
  hiddenField.setAttribute("value", "open");
  hiddenField.name = "status";
  form.appendChild(hiddenField);
  // submit form
  Rails.fire(form, "submit");

  window.location.href = "/publishers/case";
};

document.addEventListener("DOMContentLoaded", () => {
  const element = document.querySelector("#fileUploadSection");
  ReactDOM.render(<FileUpload />, element);

  // Autosave every minute
  setInterval(autoSave, 60000);

  const button = document.querySelector("#open-case");
  if (button) {
    button.onclick = openCase;
  }
});
