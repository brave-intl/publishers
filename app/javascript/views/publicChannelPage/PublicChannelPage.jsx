import * as React from "react";
import { FormattedMessage, injectIntl } from "react-intl";

import CryptoPaymentWidget from "./CryptoPaymentWidget";

import styled from "styled-components";
import {
  Logo,
  Cover,
  ImageContainer,
  DescriptionContainer,
  CreatorTitle,
  CreatorDescription,
  PrivacyDisclaimer,
  CryptoPaymentContainer,
  SocialLink,
  PublicChannelContainer,
} from "./PublicChannelPageStyle.js";

import twitter from "../../../assets/images/social-x.svg";
import vimeo from "../../../assets/images/social-vimeo.svg";
import github from "../../../assets/images/social-github.svg";
import twitch from "../../../assets/images/social-twitch.svg";
import reddit from "../../../assets/images/social-reddit.svg";
import youtube from "../../../assets/images/social-youtube.svg";
import verified from "../../../assets/images/purple_verified.png";

class PublicChannelPage extends React.Component {
  constructor(props) {
    super(props);


    this.coverUrl = this.replaceBlankUrl(this.props.siteBanner, "backgroundUrl");
    this.logoUrl = this.replaceBlankUrl(this.props.siteBanner, "logoUrl")
    this.title = props.siteBanner && props.siteBanner.title;
    this.description = props.siteBanner && props.siteBanner.description;
    this.socialLinks = props.siteBanner && props.siteBanner.socialLinks || [];
    this.cryptoAddresses = props.cryptoAddresses;
    this.cryptoConstants = props.cryptoConstants;
    this.url = props.url

    this.socialIcons = { youtube, twitter, twitch, github, reddit, vimeo };
  }

  replaceBlankUrl(siteBanner, propName) {
    const url = siteBanner && siteBanner[propName];
    return url.length > 1 ? url : null;
  }
  
  render() {
    return (
      <PublicChannelContainer>
        <ImageContainer>
          <Cover url={this.coverUrl}/>
        </ImageContainer>
        <div className='container'>
          <div className='row'>
            <DescriptionContainer className='col-xs-12 col-lg-6'>
              <Logo url={this.logoUrl}/>
              <CreatorTitle>{this.title} <img src={verified} /></CreatorTitle>
              <CreatorDescription>{this.description}</CreatorDescription>
              <div>
                {Object.keys(this.socialLinks).map((key) => {
                  if (this.socialLinks[key].length) {
                    return (
                      <SocialLink href={this.socialLinks[key]} 
                                  key={key}
                                  target="_blank"
                                  rel="noopener noreferrer">
                                    <img src={this.socialIcons[key]} />
                      </SocialLink>
                    );
                  }
                })}
              </div>
            </DescriptionContainer>
            <CryptoPaymentContainer className='col-xs-12 col-lg-6'>
              <CryptoPaymentWidget title={this.title} cryptoAddresses={this.cryptoAddresses} cryptoConstants={this.cryptoConstants} />
              <PrivacyDisclaimer>
                <FormattedMessage id="publicChannelPage.trustWarning" />
                <a href={this.url} target="_blank" >{this.url}</a>
              </PrivacyDisclaimer>
              <PrivacyDisclaimer>
                <FormattedMessage id="publicChannelPage.privacyDisclaimer" />
              </PrivacyDisclaimer>
            </CryptoPaymentContainer>
          </div>
        </div>
      </PublicChannelContainer>
    )
  }
}

export default injectIntl(PublicChannelPage);
