import * as React from "react";

import {
  ContentWrapper,
  Text,
  TextWrapper,
  Wrapper
} from "./ReferralsHeaderStyle";

import locale from "../../../locale/en";

interface IReferralsHeaderProps {
  campaigns: any;
}

interface IReferralsHeaderState {
  stats: any;
}

export default class ReferralsHeader extends React.Component<
  IReferralsHeaderProps,
  IReferralsHeaderState
> {
  constructor(props) {
    super(props);
    this.state = {
      stats: this.processStats(this.props.campaigns)
    };
  }

  public componentDidUpdate() {
    if (
      JSON.stringify(this.state.stats) !==
      JSON.stringify(this.processStats(this.props.campaigns))
    ) {
      this.setState({ stats: this.processStats(this.props.campaigns) });
    }
  }

  public processStats(campaigns) {
    let downloads = 0;
    let installs = 0;
    let thirtyDayUse = 0;
    let total = 0;

    campaigns.forEach(campaign => {
      campaign.promo_registrations.forEach(code => {
        downloads += JSON.parse(code.stats)[0].retrievals;
        installs += JSON.parse(code.stats)[0].first_runs;
        thirtyDayUse += JSON.parse(code.stats)[0].finalized;
        total++;
      });
    });
    return { downloads, installs, thirtyDayUse, total };
  }

  public render() {
    return (
      <Wrapper>
        <ContentWrapper>
          <TextWrapper>
            <Text header>{locale.campaigns}</Text>
            <Text stat>{this.props.campaigns.length}</Text>
          </TextWrapper>
          <TextWrapper>
            <Text header>{locale.referralCodes}</Text>
            <Text stat blue>
              {this.state.stats.total}
            </Text>
          </TextWrapper>
          <TextWrapper>
            <Text header>{locale.downloads}</Text>
            <Text stat>{this.state.stats.downloads}</Text>
          </TextWrapper>
          <TextWrapper>
            <Text header>{locale.installs}</Text>
            <Text stat>{this.state.stats.installs}</Text>
          </TextWrapper>
          <TextWrapper>
            <Text header>{locale.thirtyDay}</Text>
            <Text stat purple>
              {this.state.stats.thirtyDayUse}
            </Text>
          </TextWrapper>
        </ContentWrapper>
      </Wrapper>
    );
  }
}
