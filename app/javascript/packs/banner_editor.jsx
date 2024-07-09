import React from "react";
import ReactDOM from "react-dom";
import { FormattedMessage, IntlProvider } from "react-intl";
import AvatarEditor from "react-avatar-editor";

import BannerPreview from "../packs/banner_preview.jsx";
import Navbar from "../packs/navbar.jsx";

import FailureDialog from "./bannerEditor/FailureDialog";

import { ThemeProvider } from "brave-ui/theme";
import Theme from "brave-ui/theme/brave-default";

import styled from "styled-components";
import {
  Editor,
  Template,
  Content,
  Links,
  ExplanatoryText,
  Logo,
  Cover,
  Input,
  Label,
  Text,
  Caret,
  LinkInputWrapper,
  TextInput,
  DropdownToggle,
  Channel,
  Delete,
  Link,
  TextArea,
  Button,
  Opacity,
  Dialogue,
  LinkError,
} from "../packs/style.jsx";

import DonationJar from "../../assets/images/icn-donation-jar@1x.png";
import Spinner from "../utils/spinner";

import locale from "locale/en";
import en, { flattenMessages } from "../locale/en";
import ja from "../locale/ja";

import {
  BatColorIcon,
  YoutubeColorIcon,
  TwitterColorIcon,
  TwitchColorIcon,
  VimeoColorIcon,
  GitHubColorIcon,
  RedditColorIcon,
  LoaderIcon
} from "brave-ui/components/icons";
import Select from 'react-select';

import "../../assets/stylesheets/components/banner-editor.scss";
import "../../assets/stylesheets/components/spinner.scss";
import "../../assets/stylesheets/components/slider.scss";

const DEFAULT_TITLE = "Brave Creators";
const DEFAULT_DESCRIPTION =
  "Thanks for stopping by. We joined Brave's vision of protecting your privacy because we believe that fans like you would support us in our effort to keep the web a clean and safe place to be.\n\nYour tip is much appreciated and it encourages us to continue to improve our content";

export default class BannerEditor extends React.Component {
  constructor(props) {
    super(props);

    const locale = document.body.dataset.locale;
    let localePackage = en;
    if (locale === "ja") {
      localePackage = ja;
    }

    this.state = {
      loading: true,
      title: this.props.values.title || DEFAULT_TITLE,
      description: this.props.values.description || localePackage.siteBanner.defaultDescription,
      logo: this.props.values.logo || { url: null, data: null },
      cover: this.props.values.cover || { url: null, data: null },
      channelIndex: this.props.values.channelIndex || 0,
      channelBanners: this.props.channelBanners,
      scale: 1,
      socialLinks: {},
      selectedSocial: "",
      linkErrorText: false,
      conversionRate: this.props.conversionRate,
      preferredCurrency: "USD",
      mode: "Edit",
      view: "editor-view",
      state: "editor",
      publisherId: this.props.publisherId
    };
    // this data is from the publisher and applies to all channels, will not change once modal is loaded
    this.socialMediaOptions = this.props.channelBanners.filter( channel => channel.type !== 'SiteChannelDetails' )
                                .map( channel => { 
                                  return {value: channel.url, type: channel.type, label: channel.url.replace(/^https?:\/\/(www\.)?/, '')}
                                });
    
    this.updateTitle = this.updateTitle.bind(this);
    this.preview = this.preview.bind(this);
    this.updateDescription = this.updateDescription.bind(this);
    this.save = this.save.bind(this);
    this.incrementChannelIndex = this.incrementChannelIndex.bind(this);
    this.decrementChannelIndex = this.decrementChannelIndex.bind(this);
    this.updateWindowDimensions = this.updateWindowDimensions.bind(this);
    this.selectSocial = this.selectSocial.bind(this);
    this.handleLinkDelete = this.handleLinkDelete.bind(this);
    this.addSocialLink = this.addSocialLink.bind(this);
  }

  componentWillMount() {
    this.modalize();
  }

  componentDidMount() {
    this.fetchBanner();
    this.setSpinner();
    this.cleanup();
    window.addEventListener("resize", this.updateWindowDimensions);
  }

