// Copyright (c) 2023 The Brave Authors. All rights reserved.
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this file,
// You can obtain one at https://mozilla.org/MPL/2.0/.

// Copied from old brave-ui

import styled, { css } from "styled-components";
import bg1Url from "./bg_bats.svg";
import bg2Url from "./bg_hearts.svg";
import { IProps } from "./index";

interface IStyleProps {
  padding?: boolean;
  bg?: string;
  isMobile?: boolean;
}

const getTextStyle = (isMobile?: boolean) => {
  if (!isMobile) {
    return css`
      flex-grow: 1;
      flex-shrink: 1;
      flex-basis: calc(100% - 217px);
    `;
  }

  return css`
    display: block;
    margin-top: -60px;
  `;
};

const getDonationStyle = (isMobile?: boolean) => {
  if (!isMobile) {
    return null;
  }

  return css`
    width: 100%;
    bottom: 0;
    left: 0;
    height: 237px;
    position: fixed;
    box-shadow: 0 -2px 8px 0 rgba(12, 13, 33, 0.35);
  `;
};

export const StyledWrapper = styled("div")<IStyleProps>`
  overflow-y: scroll;
  height: ${(p) => (p.isMobile ? "calc(100% - 237px)" : "auto")};
  padding: ${(p) => (p.isMobile ? "10px 15" : 0)}px;
  font-family: Poppins, sans-serif;
`;

export const StyledContentWrapper = styled("div")<IStyleProps>`
  display: ${(p) => (p.isMobile ? "block" : "flex")};
  justify-content: space-between;
  align-items: stretch;
  align-content: flex-start;
  flex-wrap: nowrap;
  max-width: 1320px;
  margin: 0 auto;
`;

export const StyledContent = styled("div")`
  flex-grow: 1;
  flex-shrink: 1;
  flex-basis: calc(100% - 336px);
  background: #e9f0ff;
  display: flex;
  flex-wrap: wrap;
  align-items: flex-start;
  align-content: space-between;
`;

export const StyledDonation = styled("div")<IStyleProps>`
  flex-basis: 336px;
  background: #696fdc;
  justify-content: space-between;
  display: flex;
  flex-direction: column;
  ${(p) => getDonationStyle(p.isMobile)}
`;

export const StyledBanner = styled("div")<IStyleProps>`
  position: relative;
  min-width: ${(p) => (p.isMobile ? "unset" : "900px")};
  background: #dbe3f3;
`;

export const StyledBannerImage = styled("div")<Partial<IProps>>`
  font-size: ${(p) => (!p.bgImage ? "38px" : 0)};
  font-weight: 600;
  line-height: 0.74;
  color: #d1d1db;
  height: 176px;
  background: ${(p) =>
    p.bgImage
      ? `url(${p.bgImage}) no-repeat top center / cover`
      : `url(${bg1Url}) no-repeat top left, url(${bg2Url}) no-repeat top right, #9e9fab`};
`;

export const StyledClose = styled("button")`
  top: 16px;
  right: 16px;
  position: absolute;
  background: none;
  border: none;
  padding: 0;
  cursor: pointer;
  width: 24px;
  height: 24px;
  color: #fff;
  filter: drop-shadow(0px 0px 2px rgba(0, 0, 0, 0.4));
`;

export const StyledLogoWrapper = styled("div")<IStyleProps>`
  padding-left: ${(p) => (p.isMobile ? 20 : 45)}px;
  flex-basis: 217px;
`;

export const StyledLogoText = styled("div")<IStyleProps>`
  background: inherit;
  -webkit-background-clip: text;
  color: transparent;
  filter: invert(1) grayscale(1) contrast(9);
  font-size: ${(p) => (p.isMobile ? 50 : 80)}px;
  font-weight: 600;
  text-align: center;
  letter-spacing: 0;
  line-height: 1;
  text-transform: uppercase;
  user-select: none;
  margin-top: ${(p) => (p.isMobile ? -15 : 0)}px;
