import * as React from "react";

import { Container, Grid, Wrapper } from "./ReferralsStyle";

import { Navbar, NavbarSelection } from "../../components/navbar/Navbar";
import ReferralsCard from "./referralsCard/ReferralsCard";
import ReferralsHeader from "./referralsHeader/ReferralsHeader";
import ReferralsNav from "./referralsNav/ReferralsNav";

export interface ICampaign {
  promo_campaign_id: string;
  created_at: string;
  name: string;
  promo_registrations: IPromoRegistration[];
}

interface IPromoRegistration {
  id: string;
  created_at: string;
  referral_code: string;
  stats: any;
}

interface IReferralsProps {
  campaigns: ICampaign[];
}

interface IReferralsState {
  campaigns: ICampaign[];
}

export default class Referrals extends React.Component<
  IReferralsProps,
  IReferralsState
> {
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
        <Navbar navbarSelection={NavbarSelection.Referrals} />
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
    <div key={index}>
      <ReferralsCard campaign={campaign} />
    </div>
  ));
  return <Grid>{referralsCardMap}</Grid>;
}