  updateWindowDimensions() {
    if (window.innerWidth < 991) {
      this.close();
    }
  }

  modalize() {
    document.getElementsByClassName("modal-panel")[0].style.maxWidth = "none";
    document.getElementsByClassName("modal-panel")[0].style.padding = "0px";
    document.getElementsByClassName("modal-panel--content")[0].style.padding =
      "0px";
  }

  close() {
    document.getElementsByClassName("modal-panel")[0].style.maxWidth = "40rem";
    document.getElementsByClassName("modal-panel")[0].style.padding =
      "2rem 2rem";
    document.getElementsByClassName("modal-panel--content")[0].style.padding =
      "1rem 1rem 0 1rem";
    document.getElementsByClassName(
      "modal-panel--close js-deny"
    )[0].style.visibility = "visible";
    document.getElementsByClassName("modal-panel--close js-deny")[0].click();
  }

  cleanup() {
    document.getElementsByClassName(
      "modal-panel--close js-deny"
    )[0].style.visibility = "hidden";
  }

  preview() {
    let div = document.createElement("div");
    div.id = "preview-container";
    let PreviewContainer = document.body.appendChild(div);

    ReactDOM.render(<BannerPreview {...this.state} />, PreviewContainer);
    this.close();
  }

  setSpinner() {
    Spinner.show("spinner", "spinner-container");
  }

  setEditorRef = editor => (this.editor = editor);

  handleZoom(e) {
    this.setState({ scale: e.target.value });
  }

  apply() {
    let that = this;
    let logo = this.state.logo;
    let cover = this.state.cover;
    let img;
    try {
      img = this.editor.getImage();
    } catch (error) {
      // errors would happen here if the user uploads a file that's not an image
      // clear out the 'errored' data
      this.state[this.state.state] = { url: null, data: null };
      // get rid of dialog: same as clicking the 'cancel' button
      this.setState({ state: "Editor" });
      // don't try to save or set anything
      return;
    }

    switch (this.state.state) {
      case "logo":
        let logoCanvas = document.createElement("canvas");
        logoCanvas.width = 480;
        logoCanvas.height = 480;
        var ctx = logoCanvas.getContext("2d");
        ctx.drawImage(img, 0, 0, 480, 480);
        logo.url = logoCanvas.toDataURL("image/jpeg", 1);

        //Generate data to save
        logoCanvas.toBlob(function(blob) {
          let file = {};
          file["files"] = [blob];
          logo.data = file;
          that.setState({ logo: logo, scale: 1, state: "editor" });
        }, "image/jpeg", 1);
        break;
      case "cover":
        let coverCanvas = document.createElement("canvas");
        coverCanvas.width = 2700;
        coverCanvas.height = 528;
        var ctx = coverCanvas.getContext("2d");
        ctx.drawImage(img, 0, 0, 2700, 528);
        cover.url = coverCanvas.toDataURL("image/jpeg", 1);

        //Generate data to save
        coverCanvas.toBlob(function(blob) {
          let file = {};
          file["files"] = [blob];
          cover.data = file;
          that.setState({ cover: cover, scale: 1, state: "editor" });
        }, "image/jpeg", 1);
        break;
    }
  }

  addLogo(event) {
    let temp = URL.createObjectURL(event.target.files[0]);
    this.setState({
      tempLogo: temp,
      state: "logo"
    });
  }

  addCover(event) {
    let temp = URL.createObjectURL(event.target.files[0]);
    this.setState({
      tempCover: temp,
      state: "cover"
    });
  }

