import * as React from "react";
import * as ReactDOM from "react-dom";

class Duplicates extends React.Component {
  constructor(props) {
    super(props);
  }

  componentDidMount() {}

  render() {
    return <div className="alert w-100 alert-warning">Loading</div>;
  }
}

document.addEventListener("DOMContentLoaded", () => {
  ReactDOM.render(
    <Duplicates />,
    document
      .getElementById("duplicates")
      .appendChild(document.createElement("div"))
  );
});
