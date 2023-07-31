// Copyright (c) 2023 The Brave Authors. All rights reserved.
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this file,
// You can obtain one at https://mozilla.org/MPL/2.0/.

// Copied from old brave-ui

import * as React from "react";
import {
  StyledBanner,
  StyledBannerImage,
  StyledCenter,
  StyledCheckbox,
  StyledClose,
  StyledContent,
  StyledContentWrapper,
  StyledDonation,
  StyledEmptyBox,
  StyledLogoBorder,
  StyledLogoImage,
  StyledLogoText,
  StyledLogoWrapper,
  StyledNoticeIcon,
  StyledNoticeLink,
  StyledNoticeText,
  StyledNoticeWrapper,
  StyledOption,
  StyledSocialIcon,
  StyledSocialItem,
  StyledSocialWrapper,
  StyledText,
  StyledTextWrapper,
  StyledTitle,
  StyledTokens,
  StyledWallet,
  StyledWrapper,
} from "./style";

import Checkbox from "brave-ui/components/formControls/checkbox/index";
import {
  AlertCircleIcon,
  CloseCircleOIcon,
  TwitchColorIcon,
  TwitterColorIcon,
  YoutubeColorIcon,
} from "brave-ui/components/icons";
import { getLocale } from "brave-ui/helpers";
import Donate from "./donate/index";

export interface ISocial { type: SocialType; url: string }
export type SocialType = "twitter" | "youtube" | "twitch";
export interface IDonation {
  tokens: string;
  converted: string;
  selected?: boolean;
}

export interface IProps {
  balance: string;
  currentAmount: string;
  donationAmounts: IDonation[];
  onAmountSelection: (tokens: string) => void;
  id?: string;
  title?: string;
  name?: string;
  domain: string;
  bgImage?: string;
  logo?: string;
  social?: ISocial[];
  provider?: SocialType;
  recurringDonation?: boolean;
  children?: React.ReactNode;
  onDonate: (amount: string, monthly: boolean) => void;
  onClose?: () => void;
  isMobile?: boolean;
  logoBgColor?: string;
  showUnVerifiedNotice?: boolean;
  learnMoreNotice?: string;
  addFundsLink?: string;
}

interface IState {
  monthly: boolean;
}

export default class SiteBanner extends React.PureComponent<IProps, IState> {
  constructor(props: IProps) {
    super(props);
    this.state = {
      monthly: false,
    };
  }

  public getLogo(logo: string | undefined, domain: string, name: string | undefined) {
    let letter = (domain && domain.substring(0, 1)) || "";

    if (name) {
      letter = name.substring(0, 1);
    }

    return !logo ? (
      <StyledLogoText isMobile={this.props.isMobile}>{letter}</StyledLogoText>
    ) : (
      <StyledLogoImage bg={logo} />
    );
  }

  public getSocialData(item: ISocial) {
    let logo = null;
    switch (item.type) {
      case "twitter":
        logo = <TwitterColorIcon />;
        break;
      case "youtube":
        logo = <YoutubeColorIcon />;
        break;
      case "twitch":
        logo = <TwitchColorIcon />;
        break;
    }

    return logo;
  }

  public getSocial = (social?: ISocial[]) => {
    if (!social || social.length === 0) {
      return null;
    }

    return social.map((item: ISocial) => {
      const logo = this.getSocialData(item);
      return (
        <StyledSocialItem
          key={`${this.props.id}-social-${item.type}`}
          href={item.url}
          target={"_blank"}
        >
          <StyledSocialIcon>{logo}</StyledSocialIcon>
        </StyledSocialItem>
      );
    });
  };

  public getTitle(title?: string) {
    return title ? title : getLocale("welcome");
  }

  public getBannerTitle(name?: string, domain?: string, provider?: SocialType) {
    const identifier = name || domain;

    if (!provider) {
      return identifier;
    }

    switch (provider) {
      case "youtube":
        return `${identifier} ${getLocale("on")} YouTube`;
      case "twitter":
        return `${identifier} ${getLocale("on")} Twitter`;
      case "twitch":
        return `${identifier} ${getLocale("on")} Twitch`;
      default:
        return identifier;
    }
  }

  public getText(children?: React.ReactNode) {
    if (!children) {
      return (
        <>
          <p>{getLocale("rewardsBannerText1")}</p>
          <p>{getLocale("rewardsBannerText2")}</p>
        </>
      );
    }

    return children;
  }

