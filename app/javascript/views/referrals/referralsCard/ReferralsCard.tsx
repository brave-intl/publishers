import * as React from "react";

import {
  FlexWrapper,
  HeaderRow,
  IconWrapper,
  Logo,
  Row,
  Text,
  TextWrapper
} from "./ReferralsCardStyle";

import Card from "../../../components/card/Card";
import { H2 } from "../../../components/text/Text";

import { CaratRightIcon, CheckCircleIcon } from "brave-ui/components/icons";

import locale from "../../../locale/en";

interface IReferralsCardProps {
  campaign: any;
}

export default class ReferralsCard extends React.Component<
  IReferralsCardProps
> {
  public render() {
    return (
      <Card>
        <FlexWrapper>
          <Logo>
            <CheckCircleIcon />
          </Logo>
          <HeaderRow>
            <H2 bold={true}>{this.props.campaign.name}</H2>
            <div>
              {locale.referrals.created}{" "}
              {formatCreatedAt(this.props.campaign.created_at)}
            </div>
          </HeaderRow>
        </FlexWrapper>

        <FlexWrapper style={{ marginTop: "16px", marginBottom: "8px" }}>
          <TextWrapper stats>
            <Text header>{locale.referrals.downloads}</Text>
            <Text stat>
              {processStats(this.props.campaign.promo_registrations).downloads}
            </Text>
          </TextWrapper>
          <TextWrapper stats>
            <Text header>{locale.referrals.installs}</Text>
            <Text stat>
              {processStats(this.props.campaign.promo_registrations).installs}
            </Text>
          </TextWrapper>
          <TextWrapper stats>
            <Text header>{locale.referrals.thirtyDay}</Text>
            <Text use>
              {
                processStats(this.props.campaign.promo_registrations)
                  .thirtyDayUse
              }
            </Text>
          </TextWrapper>
        </FlexWrapper>

        <Row total>
          <TextWrapper total>
            <Text total>{locale.referrals.totalNumber}</Text>
          </TextWrapper>
          <TextWrapper total>
            <Text codes>
              {processStats(this.props.campaign.promo_registrations).total}
            </Text>
          </TextWrapper>
          <IconWrapper carat>
            <CaratRightIcon
              onClick={redirectToReferralsInformation(
                this.props.campaign.promo_campaign_id
              )}
            />
          </IconWrapper>
        </Row>
      </Card>
    );
  }
}

function redirectToReferralsInformation(campaign) {
  return () => {
    window.location.href = "/partners/referrals/" + campaign;
  };
}

function formatCreatedAt(createdAt) {
  const options = { year: "numeric", month: "long", day: "numeric" };
  const date = new Date(createdAt);
  return date.toLocaleDateString("en-US", options);
}

function processStats(referralCodes) {
  let installs = 0;
  let downloads = 0;
  let thirtyDayUse = 0;
  const total = referralCodes.length;

  referralCodes.forEach(code => {
    downloads += JSON.parse(code.stats)[0].retrievals;
    installs += JSON.parse(code.stats)[0].first_runs;
    thirtyDayUse += JSON.parse(code.stats)[0].finalized;
  });

  return { downloads, installs, thirtyDayUse, total };
}
