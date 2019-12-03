import * as React from "react";

/**
 * Component that alerts if you click outside of it
 */

interface IOutsideAlerterProps {
  onOutsideClick: () => void;
  outsideAlerterStyle: any;
}

export default class OutsideAlerter extends React.Component<
  IOutsideAlerterProps
> {
  public wrapperRef;

  constructor(props) {
    super(props);
    this.state = {
      wrapperRef: null
    };

    this.setWrapperRef = this.setWrapperRef.bind(this);
    this.handleClickOutside = this.handleClickOutside.bind(this);
  }

  public componentDidMount() {
    document.addEventListener("mousedown", this.handleClickOutside);
  }

  public componentWillUnmount() {
    document.removeEventListener("mousedown", this.handleClickOutside);
  }

  public setWrapperRef(node) {
    this.wrapperRef = node;
  }

  public handleClickOutside(event) {
    if (this.wrapperRef && !this.wrapperRef.contains(event.target)) {
      this.props.onOutsideClick();
    }
  }

  public render() {
    return (
      <span style={this.props.outsideAlerterStyle} ref={this.setWrapperRef}>
        {this.props.children}
      </span>
    );
  }
}