`;

export const StyledLogoBorder = styled("div")<IStyleProps>`
  border: 6px solid #fff;
  border-radius: 50%;
  width: ${(p) => (p.isMobile ? 100 : 160)}px;
  height: ${(p) => (p.isMobile ? 100 : 160)}px;
  background: ${(p) => p.bg || "#DE4D26"};
  padding-top: ${(p) => (p.padding ? "35px" : 0)};
  margin: -66px 0 25px;
  overflow: hidden;
`;

export const StyledTextWrapper = styled("div")<IStyleProps>`
  ${(p) => getTextStyle(p.isMobile)}
`;

export const StyledTitle = styled("div")<IStyleProps>`
  font-size: 28px;
  font-weight: 600;
  line-height: 1;
  color: #4b4c5c;
  margin: ${(p) => (p.isMobile ? 25 : 10)}px 0 0;
  padding-left: ${(p) => (p.isMobile ? 25 : 0)}px;
`;

export const StyledText = styled("div")<IStyleProps>`
  font-family: Muli, sans-serif;
  font-size: 16px;
  line-height: 1.5;
  color: #686978;
  padding-right: 37px;
  padding-left: ${(p) => (p.isMobile ? 25 : 0)}px;
`;

export const StyledWallet = styled("div")<IStyleProps>`
  font-size: 12px;
  color: #afb2f1;
  text-align: right;
  margin: ${(p) => (p.isMobile ? 20 : 8)}px 0 10px;
  padding: 0 ${(p) => (p.isMobile ? 20 : 19)}px 0 55px;
`;

export const StyledTokens = styled("span")`
  color: #fff;
`;

export const StyledOption = styled("span")`
  color: rgba(255, 255, 255, 0.65);
`;

export const StyledCenter = styled("div")`
  max-width: 1024px;
  padding: 126px 0 0 238px;
  margin: 0 auto;
  user-select: none;
`;

export const StyledSocialItem = styled("a")`
  font-size: 12px;
  line-height: 2.5;
  letter-spacing: 0.2px;
  color: #9e9fab;
  text-decoration: none;
  display: inline-block;
  margin: 0 8px;
`;

export const StyledSocialIcon = styled("span")`
  vertical-align: middle;
  display: inline-block;
  margin-right: 5px;
  width: 22px;
  height: 22px;
`;

export const StyledSocialWrapper = styled("div")<IStyleProps>`
  text-align: right;
  padding-right: ${(p) => (p.isMobile ? 0 : 40)}px;
  margin-top: ${(p) => (p.isMobile ? 5 : 15)}px;
`;

export const StyledEmptyBox = styled("div")`
  width: 100%;
  height: 39px;
`;

export const StyledLogoImage = styled("div")<IStyleProps>`
  width: 148px;
  height: 148px;
  background: url(${(p) => p.bg}) no-repeat;
  background-size: cover;
`;

export const StyledCheckbox = styled("div")<IStyleProps>`
  width: ${(p) => (p.isMobile ? 232 : 180)}px;
  padding-left: ${(p) => (p.isMobile ? 40 : 0)}px;
  margin: ${(p) => (p.isMobile ? "15px auto 5px auto" : "15px 0 5px")};
`;
export const StyledNoticeWrapper = styled("div")`
  background: #fff;
  border: 1px solid rgba(155, 157, 192, 0);
  border-radius: 4px;
  width: 90%;
  margin: 10px 0 18px;
  padding: 7px 15px;
  display: flex;
`;
export const StyledNoticeIcon = styled("div")`
  width: 39px;
  height: 39px;
  color: #00aeff;
  margin: -2px 6px 0 0;
`;
export const StyledNoticeText = styled("div")`
  flex: 1;
  color: #67667d;
  font-size: 12px;
  font-family: ${(p) => p.theme.fontFamily.body};
  letter-spacing: 0;
  line-height: 18px;
`;
export const StyledNoticeLink = styled("a")`
  color: #0095ff;
  font-family: ${(p) => p.theme.fontFamily.body};
  font-weight: bold;
  display: inline-block;
  text-decoration: none;
  margin-left: 4px;
`;
