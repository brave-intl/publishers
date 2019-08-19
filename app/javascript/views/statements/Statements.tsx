import * as React from "react";

import { Container, Wrapper } from "../style";

import { Navbar, NavbarSelection } from "../../components/navbar/Navbar";

import routes from "../routes";

interface IPaymentsState {
  isLoading: boolean;
}

export default class Payments extends React.Component<any, IPaymentsState> {
  public readonly state: IPaymentsState = {
    isLoading: false
  };

  constructor(props) {
    super(props);
  }

  public render() {
    return (
      <div>
        <h1>test</h1>
      </div>
    );
  }
}
