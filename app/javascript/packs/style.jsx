import styled, { css } from "styled-components";

import BatsBackground from "../../assets/images/bg_bats.svg";
import HeartsBackground from "../../assets/images/bg_hearts.svg";

export const Container = styled.div``;

export const Dialogue = styled.div`
  position: absolute;
  background-color: white;
  border-radius: 8px;
  left: 50%;
  top: 50%;
  padding: 75px;
  z-index: 1;

  ${props =>
    props.logo &&
    `
    width: 500px;
    height: 500px;
    margin-left: -250px;
    margin-top: -250px;
    padding: 40px;
    text-align: center;
    `}

  ${props =>
    props.cover &&
    `
    width: 600px;
    height: 400px;
    margin-left: -300px;
    margin-top: -250px;
    padding: 40px;
    text-align: center;
    `}

  ${props =>
    props.save &&
    `
    width: 550px;
    margin-left: -275px;
    margin-top: -200px;
    `}
`;

export const Channels = styled.div`
  margin-top: 7px;

  ${({ active }) =>
    active === false &&
    `
    opacity: .3;
    pointer-events: none;
  `}
`;

export const Opacity = styled.div`
  position: absolute;
  width: 100%;
  height: 100%;
  z-index: 1;
  background: rgba(64, 64, 64, 0.7);
  border-radius: 6px;
`;

export const Editor = styled.div`
  width: 1300px;
`;

export const Template = styled.div``;

export const LinkInputWrapper = styled.div``;

export const Content = styled.div`
  display: grid;
  grid-template-columns: 3.5fr 5fr 3fr;
  background-color: rgb(233, 240, 255);
  border-radius: 8px;
  height: 350px;
`;

export const Input = styled.input`
  display: none;
`;

export const DropdownToggle = styled.div`
  display: inline;
`;

export const TextInput = styled.input`
  background-color: rgba(0, 0, 0, 0);
  border: 1px solid #686978;
  border-radius: 8px;
  color: #686978;
  padding: 10px;
  cursor: pointer;

  &:hover {
    box-shadow: 0 0 1px 1px #fc4145;
    border: 1px solid rgba(0, 0, 0, 0);
  }

  &:focus {
    cursor: text;
    box-shadow: 0 0 1px 1px #fc4145;
    border: 1px solid rgba(0, 0, 0, 0);
    outline: none;
  }

  ${props =>
    props.link &&
    `
    display: inline;
    width: 175px;
    height: 40px;
    margin-left: 5px;
    `}

  ${props =>
    props.headline &&
    `
    color: #28292e;
    font-size: 32px;
    width: 100%;
    height: 50px;
    margin-top: 10px;
    `}
`;

export const TextArea = styled.textarea`
  background-color: rgba(0, 0, 0, 0);
  border: 1px solid #686978;
  border-radius: 8px;
  color: #686978;
  width: 100%;
  height: 200px;
  margin-top: 10px;
  padding: 10px;
  font-size: 16px;
  resize: none;
  cursor: pointer;

  &:hover {
    box-shadow: 0 0 1px 1px #fc4145;
    border: 1px solid rgba(0, 0, 0, 0.5);
  }

  &:focus {
    cursor: text;
    box-shadow: 0 0 1px 1px #fc4145;
    border: 1px solid rgba(0, 0, 0, 0.5);
    outline: none;
  }
`;

export const Label = styled.label`
  height: 100%;
  width: 100%;
  border: none;
  cursor: pointer;

  ${props =>
    props.logo &&
    `
    border-radius:50%;
    `}

  &:hover {
    background: linear-gradient(rgba(0, 0, 0, 0.5), rgba(0, 0, 0, 0.5));
  }
`;

export const Text = styled.p`
  font-size: 18px;
  font-weight: bold;
  font-family: Poppins, sans-serif;

${props =>
  props.links &&
  css`
    color: rgb(104, 105, 120);
  `}

${props =>
  props.donations &&
  css`
    font-size: 17px;
    color: white;
    padding-left: 42px;
    margin-bottom: 8px;
  `}

${props =>
  props.add &&
  css`
    color: rgb(125, 123, 220);
    margin-left: 78px;
    margin-top: 15px;
    font-size: 15px;
    cursor: pointer;
    width: 80px;
  `}

${props =>
  props.donation &&
  css`
    color: white;
  `}

${props =>
  props.donationAmount &&
  css`
    display: inline;
    font-size: 14px;
    color: #f1f1f9;
  `}

${props =>
  props.convertedAmount &&
  css`
    display: inline-block;
    font-size: 14px;
    padding: 5px;
    width: 100px;
    font-weight: normal;
    color: #f1f1f9;
  `}

${props =>
  props.BAT &&
  css`
    display: inline;
    font-size: 0.85rem;
    font-weight: normal;
    margin-left: 5px;
    font-family: Poppins;
    color: #f1f1f9;
  `}

${props =>
  props.dialogueHeader &&
  css`
    font-size: 24px;
    font-weight: normal;
    font-family: Poppins;
    color: #4c54d2;
  `}

${props =>
  props.dialogueSubtext &&
  css`
    font-size: 15px;
    font-weight: normal;
    color: rgb(104, 105, 120);
  `}

${props =>
  props.channel &&
  css`
    font-size: 1.25rem;
    margin-bottom: 0px;
    user-select: none;
  `}
`;

