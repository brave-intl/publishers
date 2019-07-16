import React from "react";
import * as ReactDOM from "react-dom";

export default class CaseReply extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      filterText: "",
      isVisible: false
    };
  }

  setText = e => {
    this.setState({ filterText: e.target.value });
  };

  getReplies = () => {
    if (this.state.filterText === "") {
      return this.props.replies;
    }

    return this.props.replies.filter(reply => {
      let query = this.state.filterText.toLowerCase();
      let title = reply.title.toLowerCase();
      let body = reply.body.toLowerCase();

      return title.includes(query) || body.includes(query);
    });
  };

  renderDropdown = () => {
    this.setState(prevState => ({
      isVisible: !prevState.isVisible
    }));
  };

  clickReply = body => {
    const textarea = document.getElementsByName("case_note[note]")[0];

    textarea.value += body + "\n";

    this.setState({ isVisible: false });
  };

  render() {
    const button = (
      <div className="btn btn-light ml-2 mb-2" onClick={this.renderDropdown}>
        <i className="fa fa-comment-o" />
        <i
          className="small ml-0 mr-2 fa fa-caret-down"
          style={{ top: "5px", position: "relative" }}
        />
        Saved replies
      </div>
    );
    let replies = (
      <div className="text-muted">
        <i className="fa fa-frown-o mx-2" />
        <span>No replies</span>
      </div>
    );

    const savedReplies = this.getReplies();
    if (savedReplies.length > 0) {
      replies = savedReplies.map(reply => (
        <div
          className="reply p-2 rounded"
          key={reply.id}
          onClick={() => this.clickReply(reply.body)}
        >
          <div className="font-weight-bold text-dark text-truncate">
            {reply.title}
          </div>
          <div className="text-muted text-truncate">{reply.body}</div>
        </div>
      ));
    }

    return (
      <div>
        {button}
        {this.state.isVisible && (
          <div
            className="p-2 border rounded bg-white"
            style={{ width: "500px" }}
          >
            <strong className="p-1">Select a reply</strong>
            <div className="my-1 py-2 border-top">
              <input
                type="text"
                autoFocus
                placeholder="Filter replies..."
                className="border rounded-pill px-3 py-1 w-100"
                style={{ outline: "none" }}
                value={this.state.filterText}
                onChange={this.setText}
              />
            </div>
            <div style={{ maxHeight: "200px", overflow: "auto" }}>
              {replies}
            </div>
          </div>
        )}
      </div>
    );
  }
}

document.addEventListener("DOMContentLoaded", () => {
  const element = document.querySelector("#replySection");
  const replies = JSON.parse(element.dataset.replies);
  ReactDOM.render(<CaseReply replies={replies} />, element);
});
