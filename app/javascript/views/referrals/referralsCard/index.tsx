import * as React from "react";

import {
  ContentWrapper,
  Grid,
  IconWrapper,
  Row,
  Text,
  TextWrapper,
  Wrapper
} from "./style";

import { CaratRightIcon, CheckCircleIcon } from "brave-ui/components/icons";

import locale from "../../../locale/en";

export default class ReferralsCard extends React.Component {
  public render() {
    return (
      <Wrapper>
        <Grid>
          <Row>
            <IconWrapper check>
              <CheckCircleIcon />
            </IconWrapper>
            <ContentWrapper>
              <TextWrapper>
                <Text>{locale.campaignName}</Text>
              </TextWrapper>
              <TextWrapper created>
                <Text created>{locale.created}</Text>
                <Text date>Jan 20, 2018</Text>
              </TextWrapper>
            </ContentWrapper>
          </Row>

          <Row stats>
            <TextWrapper stats>
              <Text header>{locale.downloads}</Text>
              <Text stat>99999</Text>
            </TextWrapper>
            <TextWrapper stats>
              <Text header>{locale.installs}</Text>
              <Text stat>99999</Text>
            </TextWrapper>
            <TextWrapper stats>
              <Text header>{locale.thirtyDay}</Text>
              <Text use>99999</Text>
            </TextWrapper>
          </Row>

          <Row total>
            <TextWrapper total>
              <Text total>{locale.totalNumber}</Text>
            </TextWrapper>
            <TextWrapper total>
              <Text codes>999</Text>
            </TextWrapper>
            <IconWrapper carat>
              <CaratRightIcon />
            </IconWrapper>
          </Row>
        </Grid>
      </Wrapper>
    );
  }
}
