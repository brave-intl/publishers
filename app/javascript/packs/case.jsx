import React from "react";
import * as ReactDOM from "react-dom";

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

document.addEventListener("DOMContentLoaded", () => {
  const element = document.querySelector("#fileUploadSection");
  ReactDOM.render(<FileUpload />, element);
});

console.log("please no 404");
