import * as React from "react";
import { FormattedMessage, injectIntl } from "react-intl";
import routes from "../../routes";
import { FlexWrapper } from "../../style";
import BitflyerIcon from "./bitflyerConnection/BitflyerIcon";
import GeminiIcon from "./geminiConnection/GeminiIcon";
import UpholdIcon from "./upholdConnection/UpholdIcon";
import { Tooltip } from "react-tooltip";

// This shows the Connect Buttons for the different Wallet Providers

class NotConnected extends React.Component<any, any> {
  constructor(props) {
    super(props);
    
    const supportUrl = props.locale !== 'ja' ? 'https://support.brave.com/hc/en-us/articles/9884338155149' : 'https://support.brave.com/hc/en-us/articles/23311539795597';

    this.state = {
      allowedRegions: props.allowedRegions,
      locale: props.locale,
      featureFlags: props.featureFlags,
      supportUrl,
    }
  }
  
  public render() {
    return (
      <div className="row">
        <div className="col-6">
          <h6>
            <FormattedMessage id="walletServices.brave.title" />
          </h6>
          <FormattedMessage id="walletServices.brave.description" />
        </div>
        <div className="col-6 d-flex flex-column justify-content-center align-items-end">
          {this.state.featureFlags.gemini_enabled && this.state.locale !== 'ja' && <GeminiConnectButton allowedRegions={this.state.allowedRegions} />}
          {this.state.locale !== 'ja' && <UpholdConnectButton allowedRegions={this.state.allowedRegions} />}
          {this.state.locale === 'ja' && <BitflyerConnectButton />}
          {this.state.locale !== 'ja' && <div><a href='https://support.brave.com/hc/en-us/articles/6539887971469'>See list of supported regions for each custodian</a></div>}
        </div>
        <div className="col-11 alert alert-warning m-3 justify-content-center">
          <FormattedMessage id={"walletServices.brave.nonKycWarning"} values={{
            custodial_support_link: msg => (
              <a target='_blank' href={this.state.supportUrl}>
                <strong>{msg}</strong>
              </a>
            ),
            em: msg => <em>{msg}</em>
          }} />
        </div>
      </div>
    )
  }
};

// This button connects to the uphold resource on the Publishers backend.
// The data-method is a built-in Rails method that will use rails-ujs to submit a "patch" request to the backend
// The backend updates the state token and then redirects to Uphold to have the user fill out their login details.
// Afterwards this redirects the user to the UpholdController/#create action.
class UpholdConnectButton extends React.Component<any, any> {
  constructor(props) {
    super(props);
    this.state = {
      allowedRegions: props.allowedRegions.uphold.allow.join(', ')
    }
  }

  public render() {
    return (
      <>
        <Tooltip
          id='uphold-regions'
          place='right'
          render={({content}) => `Supported regions for Uphold: ${content}`}>
        </Tooltip>
        <a
          className="btn btn-secondary font-weight-bold mb-2"
          rel="nofollow"
          data-method="post"
          href={routes.publishers.uphold.connect}
          data-tooltip-content={this.state.allowedRegions}
          data-tooltip-id='uphold-regions'
        >
          <FlexWrapper className="align-items-center">
            <FormattedMessage id="walletServices.uphold.connect" />
            <UpholdIcon />
          </FlexWrapper>
        </a>
      </>
    );
  }
}

class GeminiConnectButton extends React.Component<any, any> {
  constructor(props) {
    super(props);

    this.state = {
      allowedRegions: 'US'
    }
  }

  public render() {
    return (
      <>
        <Tooltip
          id='gemini-regions'
          place='right'
          render={({content}) => `Supported regions for Gemini: ${content}`}>
        </Tooltip>
        <a
          className="btn btn-secondary font-weight-bold mb-2"
          rel="nofollow"
          data-method="post"
          href={routes.publishers.gemini.connect}
          data-tooltip-content={this.state.allowedRegions}
          data-tooltip-id='gemini-regions'
        >
          <FlexWrapper className="align-items-center">
            <FormattedMessage id="walletServices.gemini.connect" />
            <GeminiIcon />
          </FlexWrapper>
        </a>
      </>
    );
  }
}

const BitflyerConnectButton = () => (
  <a
    className="btn btn-secondary font-weight-bold mb-2"
    rel="nofollow"
    data-method="post"
    href={routes.publishers.bitflyer.connect}
  >
    <FlexWrapper className="align-items-center">
      <FormattedMessage id="walletServices.bitflyer.connect" />
      <BitflyerIcon />
    </FlexWrapper>
  </a>
);

export default injectIntl(NotConnected);
