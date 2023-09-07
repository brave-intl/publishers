import styled from "styled-components";

import BatsBackground from "../../../assets/images/bg_bats.svg";
import HeartsBackground from "../../../assets/images/bg_hearts.svg";
import CryptoWidgetBackground from "../../../assets/images/crypto_widget_bg.png";

export const Logo = styled.div`
  border-radius: 50%;
  width: 160px;
  height: 160px;

  ${({ url }) =>
    url &&
    `
    background-size: cover;
    background-image: url(${url})
  `}

  ${({ url }) =>
    url === null &&
    `
    border: 6px solid white;
    background-color: #4C54D2;
  `}
`;

export const Cover = styled.div`
  height: 234px;
  position: absolute;
  top: 0;
  width: 100%;
  z-index: 1;

  ${({ url }) =>
    url &&
    `
    background-size: cover;
    background-image: url(${url})
  `}

  ${({ url }) =>
    url === null &&
    `
    background: url(${BatsBackground}) left bottom no-repeat, url(${HeartsBackground}) right top no-repeat, rgb(158, 159, 171);
  `}
`;

export const ImageContainer = styled.div`
  position: relative;
  min-height: 117px;
`;

export const DescriptionContainer = styled.div`
  font-family: 'Poppins-Regular', sans-serif;
  z-index: 100;
  margin-bottom: 2rem;
`;

export const CryptoPaymentContainer = styled.div`
  text-align: center;
  z-index: 100;
`;

export const CryptoWidgetWrapper = styled.div`
  background-size: cover;
  background-image: url(${CryptoWidgetBackground});
  border-radius: 12px;
  width: 520px;
  height: 542px;
  box-shadow: 0px 3px 10px -1px rgba(0, 0, 0, 0.05);
  margin: 0 auto;
`;

export const CreatorDescription = styled.div`
  margin-bottom: 2rem;
  color: #3F4855;
`;

export const CreatorTitle = styled.div`
  font-size: 2rem;
  font-weight: 500;
  margin-bottom: 2rem;
  margin-top: 2rem;
  color: #0D0F14;

    img {
      width: 22px;
      height: 22px;
    }
`;

export const PrivacyDisclaimer = styled.div`
  text-align: center;
  font-size: .8rem;
  font-family: 'Poppins-Regular', sans-serif;
  color: #3F4855;
  margin: 1rem;
`;

export const SocialLink = styled.a`
  padding-right: 20px;
    
    img {
      height: 18px;
      width: 18px;
    }
`;

