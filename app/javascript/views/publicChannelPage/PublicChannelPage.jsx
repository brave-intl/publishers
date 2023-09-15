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
} from "./PublicChannelPageStyle.js";

import twitch from "../../../assets/images/social-twitch.png";
import youtube from "../../../assets/images/social-youtube.png";
import twitter from "../../../assets/images/social-twitter.png";
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

    this.socialIcons = { youtube, twitter, twitch };
  }

  replaceBlankUrl(siteBanner, propName) {
    const url = siteBanner && siteBanner[propName];
    return url.length > 1 ? url : null;
  }
  
  render() {
    return (
      <>
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
              <CryptoPaymentWidget cryptoAddresses={this.cryptoAddresses} />
              <PrivacyDisclaimer>
                <FormattedMessage id="publicChannelPage.privacyDisclaimer" />
              </PrivacyDisclaimer>
            </CryptoPaymentContainer>
          </div>
        </div>
      </>
    )
  }
}

export default injectIntl(PublicChannelPage);
