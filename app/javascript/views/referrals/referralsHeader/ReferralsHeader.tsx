import * as React from "react";

import {
  Box,
  ContentWrapper,
  Text,
  TextWrapper,
  Wrapper
} from "./ReferralsHeaderStyle";

import locale from "../../../locale/en";

interface IReferralsHeaderProps {
  unassignedCodes: any;
  campaigns: any;
}

export default class ReferralsHeader extends React.Component<
  IReferralsHeaderProps
> {
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
              {countReferralCodes(
                this.props.campaigns,
                this.props.unassignedCodes
              )}
            </Text>
          </TextWrapper>
          <TextWrapper>
            <Text header>{locale.downloads}</Text>
            <Text stat>
              {countDownloads(this.props.campaigns, this.props.unassignedCodes)}
            </Text>
          </TextWrapper>
          <TextWrapper>
            <Text header>{locale.installs}</Text>
            <Text stat>
              {countInstalls(this.props.campaigns, this.props.unassignedCodes)}
            </Text>
          </TextWrapper>
          <TextWrapper>
            <Text header>{locale.thirtyDay}</Text>
            <Text stat purple>
              {countThirtyDayUse(
                this.props.campaigns,
                this.props.unassignedCodes
              )}
            </Text>
          </TextWrapper>
        </ContentWrapper>
      </Wrapper>
    );
  }
}

function countReferralCodes(campaigns, unassignedCodes) {
  let referralCodes = 0;
  campaigns.forEach(campaign => {
    campaign.promo_registrations.forEach(referralCode => {
      referralCodes++;
    });
  });
  return referralCodes;
}

function countDownloads(campaigns, unassignedCodes) {
  let downloads = 0;
  campaigns.forEach(campaign => {
    campaign.promo_registrations.forEach(referralCode => {
      downloads += JSON.parse(referralCode.stats)[0].retrievals;
    });
  });
  return downloads;
}

function countInstalls(campaigns, unassignedCodes) {
  let installs = 0;
  campaigns.forEach(campaign => {
    campaign.promo_registrations.forEach(referralCode => {
      installs += JSON.parse(referralCode.stats)[0].first_runs;
    });
  });
  return installs;
}

function countThirtyDayUse(campaigns, unassignedCodes) {
  let thirtyDay = 0;
  campaigns.forEach(campaign => {
    campaign.promo_registrations.forEach(referralCode => {
      thirtyDay += JSON.parse(referralCode.stats)[0].finalized;
    });
  });
  return thirtyDay;
}
