import * as React from "react";

import { Container, Grid, Wrapper } from "./ReferralsStyle";

import ReferralsCard from "./referralsCard/ReferralsCard";
import ReferralsHeader from "./referralsHeader/ReferralsHeader";
import ReferralsNav from "./referralsNav/ReferralsNav";

interface IReferralsState {
  campaigns: any;
}

export default class Referrals extends React.Component<{}, IReferralsState> {
  constructor(props) {
    super(props);
    this.state = {
      campaigns: []
    };
    this.fetchData = this.fetchData.bind(this);
  }

  public componentDidMount() {
    this.fetchData();
  }

  public async fetchData() {
    const url = "/partners/referrals/";
    const options = {
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
        "X-Requested-With": "XMLHttpRequest"
      },
      method: "GET"
    };
    const response = await fetch(url, options);
    const data = await response.json();
    this.setState({
      campaigns: data.campaigns
    });
  }

  public render() {
    return (
      <Wrapper>
        <ReferralsNav fetchData={this.fetchData} />
        <Container>
          <ReferralsHeader campaigns={this.state.campaigns} />
          <ReferralsCardMap campaigns={this.state.campaigns} />
        </Container>
      </Wrapper>
    );
  }
}

function ReferralsCardMap(props) {
  const referralsCardMap = props.campaigns.map((campaign, index) => (
    <ReferralsCard key={index} campaign={campaign} />
  ));
  return <Grid>{referralsCardMap}</Grid>;
}
