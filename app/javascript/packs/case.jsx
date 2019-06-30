import React from "react";
import * as ReactDOM from "react-dom";
import Rails from "rails-ujs";

import { DirectUpload } from "activestorage";

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

    this.uploadFile(file);
    this.setState({
      filesToUpload: [...this.state.filesToUpload, file]
    });
  };

  directUploadWillStoreFileWithXHR(request) {
    request.upload.addEventListener("progress", event =>
      this.directUploadDidProgress(event)
    );
  }

  directUploadDidProgress = event => {
    this.setState({ progress: (event.loaded / event.total) * 100 });
    // Use event.loaded and event.total to update the progress bar
  };

  uploadFile = file => {
    // your form needs the file_field direct_upload: true, which
    //  provides data-direct-upload-url
    const input = document.querySelector("input[type=file]");

    const url = input.dataset.directUploadUrl;
    const upload = new DirectUpload(file, url, this);

    upload.create((error, blob) => {
      if (error) {
        this.setState({ error: error });
        // Handle the error
      } else {
        // Add an appropriately-named hidden input to the form with a
        //  value of blob.signed_id so that the blob ids will be
        //  transmitted in the normal upload flow
        const hiddenField = document.createElement("input");
        hiddenField.setAttribute("class", "upload-blob");
        hiddenField.setAttribute("type", "hidden");
        hiddenField.setAttribute("value", blob.signed_id);
        hiddenField.name = input.name;
        const form = document.querySelector("form");
        form.appendChild(hiddenField);
        Rails.fire(form, "submit");
        // After form has submitted remove the entry
        setTimeout(() => {
          form.removeChild(hiddenField);
          this.setState({ progress: 0 });
        }, 1000);
      }
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
        <input type="file" onChange={this.onChange} />
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

  const button = document.querySelector("#open-case");
  if (button) {
    button.onclick = openCase;
  }
});
