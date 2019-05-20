import * as React from "react";

import {
  BatGreyIcon,
  CheckIcon,
  LoveIcon,
  PaperAirplaneIcon,
  PaymentDueIcon,
  SettingsIcon,
  VerifiedIcon,
  WalletActivityIcon,
  WalletManageIcon
} from "brave-ui/components/icons";
import {
  Container,
  InnerContainer,
  InnerNav,
  Nav,
  NavIcon,
  NavText
} from "./BottomNavStyle";

export default class BottomNav extends React.Component<{}, {}> {
  constructor(props) {
    super(props);
    this.state = {};
  }

  public render() {
    return (
      <Container>
        <InnerContainer>
          <Nav>
            <InnerNav>
              <NavIcon>
                {" "}
                <WalletManageIcon />
              </NavIcon>
              <NavText>Overview</NavText>
            </InnerNav>
          </Nav>
          <Nav>
            <InnerNav>
              <NavIcon>
                {" "}
                <VerifiedIcon />
              </NavIcon>
              <NavText>Channels</NavText>
            </InnerNav>
          </Nav>
          <Nav>
            <InnerNav>
              <NavIcon>
                {" "}
                <CheckIcon />
              </NavIcon>
              <NavText>Referrals</NavText>
            </InnerNav>
          </Nav>
          <Nav>
            <InnerNav>
              <NavIcon>
                {" "}
                <PaymentDueIcon />
              </NavIcon>
              <NavText selected={true}>Payments</NavText>
            </InnerNav>
          </Nav>
          <Nav>
            <InnerNav>
              <NavIcon>
                {" "}
                <SettingsIcon />
              </NavIcon>
              <NavText>Settings</NavText>
            </InnerNav>
          </Nav>
        </InnerContainer>
      </Container>
    );
  }
}
