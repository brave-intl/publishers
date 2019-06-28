import React from "react";
import * as ReactDOM from "react-dom";
import Rails from "rails-ujs";

export default class FileUpload extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      filesToUpload: []
    };
  }

  onChange = event => {
    const file = event.target.files[0];
    if (!file) return;

    this.setState({
      filesToUpload: [...this.state.filesToUpload, file]
    });

    console.log(event);
  };

  render() {
    const files = this.state.filesToUpload.map(f => (
      <div key={f.name}>
        <input type="file" value={f} readOnly className="d-none" />
        {f.type.match("image.*") && (
          <img src={URL.createObjectURL(f)} width="60" height="60" />
        )}

        {f.name}
      </div>
    ));

    return (
      <div>
        <input type="file" onChange={this.onChange} />
        {files.length > 0 && (
          <div>
            <strong>Uploaded</strong>
            {files}
          </div>
        )}
      </div>
    );
  }
}

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

document.body.addEventListener("ajax:before", function(event) {
  document.getElementById("saving").classList.toggle("d-none");
});

async function autoSave() {
  Rails.fire(form, "submit");
}
document.addEventListener("DOMContentLoaded", () => {
  // Auto save the form every 90 seconds
  setInterval(autoSave, 90000);
  const element = document.querySelector("#fileUploadSection");
  ReactDOM.render(<FileUpload />, element);
});
