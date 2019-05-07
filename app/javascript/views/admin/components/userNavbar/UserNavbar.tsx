import * as React from "react";

import Card from "../../../../components/card/Card";
import BottomNav from "./components/BottomNav/BottomNav";
import TopNav from "./components/TopNav/TopNav";
import {} from "./UserNavbarStyle";

interface IUserNavbarProps {
  name: string;
  status: string;
  userID: string;
  navbarSelection: NavbarSelection;
}

export enum NavbarSelection {
  Dashboard,
  Channels,
  Referrals,
  Payments
}

export default class Referrals extends React.Component<IUserNavbarProps, {}> {
  constructor(props) {
    super(props);
    this.state = {};
  }

  public render() {
    return (
      <div>
        <TopNav
          navbarSelection={this.props.navbarSelection}
          name={this.props.name}
          status={this.props.status}
          userID={this.props.userID}
        />
        <BottomNav />
      </div>
    );
  }
}
