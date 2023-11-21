import React from "react";
import ReactDOM from "react-dom";
import { FormattedMessage, IntlProvider, useIntl } from "react-intl";

import { renderBannerEditor } from "../packs/banner_editor";

import SiteBanner from "./bannerPreview";
import { initLocale } from "brave-ui";
import locale from "locale/en";
import en, { flattenMessages } from "../locale/en";
import ja from "../locale/ja";

import { ThemeProvider } from "brave-ui/theme";
import Theme from "brave-ui/theme/brave-default";

export default class BannerPreview extends React.Component {

  constructor(props) {
    super(props);

    this.state = {};
  }

  componentWillMount() {
    this.prepareContainer();
  }

  componentDidMount() {
    // this.cleanup();
  }

  prepareContainer() {
    let container = document.getElementById("preview-container");
    container.setAttribute("style", "position: absolute; top: 0; left: 0; z-index:10000; height:100%; width:100%; background-color:rgba(12, 13, 33, 0.85)");
  }

  getSocial() {
    return Object.keys(this.props.socialLinks).filter(link => this.props.socialLinks[link])
      .map( link => {
        return { type: link, url: this.props.socialLinks[link] };
      });
  }

  handleClose() {
    let values = {
      title: this.props.title,
      description: this.props.description,
      logo: this.props.logo,
      cover: this.props.cover,
      donationAmounts: this.props.donationAmounts,
      channelIndex: this.props.channelIndex
    };
    let instantDonationButton = document.getElementById("instant-donation-button");
    instantDonationButton.click();
    renderBannerEditor(values, this.props.preferredCurrency, this.props.conversionRate, this.props.channelBanners, "Editor-From-Preview");
    setTimeout(function() {
      document.getElementById("preview-container").remove();
    }, 100);

  }

  cleanup() {
    document.getElementsByClassName("sc-bZQynM rOiyj")[0].remove();
    document.getElementsByClassName("sc-fjdhpX jopENR")[0].style.visibility = "hidden";
  }

  render() {
    const docLocale = document.body.dataset.locale;
    let localePackage = en;
    if (docLocale === "ja") {
      localePackage = ja;
    }
    return (
      <ThemeProvider theme={Theme}>
        <IntlProvider locale={docLocale} messages={flattenMessages(localePackage)}>
          <div style={{ height: "100%", width: "97%", margin: "auto" }}>
            <SiteBanner
              domain={""}
              title={this.props.title}
              currentDonation={0}
              balance={25.0}
              currentAmount={0}
              onClose={() => this.handleClose()}
              bgImage={this.props.cover.url}
              logo={this.props.logo.url}
              donationAmounts={
                [
                  { tokens: 1, converted: (1 * this.props.conversionRate).toFixed(2), selected: false },
                  { tokens: 5, converted: (5 * this.props.conversionRate).toFixed(2), selected: false },
                  { tokens: 10, converted: (10 * this.props.conversionRate).toFixed(2), selected: false }
                ]
              }
              social={this.getSocial()}
            >
              <p>{this.props.description}</p>
            </SiteBanner>
          </div>
        </IntlProvider>
      </ThemeProvider>
    );
  }
}
