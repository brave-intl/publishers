import * as React from "react";

import Card from "../../../../../components/card/Card";
import { H1, H2, H4 } from "../../../../../components/text/Text";
import { Stat } from "./ReferralsHeaderStyle";

export default class ReferralsHeader extends React.Component<{}, {}> {
  constructor(props) {
    super(props);
  }

  public render() {
    return (
      <Card>
        <div>
          <div style={{ display: "flex", justifyContent: "space-between" }}>
            <Stat>
              <H4>DOWNLOADS</H4>
              <H1>{this.props.downloads}</H1>
            </Stat>
            <Stat>
              <H4>INSTALLS</H4>
              <H1>{this.props.installs}</H1>
            </Stat>
            <Stat>
              <H4>CONFIRMATIONS</H4>
              <H1>{this.props.confirmations}</H1>
            </Stat>
          </div>
        </div>
      </Card>
    );
  }
}
