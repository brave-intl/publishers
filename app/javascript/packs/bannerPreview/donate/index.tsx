// Copyright (c) 2023 The Brave Authors. All rights reserved.
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this file,
// You can obtain one at https://mozilla.org/MPL/2.0/.

// Copied from old brave-ui

import * as React from "react";
import {
  StyledAmountsWrapper,
  StyledButtonWrapper,
  StyledContent,
  StyledDonationTitle,
  StyledFunds,
  StyledFundsText,
  StyledIconFace,
  StyledIconSend,
  StyledSend,
  StyledSendButton,
  StyledWrapper,
} from "./style";

import { EmoteSadIcon, SendIcon } from "brave-ui/components/icons";
import { getLocale } from "brave-ui/helpers";
import Amount from "../amount/index";

export type DonateType = "big" | "small";

interface IDonation {
  tokens: string;
  converted: string;
}

export interface IProps {
  actionText: string;
  title: string;
  balance: number;
  donationAmounts: IDonation[];
  currentAmount: string;
  onDonate: (amount: string) => void;
  onAmountSelection?: (tokens: string) => void;
  id?: string;
  donateType: DonateType;
  children?: React.ReactNode;
  isMobile?: boolean;
  addFundsLink?: string;
}

interface IState {
  missingFunds: boolean;
}

export default class Donate extends React.PureComponent<IProps, IState> {
  constructor(props: IProps) {
    super(props);
    this.state = {
      missingFunds: false,
    };
  }

  public componentDidUpdate(prevProps: IProps) {
    if (
      this.props.balance !== prevProps.balance ||
      this.props.donationAmounts !== prevProps.donationAmounts ||
      this.props.currentAmount !== prevProps.currentAmount
    ) {
      this.validateAmount(this.props.balance);
    }
  }

  public validateDonation = () => {
    if (this.validateAmount(this.props.balance)) {
      return;
    }

    if (this.props.onDonate) {
      this.props.onDonate(this.props.currentAmount);
    }
  };

  public validateAmount(balance: number, tokens?: string) {
    if (tokens === undefined) {
      tokens = this.props.currentAmount;
    }

    const valid = parseInt(tokens, 10) > balance;
    this.setState({ missingFunds: valid });
    return valid;
  }

  public onAmountChange = (tokens: string) => {
    this.validateAmount(this.props.balance, tokens);

    if (this.props.onAmountSelection) {
      this.props.onAmountSelection(tokens);
    }
  };

  public render() {
    const {
      id,
      donationAmounts,
      actionText,
      children,
      title,
      currentAmount,
      donateType,
      isMobile,
      addFundsLink,
    } = this.props;
    const disabled = parseInt(currentAmount, 10) === 0;

    return (
      <StyledWrapper
        donateType={donateType}
        disabled={disabled}
        isMobile={isMobile}
      >
        <StyledContent id={id} isMobile={isMobile}>
          <StyledDonationTitle isMobile={isMobile}>{title}</StyledDonationTitle>
          <StyledAmountsWrapper isMobile={isMobile}>
            {donationAmounts &&
              donationAmounts.map((donation: IDonation) => {
                return (
                  <div key={`${id}-donate-${donation.tokens}`}>
                    <Amount
                      isMobile={isMobile}
                      amount={donation.tokens}
                      selected={donation.tokens === currentAmount.toString()}
                      onSelect={this.onAmountChange}
                      converted={donation.converted}
                      type={donateType}
                    />
                  </div>
                );
              })}
          </StyledAmountsWrapper>
          {children}
        </StyledContent>

        <StyledSend onClick={this.validateDonation}>
          <StyledButtonWrapper isMobile={isMobile}>
            <StyledSendButton>
              <StyledIconSend disabled={disabled} donateType={donateType}>
                <SendIcon />
              </StyledIconSend>
              {actionText}
            </StyledSendButton>
          </StyledButtonWrapper>
        </StyledSend>
        {this.state.missingFunds ? (
          <StyledFunds>
            <StyledIconFace>
              <EmoteSadIcon />
            </StyledIconFace>
            <StyledFundsText>
              {getLocale("notEnoughTokens")}{" "}
              <a href={addFundsLink} target={"_blank"} rel="noopener noreferrer">
                {getLocale("addFunds")}
              </a>
              .
            </StyledFundsText>
          </StyledFunds>
        ) : null}
      </StyledWrapper>
    );
  }
}
