import * as React from "react"

import { Box, ContentWrapper, Text, TextWrapper, Wrapper } from "./style"

import locale from "../../../locale/en"

export default class ReferralsHeader extends React.Component {
  public render() {
    return (
      <Wrapper>
        <ContentWrapper box>
          <Box>
            <Text box>January 2019</Text>
          </Box>
        </ContentWrapper>
        <ContentWrapper>
          <TextWrapper>
            <Text header>{locale.campaigns}</Text>
            <Text stat>9</Text>
          </TextWrapper>
          <TextWrapper>
            <Text header>{locale.referralCodes}</Text>
            <Text stat blue>
              499
            </Text>
          </TextWrapper>
          <TextWrapper>
            <Text header>{locale.downloads}</Text>
            <Text stat>9999</Text>
          </TextWrapper>
          <TextWrapper>
            <Text header>{locale.installs}</Text>
            <Text stat>999</Text>
          </TextWrapper>
          <TextWrapper>
            <Text header>{locale.thirtyDay}</Text>
            <Text stat purple>
              999
            </Text>
          </TextWrapper>
          <TextWrapper>
            <Text header>{locale.thirtyDay}</Text>
            <TextWrapper earnings>
              <Text stat purple>
                999
              </Text>
              <Text bat purple>
                {locale.bat}
              </Text>
            </TextWrapper>
          </TextWrapper>
        </ContentWrapper>
      </Wrapper>
    )
  }
}
