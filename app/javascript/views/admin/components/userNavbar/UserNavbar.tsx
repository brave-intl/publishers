import * as React from "react";

import Card from "../../../../components/card/Card";
import BottomNav from "./components/BottomNav/BottomNav";
import TopNav from "./components/TopNav/TopNav";
import {} from "./UserNavbarStyle";

interface IUserNavbarProps {
  publisher: IPublisherNavProps;
  navbarSelection: string;
}

interface IPublisherNavProps {
  name: string;
  avatar: string;
  status: string;
  id: string;
}

export enum NavbarSelection {
  Dashboard = "Dashboard",
  Channels = "Channels",
  Referrals = "Referrals",
  Payments = "Payments"
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
          name={this.props.publisher.name}
          status={this.props.publisher.status}
          avatar={this.props.publisher.avatar}
          userID={this.props.publisher.id}
        />
        <BottomNav />
      </div>
    );
  }
}