  public onMonthlyChange = (key: string, selected: boolean) => {
    this.setState({ monthly: selected });
  };

  public onDonate = (amount: string) => {
    if (this.props.onDonate) {
      this.props.onDonate(amount, this.state.monthly);
    }
  };

  public onKeyUp = (e: React.KeyboardEvent<HTMLDivElement>) => {
    if (e.key.toLowerCase() === "escape" && this.props.onClose) {
      this.props.onClose();
    }
  };

  public render() {
    const {
      id,
      bgImage,
      onClose,
      logo,
      social,
      provider,
      children,
      title,
      recurringDonation,
      balance,
      donationAmounts,
      domain,
      onAmountSelection,
      logoBgColor,
      currentAmount,
      name,
      isMobile,
      showUnVerifiedNotice,
      learnMoreNotice,
      addFundsLink,
    } = this.props;

    return (
      <StyledWrapper
        id={id}
        isMobile={isMobile}
        onKeyUp={this.onKeyUp}
        tabIndex={0}
      >
        <StyledBanner isMobile={isMobile}>
          <StyledClose onClick={onClose}>
            <CloseCircleOIcon />
          </StyledClose>
          <StyledBannerImage bgImage={bgImage}>
            {!isMobile ? (
              <StyledCenter>
                {this.getBannerTitle(name, domain, provider)}
              </StyledCenter>
            ) : null}
          </StyledBannerImage>
          <StyledContentWrapper isMobile={isMobile}>
            <StyledContent>
              <StyledLogoWrapper isMobile={isMobile}>
                <StyledLogoBorder
                  isMobile={isMobile}
                  padding={!logo}
                  bg={logoBgColor}
                >
                  {this.getLogo(logo, domain, name)}
                </StyledLogoBorder>
              </StyledLogoWrapper>
              <StyledTextWrapper isMobile={isMobile}>
                <StyledSocialWrapper isMobile={isMobile}>
                  {this.getSocial(social)}
                </StyledSocialWrapper>
                {showUnVerifiedNotice ? (
                  <StyledNoticeWrapper>
                    <StyledNoticeIcon>
                      <AlertCircleIcon />
                    </StyledNoticeIcon>
                    <StyledNoticeText>
                      <b>{getLocale("siteBannerNoticeNote")}</b>{" "}
                      {getLocale("siteBannerNoticeText")}
                      <StyledNoticeLink
                        href={learnMoreNotice}
                        target={"_blank"}
                      >
                        {getLocale("unVerifiedTextMore")}
                      </StyledNoticeLink>
                    </StyledNoticeText>
                  </StyledNoticeWrapper>
                ) : null}
                <StyledTitle isMobile={isMobile}>
                  {this.getTitle(title)}
                </StyledTitle>
                <StyledText isMobile={isMobile}>
                  {this.getText(children)}
                </StyledText>
              </StyledTextWrapper>
            </StyledContent>
            <StyledDonation isMobile={isMobile}>
              <StyledWallet isMobile={isMobile}>
                {getLocale("walletBalance")}{" "}
                <StyledTokens>{balance} BAT</StyledTokens>
              </StyledWallet>
              <Donate
                isMobile={isMobile}
                balance={parseFloat(balance)}
                donationAmounts={donationAmounts}
                title={getLocale("donationAmount")}
                onDonate={this.onDonate}
                actionText={
                  this.state.monthly
                    ? getLocale("doMonthly")
                    : getLocale("sendDonation")
                }
                onAmountSelection={onAmountSelection}
                donateType={"big"}
                currentAmount={currentAmount}
                addFundsLink={addFundsLink}
              >
                {!recurringDonation ? (
                  <StyledCheckbox isMobile={isMobile}>
                    <Checkbox
                      testId={"monthlyCheckbox"}
                      value={{ make: this.state.monthly }}
                      onChange={this.onMonthlyChange}
                      type={"dark"}
                    >
                      <div data-key="make">
                        <StyledOption>{getLocale("makeMonthly")}</StyledOption>
                      </div>
                    </Checkbox>
                  </StyledCheckbox>
                ) : (
                  <StyledEmptyBox />
                )}
              </Donate>
            </StyledDonation>
          </StyledContentWrapper>
        </StyledBanner>
      </StyledWrapper>
    );
  }
}