  async fetchBanner() {
    let that = this;
    if (this.props.mode === "Editor-From-Preview" && !this.state.fetch) {
      that.setState({ loading: false });
    } else {
      let url =
        "/publishers/" +
        this.state.publisherId +
        "/site_banners/";
      this.state.defaultSiteBannerMode
        ? (url += this.props.defaultSiteBanner.id)
        : (url += this.props.channelBanners[this.state.channelIndex].id);

      let options = {
        method: "GET",
        credentials: "same-origin",
        headers: {
          Accept: "text/html",
          "X-Requested-With": "XMLHttpRequest",
          "X-CSRF-Token": document.head.querySelector("[name=csrf-token]")
            .content
        }
      };

      let response = await fetch(url, options);
      if (response.status >= 400) {
        location.reload();
      }
      let banner = await response.json();

      //500ms timeout prevents quick flash when load times are fast.
      setTimeout(async () => {
        if (banner) {
          console.log(banner)
          that.setState({
            title: banner.title || DEFAULT_TITLE,
            description: banner.description || DEFAULT_DESCRIPTION,
            // TODO update state here as well
            socialLinks: banner.socialLinks || {},
            logo: { url: banner.logoUrl || null, data: null },
            cover: { url: banner.backgroundUrl || null, data: null },
            loading: false,
            fetch: false
          });
        } else {
          that.setState({ loading: false });
        }
        if (this.props.mode === "Preview") {
          this.preview();
        }
      }, 500);
    }
  }

  handleLinkDelete(option) {
    const oldLinks = { ...this.state.socialLinks };
    delete oldLinks[option];
    this.setState({ socialLinks: { ...oldLinks } });
  }

  updateTitle(event) {
    this.setState({ title: event.target.value });
  }

  updateDescription(event) {
    this.setState({ description: event.target.value });
  }

  setEditMode = () => {
    this.setState({ state: "Editor" });
  };

  renderDialogue() {
    let dialogue;

    switch (this.state.state) {
      case "logo":
        dialogue = (
          <div>
            <Opacity />
            <Dialogue logo>
              <Text dialogueHeader>
                <FormattedMessage id="siteBanner.resizeLogoLabel" />
              </Text>
              <AvatarEditor
                ref={this.setEditorRef}
                image={this.state.tempLogo}
                width={180}
                height={180}
                border={20}
                borderRadius={160}
                color={[230, 236, 240, 0.6]}
                scale={this.state.scale}
                style={{ marginTop: "20px", cursor: "move" }}
              />
              <br />
              <input
                style={{
                  width: "120px",
                  textAlign: "center",
                  marginTop: "30px",
                  marginBottom: "40px"
                }}
                onChange={e => this.handleZoom(e)}
                type="range"
                value={this.state.scale}
                min={1}
                max={2}
                step={0.01}
              />
              <br />
              <Button
                onClick={() => this.setState({ state: "Editor" })}
                style={{ margin: "10px", width: "120px" }}
                outline
              >
                <FormattedMessage id="siteBanner.cancel" />
              </Button>
              <Button
                onClick={() => this.apply()}
                style={{ margin: "10px", width: "120px" }}
                primary
              >
                <FormattedMessage id="siteBanner.apply" />
              </Button>
            </Dialogue>
          </div>
        );
        break;
      case "cover":
        dialogue = (
          <div>
            <Opacity />
            <Dialogue cover>
              <Text dialogueHeader>
                <FormattedMessage id="siteBanner.resizeBackgroundImage" />
              </Text>
              <AvatarEditor
                ref={this.setEditorRef}
                image={this.state.tempCover}
                width={450}
                height={88}
                border={20}
                color={[230, 236, 240, 0.6]}
                scale={this.state.scale}
                style={{ marginTop: "20px", cursor: "move" }}
              />
              <br />
              <input
                style={{
                  width: "120px",
                  textAlign: "center",
                  marginTop: "30px",
                  marginBottom: "40px"
                }}
                onChange={e => this.handleZoom(e)}
                type="range"
                value={this.state.scale}
                min={1}
                max={2}
                step={0.01}
              />
              <br />
              <Button
                onClick={() => this.setState({ state: "Editor" })}
                style={{ margin: "10px", width: "120px" }}
                outline
              >
                <FormattedMessage id="siteBanner.cancel" />
              </Button>
              <Button
                onClick={() => this.apply()}
                style={{ margin: "10px", width: "120px" }}
                primary
              >
                <FormattedMessage id="siteBanner.apply" />
              </Button>
            </Dialogue>
          </div>
        );
        break;
      case "save":
        dialogue = (
          <div>
            <Opacity />
            <Dialogue id="save-container" save>
              {this.state.saving === false && (
                <div>
                  <Text dialogueHeader>
                    <FormattedMessage id="siteBanner.update24Hours" />
                  </Text>
                  <Button dialoguePrimary onClick={this.setEditMode}>
                    OK
                  </Button>
                </div>
              )}
            </Dialogue>
          </div>
        );
        break;
      case "error":
        dialogue = (
          <FailureDialog
            saving={this.state.saving}
            setEditMode={this.setEditMode}
            message={this.state.errorMessage}
          />
        );
        break;
    }
    return dialogue;
  }

