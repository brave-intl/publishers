import * as React from "react";
import { FormattedMessage } from "react-intl";

export default class ErrorBoundary extends React.Component<any, any> {
  public static getDerivedStateFromError(error) {
    // Update state so the next render will show the fallback UI.
    return { hasError: true };
  }

  constructor(props) {
    super(props);
    this.state = { hasError: false };
  }

  public render() {
    if (this.state.hasError) {
      // You can render any custom fallback UI
      return (
        <strong>
          <FormattedMessage id="common.unexpectedError" />
        </strong>
      );
    }

    return this.props.children;
  }
}
