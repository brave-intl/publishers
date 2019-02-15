import * as React from "react";

import {
  Wrapper,
  Grid,
  Row,
  IconWrapper,
  TextWrapper,
  ContentWrapper,
  Text
} from "./ReferralsCardStyle";

import { CheckCircleIcon, CaratRightIcon } from "brave-ui/components/icons";

import locale from "../../../locale/en";

interface IReferralsCardProps {
  campaign: any;
  changeMode: any;
  index: any;
}

export default class ReferralsCard extends React.Component<
  IReferralsCardProps
> {
  render() {
    return (
      <Wrapper>
        <Grid>
          <Row>
            <IconWrapper check>
              <CheckCircleIcon />
            </IconWrapper>
            <ContentWrapper>
              <TextWrapper>
                <Text>{this.props.campaign.name}</Text>
              </TextWrapper>
              <TextWrapper created>
                <Text created>{locale.created}</Text>
                <Text date>
                  {processCreatedAt(this.props.campaign.created_at)}
                </Text>
              </TextWrapper>
            </ContentWrapper>
          </Row>

          <Row stats>
            <TextWrapper stats>
              <Text header>{locale.downloads}</Text>
              <Text stat>
                {processDownloads(this.props.campaign.promo_registrations)}
              </Text>
            </TextWrapper>
            <TextWrapper stats>
              <Text header>{locale.installs}</Text>
              <Text stat>
                {processInstalls(this.props.campaign.promo_registrations)}
              </Text>
            </TextWrapper>
            <TextWrapper stats>
              <Text header>{locale.thirtyDay}</Text>
              <Text use>
                {processThirtyDayUse(this.props.campaign.promo_registrations)}
              </Text>
            </TextWrapper>
          </Row>

          <Row total>
            <TextWrapper total>
              <Text total>{locale.totalNumber}</Text>
            </TextWrapper>
            <TextWrapper total>
              <Text codes>
                {processTotalCodes(this.props.campaign.promo_registrations)}
              </Text>
            </TextWrapper>
            <IconWrapper carat>
              <CaratRightIcon
                onClick={() => {
                  window.location.href =
                    "/partners/referrals/" +
                    this.props.campaign.promo_campaign_id;
                }}
              />
            </IconWrapper>
          </Row>
        </Grid>
      </Wrapper>
    );
  }
}

function processCreatedAt(createdAt) {
  let options = { year: "numeric", month: "long", day: "numeric" };
  let date = new Date(createdAt);
  return date.toLocaleDateString("en-US", options);
}

function processDownloads(referralCodes) {
  let downloads = 0;
  referralCodes.forEach(function(code) {
    downloads += JSON.parse(code.stats)[0].retrievals;
  });
  return downloads;
}

function processInstalls(referralCodes) {
  let installs = 0;
  referralCodes.forEach(function(code) {
    installs += JSON.parse(code.stats)[0].first_runs;
  });
  return installs;
}

function processThirtyDayUse(referralCodes) {
  let thirtyDayUse = 0;
  referralCodes.forEach(function(code) {
    thirtyDayUse += JSON.parse(code.stats)[0].finalized;
  });
  return thirtyDayUse;
}

function processTotalCodes(referralCodes) {
  return referralCodes.length;
}
