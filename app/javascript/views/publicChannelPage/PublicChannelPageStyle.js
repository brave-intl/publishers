import styled from "styled-components";

import DefaultBg from "../../../assets/images/default_banner_bg.jpg"
import CryptoWidgetBackground from "../../../assets/images/crypto_widget_bg.png";
import CryptoWidgetSuccess from "../../../assets/images/crypto_widget_success.png";
import Exchange from "../../../assets/images/exchange.svg";

export const PublicChannelContainer = styled.div`
  font-family: 'poppins', sans-serif;
`;

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
    background-repeat: no-repeat;
    background-image: url(${url})
  `}

  ${({ url }) =>
    url === null &&
    `
    background-image: url(${DefaultBg});
    background-repeat: no-repeat;
    background-size: cover;
  `}
`;

export const ImageContainer = styled.div`
  position: relative;
  min-height: 117px;
`;

export const DescriptionContainer = styled.div`
  font-family: 'Inter', sans-serif;
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
  padding: 32px 16px;
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
  font-family: 'Inter', sans-serif;
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

export const QRTitle = styled.div`
  color: #0D0F14;
  font-weight: 500;
  font-size: 1.7rem;
  padding-bottom: 50px;
`;

export const QRSubTitle = styled.div`
  font-size: 0.9rem;
  max-width: calc(100% - 50px);
  font-family: 'Inter', sans-serif;
  font-weight: 400;
  margin-bottom: -20px;
`;

export const QRText = styled.div`
  font-size: 0.9rem;
  padding-top: 50px;
  white-space: nowrap;
  max-width: calc(100% - 50px);
  font-family: 'Inter', sans-serif;
`;

export const QRTextItem = styled.div`
  display: inline-block;
  white-space: normal;
  vertical-align: middle;
`;

export const QRBox = styled.div`
  canvas {
    padding: 24px;
    border-radius: 8px;
    box-shadow: 0px 3px 10px -1px rgba(0, 0, 0, 0.05);
    border: 1px solid rgba(219, 222, 226, 1)
  }
`;

export const QRLink = styled.button`
  font-weight: 600;
  color: #3F39E8;
  font-size: 0.9em;
  font-family: poppins, sans-serif;
  width: 100%;
  padding: 14px 20px 14px 20px;
  border: none;
  background: none;
`;

export const WidgetHeading = styled.div`
  font-weight: 500;
  font-size: 1.6em;
  margin-top: 12px;
  color: #0D0F14;
  font-family: poppins, sans-serif;
`;

export const WidgetSubHeading = styled.div`
  font-weight: 400;
  font-size: 0.9em;
  color: background: #3F4855;
`;

export const HeadingWrapper = styled.div`
  text-align: left;
  padding: 10px 150px 40px 16px;
`;

export const SendButton = styled.button`
  width: 100%;
  padding: 14px 20px 14px 20px;
  border-radius: 26px;
  background: rgba(63, 57, 232, 1);
  border: none;
  color: #ffffff;
  font-weight: 600;
  font-family: poppins, sans-serif;
  font-size 0.9em;
`;

export const PaymentButtons = styled.div`
  padding: 24px 16px 32px 16px;
`;

export const PaymentOptions = styled.div`
  background-color: #ffffff;
  border-radius: 12px;
  padding: 20px 32px 32px 32px;
`;

export const SmallCurrencyDisplay = styled.div`
  display: inline-block;
  color: #3F4855;
  font-family: 'Inter', sans-serif;
`;

export const LargeCurrencyDisplay = styled.div`
  font-weight: 500;
  font-size: 1.8em;
  line-height: 1.1em;

  .currency {
    font-family: 'Inter', sans-serif;
    font-size: 0.5em;
  }
`;

export const ExchangeIcon = styled.div`
  height: 14px;
  width: 14px;
  background-image: url(${Exchange});
  background-size: 14px;
  background-repeat: no-repeat;
  display: inline-block;
  color: #3F4855;
  margin-left: 5px;
`;

export const CryptoOption = styled.div`
  text-align: left;
  padding: 20px 26px;
  font-weight: 600;

  img {
    margin-right: 16px;
    height: 32px;
    width: 32px;
  }
`;

export const AmountButton = styled.button`
  background-color: #FFFFFF;
  border: 1px solid #A1ABBA;
  font-size: 13px;
  padding: 5px 14px;
  &.selected {
    background-color: #EDEEF1;
  }

  &:first-of-type {
    border-right: none;
    border-top-left-radius: 8px;
    border-bottom-left-radius: 8px;
  }

  &:nth-of-type(2) {
    border-right: none;
  }
`;

export const AmountInput = styled.input`
  border: 1px solid #A1ABBA;
  border-left: none;
  border-top-right-radius: 8px;
  border-bottom-right-radius: 8px;
  padding: 5px 14px;
  width: 86px;
  color: #3F4855;
  font-size: 13px;

  &::-webkit-inner-spin-button,
  &::-webkit-outer-spin-button {
    -webkit-appearance: none; 
    margin: 0;
  }

  &::placeholder {
    color: #3F4855;
  }
`;

export const SuccessWrapper = styled.div`
  background-size: cover;
  background-image: url(${CryptoWidgetSuccess});
  border-radius: 12px;
  width: 520px;
  height: 542px;
  box-shadow: 0px 3px 10px -1px rgba(0, 0, 0, 0.05);
  margin: 0 auto;
  padding: 32px 16px;
`;

export const SuccessMessageWrapper = styled.div`
  padding-top: 205px;
  padding-left: 50px;
  padding-right: 50px;
  padding-bottom: 50px;
`;

export const SuccessThank = styled.div`
  font-weight: 600;
  font-size: 1.5em;
  color: #3F39E8;
  padding-top: 10px;
`;

export const SuccessAmount = styled.div`
  color: #2ABA32;
  font-weight: 600;
  font-family: 'Inter', sans-serif;
`;

export const ShareButton = styled.a`
  width: 100%;
  padding: 14px 20px 14px 20px;
  border-radius: 26px;
  background: rgba(63, 57, 232, 1);
  color: #ffffff;
  font-weight: 600;
  font-family: poppins, sans-serif;
  font-size 0.9em;
  display: block;
  cursor: pointer;

  &:hover {
    color: #ffffff;
    text-decoration: none;
  }
`;
