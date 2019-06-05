import * as React from "react";
import * as ReactDOM from "react-dom";

class Duplicates extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      count: 0
    };
  }

  componentDidMount() {
    const _this = this;

    fetch("/admin/channels/duplicates", {
      headers: {
        Accept: "application/json",
        "X-CSRF-Token": document.head
          .querySelector("[name=csrf-token]")
          .getAttribute("content"),
        "X-Requested-With": "XMLHttpRequest"
      },
      method: "GET"
    })
      .then(function(response) {
        return response.json();
      })
      .then(function(myJson) {
        _this.setState({ count: myJson.length });
      })
      .catch(error => console.error(error));
  }

  render() {
    return (
      <React.Fragment>
        {this.state.count > 0 && (
          <div className="alert mb-2 alert-warning">
            <i className="fa fa-exclamation-circle mr-2" />
            There are{" "}
            <a href="/admin/channels/duplicates">
              {this.state.count} duplicate channel(s).
            </a>{" "}
            This could impact payout.
          </div>
        )}
      </React.Fragment>
    );
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
