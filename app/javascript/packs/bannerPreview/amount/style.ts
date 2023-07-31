// Copyright (c) 2023 The Brave Authors. All rights reserved.
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this file,
// You can obtain one at https://mozilla.org/MPL/2.0/.

// Copied from old brave-ui

import styled from "styled-components";
import { IProps } from "./index";

export const StyledWrapper = styled("button")<Partial<IProps>>`
  user-select: none;
  font-family: Poppins, sans-serif;
  border: none;
  background: none;
  padding: 0;
  cursor: pointer;
  display: ${(p) => (p.isMobile ? "block" : "flex")};
  align-items: center;
  margin: ${(p) => (p.isMobile ? "0 auto 8px auto" : "0 0 8px 0")};
`;

export const StyledAmount = styled("div")<Partial<IProps>>`
  opacity: 1;
  border-radius: 20px;
  color: #fff;
  border: 1px solid rgba(255, 255, 255, 0.35);
  background: ${(p) =>
    p.selected ? "rgba(255, 255, 255, 0.35)" : "transparent"};
  vertical-align: baseline;
  padding: ${(p) => (p.type === "big" ? "0 16px" : "0 12px")};
  min-height: ${(p) => (p.type === "big" ? 40 : 32)}px;
  min-width: ${(p) =>
    p.isMobile ? "100px" : p.type === "big" ? "118px" : "82px"};
  font-size: 13px;
  font-weight: 600;
  margin-right: ${(p) => (p.isMobile ? 0 : 12)}px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: ${(p) => (p.isMobile ? 5 : 0)}px;
`;

export const StyledTokens = styled("div")`
  font-weight: 400;
  margin-left: 5px;
`;

export const StyledNumber = styled.span`
  font-weight: 400;
`;

export const StyledLogo = styled("div")<Partial<IProps>>`
  margin-right: 6px;
  width: ${(p) => (p.isMobile ? 20 : 23)}px;
`;

export const StyledConverted = styled("div")<Partial<IProps>>`
  vertical-align: baseline;
  opacity: ${(p) => (p.selected ? 1 : 0.4)};
  font-size: ${(p) => (p.type === "big" ? "12px" : "10px")};
  color: #ffffff;
  display: ${(p) => (p.isMobile ? "block" : "inline-block")};
  font-weight: 500;
`;
