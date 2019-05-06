import * as React from "react";

import Card from "../../../../components/card/Card";
import BottomNav from "./components/BottomNav/BottomNav";
import TopNav from "./components/TopNav/TopNav";
import {} from "./UserNavbarStyle";

export default class Referrals extends React.Component<{}, {}> {
  constructor(props) {
    super(props);
    this.state = {};
  }

  public render() {
    return (
      <div>
        <TopNav />
        <BottomNav />
      </div>
    );
  }
}