  renderLoadingScreen() {
    let visibility = "hidden";
    if (this.state.loading === true) {
      visibility = "visible";
    }
    return (
      <div
        style={{
          width: "100%",
          height: "744px",
          position: "absolute",
          zIndex: "20000",
          backgroundColor: "rgba(233, 240, 255, 1)",
          borderRadius: "8px",
          visibility: visibility
        }}
      >
        <div
          style={{
            width: "100%",
            marginTop: "auto",
            marginBottom: "auto",
            position: "absolute",
            left: "0",
            right: "0",
            top: "300px",
            bottom: "0"
          }}
          id="spinner-container"
        />
      </div>
    );
  }

  renderLinks() {
    const components = {
      youtube: YoutubeColorIcon,
      twitter: TwitterColorIcon,
      twitch: TwitchColorIcon,
      github: GitHubColorIcon,
      reddit: RedditColorIcon,
      vimeo: VimeoColorIcon,
    };

    return Object.keys(this.state.socialLinks).map((link) => {
      if ( !this.state.socialLinks[link] ) {
        return null;
      }

      const IconComponent = components[link];
      return (<Link key={link}>
        <IconComponent
          className="banner-link-option"
          style={{
            height: "30px",
            width: "30px",
            display: "inline-block",
            marginBottom: "12px"
          }}
        />
        <Channel>
          <Delete onClick={() => this.handleLinkDelete(link)}>
            (X)
          </Delete>
          {this.state.socialLinks[link].replace(/^https?:\/\/(www\.)?/, '')}
        </Channel>
      </Link>)
    });
  }

  selectSocial(optionVal) {
    this.setState({selectedSocial: optionVal});
  }

  addSocialLink() {
    if (this.state.selectedSocial && Object.keys(this.state.selectedSocial).length === 0) {
      return;
    }
    // reset error state
    this.setState({linkErrorText: false});
    // only allow one link to each platform
    const socialType = this.state.selectedSocial.type.toLowerCase().replace('channeldetails', '');

    if (this.state.socialLinks[socialType]) {
      this.setState({linkErrorText: true});
    } else {
      const oldLinks = { ...this.state.socialLinks };
      oldLinks[socialType] = this.state.selectedSocial.value;
      this.setState({ socialLinks: { ...oldLinks } });
    }
  }

  async save() {
    this.setState({ state: "save", saving: "true" }, () =>
      Spinner.show("save-spinner", "save-container")
    );

    let url =
      "/publishers/" +
      this.state.publisherId +
      "/site_banners/";
    this.state.defaultSiteBannerMode
      ? (url += this.props.defaultSiteBanner.id)
      : (url += this.props.channelBanners[this.state.channelIndex].id);

    let body = new FormData();
    body.append("title", this.state.title);
    body.append("description", this.state.description);
    
    // TODO UPDATE
    body.append(
      "social_links",
      JSON.stringify(this.state.socialLinks)
    );

    if (this.state.logo.data) {
      let logo = await this.readData(this.state.logo.data);
      body.append("logo", logo);
    }
    if (this.state.cover.data) {
      let cover = await this.readData(this.state.cover.data);
      body.append("cover", cover);
    }

    let options = {
      method: "PUT",
      credentials: "same-origin",
      headers: {
        Accept: "text/html",
        "X-Requested-With": "XMLHttpRequest",
        "X-CSRF-Token": document.head.querySelector("[name=csrf-token]").content
      },
      body: body
    };

    let save = await fetch(url, options);
    if (save.status == 400) {
      const errorMessage = await save.json();
      const { message } = errorMessage;

      this.setState({
        saving: false,
        state: "error",
        errorMessage: message
      });
      // location.reload();
    } else if (save.status > 400) {
      this.setState({
        saving: false,
        state: "error",
        errorMessage: "A critical error has occurred. Please try again later"
      });
    }

    document.getElementById("save-spinner").remove();
    this.setState({ saving: false });
  }

