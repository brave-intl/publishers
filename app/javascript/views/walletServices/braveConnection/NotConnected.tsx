import * as React from "react";
import { FormattedMessage, injectIntl } from "react-intl";
import routes from "../../routes";
import { FlexWrapper } from "../../style";
import BitflyerIcon from "./bitflyerConnection/BitflyerIcon";
import GeminiIcon from "./geminiConnection/GeminiIcon";
import UpholdIcon from "./upholdConnection/UpholdIcon";
import ReactTooltip from "react-tooltip";

// This shows the Connect Buttons for the different Wallet Providers
const NotConnected = (props) => (
  <div className="row">
    <div className="col-6">
      <h6>
        <FormattedMessage id="walletServices.brave.title" />
      </h6>
      <FormattedMessage id="walletServices.brave.description" />
    </div>
    <div className="col-6 d-flex flex-column justify-content-center align-items-end">
      {props.featureFlags.gemini_enabled && props.locale !== 'ja' && <GeminiConnectButton allowedRegions={props.allowedRegions} />}
      {props.locale !== 'ja' && <UpholdConnectButton allowedRegions={props.allowedRegions} />}
      {props.locale === 'ja' && <BitflyerConnectButton />}
      {props.locale !== 'ja' && <div><a href='https://support.brave.com/hc/en-us/articles/6539887971469'>See list of supported regions for each custodian</a></div>}
    </div>
    <div className="col-11 alert alert-warning m-3 justify-content-center">
      <FormattedMessage id={"walletServices.brave.nonKycWarning"} values={{
        custodial_support_link: msg => (
          <a target='_blank' href='https://support.brave.com/hc/en-us/articles/9884338155149'>
            <strong>{msg}</strong>
          </a>
        ),
        em: msg => <em>{msg}</em>
      }} />
    </div>
  </div>
);

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
        <ReactTooltip 
          id='uphold-regions'
          effect='solid'
          place='right'
          getContent={(dataTip) => `Supported regions for Uphold: ${dataTip}`}>
        </ReactTooltip>
        <a
          className="btn btn-secondary font-weight-bold mb-2"
          data-piwik-action="UpholdConnectClicked"
          data-piwik-name="Clicked"
          data-piwik-value="Dashboard"
          rel="nofollow"
          data-method="post"
          href={routes.publishers.uphold.connect}
          data-tip={this.state.allowedRegions}
          data-for='uphold-regions'
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
      allowedRegions: props.allowedRegions.gemini.allow.join(', ')
    }
  }

  public render() {
    return (
      <>
        <ReactTooltip 
          id='gemini-regions'
          effect='solid'
          place='right'
          getContent={(dataTip) => `Supported regions for Gemini: ${dataTip}`}>
        </ReactTooltip>
        <a
          className="btn btn-secondary font-weight-bold mb-2"
          data-piwik-action="GeminiConnectClicked"
          data-piwik-name="Clicked"
          data-piwik-value="Dashboard"
          rel="nofollow"
          data-method="post"
          href={routes.publishers.gemini.connect}
          data-tip={this.state.allowedRegions}
          data-for='gemini-regions'
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
    data-piwik-action="BitflyerConnectClicked"
    data-piwik-name="Clicked"
    data-piwik-value="Dashboard"
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
