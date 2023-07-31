// Copyright (c) 2023 The Brave Authors. All rights reserved.
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this file,
// You can obtain one at https://mozilla.org/MPL/2.0/.

// Copied from old brave-ui

import { BatColorIcon } from "brave-ui/components/icons";
import { getLocale } from "brave-ui/helpers";
import * as React from "react";
import {
  StyledAmount,
  StyledConverted,
  StyledLogo,
  StyledNumber,
  StyledTokens,
  StyledWrapper,
} from "./style";

export interface IProps {
  amount: string;
  converted: string;
  onSelect: (amount: string) => void;
  id?: string;
  selected?: boolean;
  type?: "big" | "small";
  currency?: string;
  isMobile?: boolean;
}

export default class Amount extends React.PureComponent<IProps, {}> {
  public static defaultProps = {
    converted: 0,
    currency: "USD",
    type: "small",
  };

  public getAboutText = (isMobile?: boolean) => {
    return isMobile ? "" : getLocale("about");
  };

  public render() {
    const {
      id,
      onSelect,
      amount,
      selected,
      type,
      converted,
      currency,
      isMobile,
    } = this.props;

    return (
      <StyledWrapper
        id={id}
        onClick={onSelect.bind(this, amount)}
        isMobile={isMobile}
      >
        <StyledAmount selected={selected} type={type} isMobile={isMobile}>
          <StyledLogo isMobile={isMobile}>
            <BatColorIcon />
          </StyledLogo>
          <StyledNumber>{amount}</StyledNumber>{" "}
          <StyledTokens>{type === "big" ? "BAT" : null}</StyledTokens>
        </StyledAmount>
        <StyledConverted selected={selected} type={type} isMobile={isMobile}>
          {this.getAboutText(isMobile)} {converted} {currency}
        </StyledConverted>
      </StyledWrapper>
    );
  }
}