  readData(file) {
    let reader = new FileReader();
    reader.readAsDataURL(file.files[0]);
    return new Promise(
      resolve =>
        (reader.onloadend = function() {
          resolve(reader.result);
        })
    );
  }

  incrementChannelIndex() {
    this.setState(
      prevState => {
        return {
          channelIndex: (prevState.channelIndex += 1),
          loading: true,
          fetch: true
        };
      },
      () => {
        this.fetchBanner();
      }
    );
  }

  decrementChannelIndex() {
    this.setState(
      prevState => {
        return {
          channelIndex: (prevState.channelIndex -= 1),
          loading: true,
          fetch: true
        };
      },
      () => {
        this.fetchBanner();
      }
    );
  }

  render() {
    const locale = document.body.dataset.locale;
    let localePackage = en;
    if (locale === "ja") {
      localePackage = ja;
    }
    return (
      <IntlProvider locale={locale} messages={flattenMessages(localePackage)}>
        <Editor>
          {this.renderLoadingScreen()}
          {this.renderDialogue()}

          <Navbar
            defaultSiteBanner={this.props.defaultSiteBanner}
            channelBanners={this.props.channelBanners}
            channelIndex={this.state.channelIndex}
            incrementChannelIndex={this.incrementChannelIndex}
            decrementChannelIndex={this.decrementChannelIndex}
            save={this.save}
            close={this.close}
            preview={this.preview}
          />

          <Template>
            <Logo url={this.state.logo.url}>
              <Input
                type="file"
                id="logoInput"
                accept="image/png, image/jpeg, image/webp"
                onChange={e => this.addLogo(e)}
              />
              <Label logo htmlFor="logoInput" />
            </Logo>

            <Cover url={this.state.cover.url}>
              <Input
                type="file"
                id="backgroundInput"
                accept="image/png, image/jpeg, image/webp"
                onChange={e => this.addCover(e)}
              />
              <Label htmlFor="backgroundInput" />
            </Cover>

            <Content>
              <Links>
                <Text links>
                  <FormattedMessage id="siteBanner.links" />
                </Text>
                {this.renderLinks()}
                <FormattedMessage id="siteBanner.linksPlaceholder">
                  {placeholder =>  
                    <Select
                      options={this.socialMediaOptions}
                      onChange={this.selectSocial}
                      value={this.state.selectedSocial}
                      placeholder={placeholder}
                      isSearchable={false}
                    />
                  }
                </FormattedMessage>
                {this.state.linkErrorText && (
                  <LinkError>
                    <FormattedMessage id="siteBanner.linkErrorText" />
                  </LinkError>
                )}
                <Button
                  onClick={this.addSocialLink}
                  style={{ margin: "10px 0px", width: "140px" }}
                  primary
                >
                  <FormattedMessage id="siteBanner.addSocialLink" />
                </Button>
              </Links>

              <ExplanatoryText>
                <TextInput
                  headline
                  onChange={this.updateTitle}
                  value={this.state.title}
                  maxLength={21}
                  type="text"
                />
                <TextArea
                  description
                  onChange={this.updateDescription}
                  value={this.state.description}
                  maxLength={330}
                  type="text"
                />
              </ExplanatoryText>
            </Content>
          </Template>
        </Editor>
      </IntlProvider>
    );
  }
}

export function renderBannerEditor(
  values,
  preferredCurrency,
  conversionRate,
  channelBanners,
  mode,
  publisherId
) {
  let props = {
    values: values,
    preferredCurrency: preferredCurrency,
    conversionRate: conversionRate,
    channelBanners: channelBanners,
    mode: mode,
    publisherId: publisherId,
  };

  ReactDOM.render(
    <ThemeProvider theme={Theme}>,
      <BannerEditor {...props} />,
    </ThemeProvider>,
    document.getElementById("rewards-banner-container").parentElement
      .parentElement
  );
}