export const Links = styled.div`
  padding-left: 80px;
  padding-top: 80px;
`;

export const Caret = styled.div`
  display: inline;
  font-size: 20px;
  margin: auto;
  user-select: none;
  font-family: Segoe UI Symbol;
  opacity: 0.5;
  padding: 7px;
  cursor: pointer;
`;

export const ExplanatoryText = styled.div`
  padding-top: 30px;
  padding-right: 75px;
  padding-left: 30px;
`;

export const DonationWrapper = styled.div`
  text-align: center;
  padding-top: 5px;
  padding-bottom: 5px;
`;

export const Channel = styled.p`
  display: inline-block;
  padding-left: 5px;
  max-width: 250px;
  margin: auto;
  overflow: hidden;
  white-space: nowrap;
  text-overflow: ellipsis;
`;

export const Delete = styled.p`
  display: inline;
  padding-left: 5px;
  padding-right: 5px;
  cursor: pointer;
  font-size: 0.85rem;
  color: #7d7bdc;
`;

export const Donations = styled.div`
  background-color: rgb(105, 111, 220);
  margin-right: -1px;
  color: white;
  padding-top: 35px;
  border-bottom-right-radius: 8px;
`;

export const Link = styled.div``;

export const BrandBar = styled.div`
  display: flex;
  align-items: center;
  height: 80px;
  padding-left: 60px;
  padding-right: 30px;
  background-color: #e9e9f4;
  border-top-left-radius: 8px;
  border-top-right-radius: 8px;

  ${({ mode }) =>
    mode === "test" &&
    `
    background-color: blue;
  `}
`;

export const Logo = styled.div`
  position: absolute;
  top: 320px;
  left: 175px;
  border-radius: 50%;
  width: 160px;
  height: 160px;
  border: 6px solid white;

  ${({ url }) =>
    url &&
    `
    background-size: cover;
    background-image: url(${url})
  `}

  ${({ url }) =>
    url === null &&
    `
    background-color: #4C54D2;
  `}
`;

export const Cover = styled.div`
  height: 234px;

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

export const ControlBar = styled.div`
  display: flex;
  align-items: center;
  height: 80px;
  padding-left: 60px;
  padding-right: 30px;
`;

export const BrandImage = styled.img`
  height: 50px;
`;

export const BrandText = styled.h5`
  padding-left: 20px;
  margin-top: 8.5px;
  margin-bottom: 0px;
  user-select: none;
`;

export const ToggleText = styled.p`
  margin-bottom: 0px;
  margin-top: 3.25px;
  margin-left: auto;
  margin-right: 10px;
  font-weight: bold;
  user-select: none;
`;

export const ToggleWrapper = styled.div`
  margin-top: 7px;
`;

export const Button = styled.div`
  width: 150px;
  text-align: center;
  border-radius: 24px;
  padding: 9px 10px;
  font-size: 14px;
  font-weight: bold;
  cursor: pointer;
  user-select: none;
  display: inline-block;

  ${props =>
    props.primary &&
    css`
      background-color: #4c54d2;
      border: 1px solid #4c54d2;
      color: white;
    `}

  ${props =>
    props.dialoguePrimary &&
    css`
      background-color: #4c54d2;
      border: 1px solid #4c54d2;
      color: white;
      display: block;
      margin: auto;
      margin-top: 30px;
    `}

  ${props =>
    props.outline &&
    css`
      border: 1px solid #4c54d2;
      color: #4c54d2;
    `}

  ${props =>
    props.subtle &&
    css`
      border: 1px solid #a0a1b2;
      color: #a0a1b2;
    `}

  ${props =>
    props.donation &&
    css`
      width: 125px;
      padding: 6px 7px;
      font-weight: normal;
      border: 1px solid #aaafef;
      color: #f1f1f9;
    `}

`;
