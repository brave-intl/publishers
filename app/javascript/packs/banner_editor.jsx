import React from 'react'
import ReactDOM from 'react-dom'
import AvatarEditor from 'react-avatar-editor'

import 'babel-polyfill';

import BannerPreview from '../packs/banner_preview.jsx'
import Navbar from '../packs/navbar.jsx'

import styled from 'styled-components'
import { Editor, Template, Content, Links, ExplanatoryText, Donations, Logo, Cover, Input, Label, Text, Caret, LinkInputWrapper, TextInput, DropdownToggle, Channel, Delete, Link, TextArea, DonationWrapper, Button, Opacity, Dialogue } from '../packs/style.jsx'

import DonationJar from '../../assets/images/icn-donation-jar@1x.png'
import Spinner from '../utils/spinner'

import { initLocale } from 'brave-ui'
import locale from 'locale/en'

import { BatColorIcon, YoutubeColorIcon, TwitterColorIcon, TwitchColorIcon, LoaderIcon } from 'brave-ui/components/icons'
import Checkbox from 'brave-ui/components/formControls/checkbox'
import Toggle from 'brave-ui/components/formControls/toggle'

import '../../assets/stylesheets/components/banner-editor.scss'
import '../../assets/stylesheets/components/spinner.scss'
import '../../assets/stylesheets/components/slider.scss'

export default class BannerEditor extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      loading: true,
      title: 'Brave Rewards',
      description: 'Thanks for stopping by. We joined Brave\'s vision of protecting your privacy because we believe that fans like you would support us in our effort to keep the web a clean and safe place to be. \n \nYour tip is much appreciated and it encourages us to continue to improve our content.',
      logo: {url: null, data: null},
      cover: {url: null, data: null},
      channelIndex: 0,
      channelBanners: this.props.channelBanners,
      defaultSiteBanner: this.props.defaultSiteBanner,
      defaultSiteBannerMode: this.props.defaultSiteBannerMode,
      scale: 1,
      linkSelection: false,
      linkOption: 'Youtube',
      currentLink: '',
      youtube: '',
      twitter: '',
      twitch: '',
      donationAmounts: [1, 5, 10],
      conversionRate: this.props.conversionRate,
      mode: 'Edit',
      view: 'editor-view',
      state: 'editor'
    }
     this.updateTitle = this.updateTitle.bind(this);
     this.preview = this.preview.bind(this);
     this.updateDescription = this.updateDescription.bind(this);
     this.save = this.save.bind(this);
     this.toggleDefaultSiteBannerMode = this.toggleDefaultSiteBannerMode.bind(this);
     this.incrementChannelIndex = this.incrementChannelIndex.bind(this);
     this.decrementChannelIndex = this.decrementChannelIndex.bind(this);
     this.updateYoutube = this.updateYoutube.bind(this);
     this.updateTwitter = this.updateTwitter.bind(this);
     this.updateTwitch = this.updateTwitch.bind(this);
     this.updateWindowDimensions = this.updateWindowDimensions.bind(this);
  }

  componentWillMount(){
    this.modalize();
  }

  componentDidMount(){
    this.fetchBanner();
    this.setSpinner();
    this.cleanup();
    window.addEventListener('resize', this.updateWindowDimensions);
  }

  updateWindowDimensions() {
    if(window.innerWidth < 991){
      this.close();
    }
}

  modalize(){
    document.getElementsByClassName("modal-container")[0].style.overflow = 'scroll';
    document.getElementsByClassName("modal-panel")[0].style.maxWidth = 'none';
    document.getElementsByClassName("modal-panel")[0].style.padding = '0px';
    document.getElementsByClassName("modal-panel--content")[0].style.padding = '0px';
  }

  close(){
    document.getElementsByClassName("modal-panel")[0].style.maxWidth = '40rem';
    document.getElementsByClassName("modal-panel")[0].style.padding = '2rem 2rem';
    document.getElementsByClassName("modal-panel--content")[0].style.padding = '1rem 1rem 0 1rem';
    document.getElementsByClassName("modal-panel--close js-deny")[0].click();
  }

  cleanup(){
    document.getElementsByClassName("modal-panel--close js-deny")[0].style.visibility = 'hidden'
    document.getElementById("banner-toggle").style.cursor = "pointer"
  }

  preview(){

    let div = document.createElement("div");
    div.id = "preview-container";
    let PreviewContainer = document.body.appendChild(div);

    ReactDOM.render(
      <BannerPreview {...this.state}/>,
      PreviewContainer
    )
    this.close();
  }

  setSpinner(){
    Spinner.show('spinner', 'spinner-container');
  }

  setEditorRef = (editor) => this.editor = editor

  handleZoom(e){
    this.setState({scale: e.target.value})
  }

  apply(){

    let that = this;
    let logo = this.state.logo;
    let cover = this.state.cover;
    let img = this.editor.getImage();

    switch(this.state.state){
      case 'logo':

        let logoCanvas = document.createElement('canvas');
        logoCanvas.width = 480; logoCanvas.height = 480;
        var ctx = logoCanvas.getContext('2d');
        ctx.drawImage(img, 0, 0, 480, 480);
        logo.url = logoCanvas.toDataURL('image/jpeg', 1);

        //Generate data to save
        logoCanvas.toBlob(function(blob){
          let file = {};
          file["files"] = [blob]
          logo.data = file;
          that.setState({logo: logo, scale: 1, state: 'editor'})
        });
        break;
      case 'cover':

        let coverCanvas = document.createElement('canvas');
        coverCanvas.width = 2700; coverCanvas.height = 528;
        var ctx = coverCanvas.getContext('2d');
        ctx.drawImage(img, 0, 0, 2700, 528);
        cover.url = coverCanvas.toDataURL('image/jpeg', 1);

        //Generate data to save
        coverCanvas.toBlob(function(blob){
          let file = {};
          file["files"] = [blob]
          cover.data = file;
          that.setState({cover: cover, scale: 1, state: 'editor'})
        });
        break;
    }
  }

  addLogo(event){
    let temp = URL.createObjectURL(event.target.files[0])
    this.setState({
      tempLogo: temp, state:'logo'
    })
  }

  addCover(event){
    let temp = URL.createObjectURL(event.target.files[0])
    this.setState({
      tempCover: temp, state:'cover'
    })
  }

  async fetchBanner(){

    let that = this
    let url = "/publishers/" + document.getElementById("publisher_id").value + "/site_banners/"
    this.state.defaultSiteBannerMode ? url += this.props.defaultSiteBanner.id : url += this.props.channelBanners[this.state.channelIndex].id

    let options = {
      method: 'GET',
      credentials: "same-origin",
      headers: {'Accept': 'text/html', 'X-Requested-With': 'XMLHttpRequest', 'X-CSRF-Token': document.head.querySelector("[name=csrf-token]").content},
    }

    let response = await fetch(url, options);
    let banner = await response.json();

    //500ms timeout prevents quick flash when load times are fast.
    setTimeout(async() => {

      if(banner){
        that.setState({
          title: banner.title,
          description: banner.description,
          youtube: banner.socialLinks.youtube,
          twitter: banner.socialLinks.twitter,
          twitch: banner.socialLinks.twitch,
          donationAmounts: banner.donationAmounts,
          logo: {url: banner.logoImage, data: null},
          cover: {url: banner.backgroundImage, data: null},
          loading: false
        });
      }

      else{
        that.setState({loading: false})
      }
      if(this.props.mode === 'Preview'){
        this.preview();
      }
    }, 500);
  }

  handleLinkSelection(e){
    let toggle = document.getElementById("toggle");
      if(e.target === toggle){
        this.setState({linkSelection: !this.state.linkSelection})
      }
      else{
        this.setState({linkSelection: false})
      }
  }

  addLink(){
    switch(this.state.linkOption){
      case 'Youtube':
        this.setState({youtube: this.state.currentLink})
        break;
      case 'Twitter':
        this.setState({twitter: this.state.currentLink})
        break;
      case 'Twitch':
        this.setState({twitch: this.state.currentLink})
        break;
    }
    this.setState({currentLink: ''})
  }

  handleLinkDelete(option){
    switch(option){
      case 'Youtube':
        this.setState({youtube: ''})
        break;
      case 'Twitter':
        this.setState({twitter: ''})
        break;
      case 'Twitch':
        this.setState({twitch: ''})
        break;
    }
  }

  handleLinkOption(value){
    this.setState({linkOption: value})
  }

  updateCurrentLink(event){
    this.setState({currentLink: event.target.value})
  }

  updateTitle(event){
     this.setState({title: event.target.value})
  }

  updateDescription(event){
     this.setState({description: event.target.value})
  }

  updateYoutube(event){
     this.setState({youtube: event.target.value})
  }

  updateTwitter(event){
     this.setState({twitter: event.target.value})
  }

  updateTwitch(event){
     this.setState({twitch: event.target.value})
  }

  updateDonationAmounts(event, index){
    let temp = this.state.donationAmounts
    if(/^(\s*|\d+)$/.test(event.target.value)){
      temp[index] = event.target.value
      this.setState({donationAmounts: temp})
    }
  }

  renderDialogue(){
    let dialogue;

    switch(this.state.state){
      case 'logo':
        dialogue =
        <div>
          <Opacity/>
          <Dialogue logo>
            <Text dialogueHeader>Resize and position your logo</Text>
            <AvatarEditor ref={this.setEditorRef} image={this.state.tempLogo} width={180} height={180} border={20} borderRadius={160} color={[230, 236, 240, 0.6]} scale={this.state.scale} style={{marginTop: '20px', cursor: 'move'}}/>
            <br/>
            <input style={{width: '120px', textAlign:'center', marginTop: '30px', marginBottom: '40px'}} onChange={ (e) => this.handleZoom(e) } type="range" value={this.state.scale} min={1} max={2} step={0.01}/>
            <br/>
            <Button onClick={ () => this.setState({state: 'Editor'}) } style={{margin:'10px', width:'120px'}} outline>Cancel</Button>
            <Button onClick={ () => this.apply() } style={{margin:'10px', width:'120px'}} primary>Apply</Button>
          </Dialogue>
        </div>
        break;
      case 'cover':
        dialogue =
        <div>
          <Opacity/>
          <Dialogue cover>
            <Text dialogueHeader>Resize and position your cover image</Text>
            <AvatarEditor ref={this.setEditorRef} image={this.state.tempCover} width={450} height={88} border={20} color={[230, 236, 240, 0.6]} scale={this.state.scale} style={{marginTop: '20px', cursor: 'move'}}/>
            <br/>
            <input style={{width: '120px', textAlign:'center', marginTop: '30px', marginBottom: '40px'}} onChange={ (e) => this.handleZoom(e) } type="range" value={this.state.scale} min={1} max={2} step={0.01}/>
            <br/>
            <Button onClick={ () => this.setState({state: 'Editor'}) } style={{margin:'10px', width:'120px'}} outline>Cancel</Button>
            <Button onClick={ () => this.apply() } style={{margin:'10px', width:'120px'}} primary>Apply</Button>
          </Dialogue>
        </div>
        break;
      case 'save':
        dialogue =
        <div>
          <Opacity/>
          <Dialogue id='save-container' save>
            { this.state.saving === false &&
              <div>
                <Text dialogueHeader>Your banner will be updated in two hours</Text>
                <Text dialogueSubtext>Your updated banner will be presented to Brave users in two hours.</Text>
                <Button dialoguePrimary onClick={ () => this.setState({state: 'Editor'}) }>OK</Button>
              </div>
            }
          </Dialogue>
        </div>
        break;
      case 'same':
        dialogue =
        <div>
          <Opacity/>
          <Dialogue save>
            <Text dialogueHeader>Use one banner for all channels?</Text>
            <Text dialogueSubtext>Your customized banner will be displayed on all of your channels.</Text>
            <div style={{marginTop: '40px', textAlign: 'center'}}>
            <Button onClick={ () => this.setState({state: 'Editor'}) } style={{margin:'10px', width:'120px'}} outline>Cancel</Button>
            <Button onClick={ async() => {
              let toggle = await this.setDefaultSiteBannerMode(true);
              this.setState({defaultSiteBannerMode: !this.state.defaultSiteBannerMode, state: 'Editor', loading: true},
              () => { this.fetchBanner() });
            }}
            style={{margin:'10px', width:'120px'}} primary>Continue</Button>
            </div>
          </Dialogue>
        </div>
        break;
    }
    return dialogue;

  }

  renderLinkInput(){
    return (this.state.youtube === '' || this.state.twitter === '' || this.state.twitch === '')
  }

  renderLoadingScreen(){
    let visibility = 'hidden';
    if(this.state.loading === true){
      visibility = 'visible';
    }
      return <div style={{width:'100%', height:'744px', position:'absolute', zIndex:'20000', backgroundColor:'rgba(233, 240, 255, 1)', borderRadius: '8px', visibility: visibility}}>
        <div style={{width:'100%', marginTop:'auto', marginBottom:'auto', position:'absolute', left:'0', right:'0', top:'300px', bottom:'0'}} id="spinner-container"></div>
      </div>
  }

  renderIcon(option){
    switch(option) {
      case 'Youtube':
        return <YoutubeColorIcon style={{height:'30px', width:'30px', display:'inline', marginBottom:'4px', cursor:'pointer'}}/>
      case 'Twitter':
        return <TwitterColorIcon style={{height:'30px', width:'30px', display:'inline', marginBottom:'4px', cursor:'pointer'}}/>
      case 'Twitch':
        return <TwitchColorIcon style={{height:'30px', width:'30px', display:'inline', marginBottom:'4px', cursor:'pointer'}}/>
    }
  }

  renderLinks(){
    return <div>
      {
        this.state.youtube !== '' &&
        <Link>
          <YoutubeColorIcon className="banner-link-option" style={{height:'25px', width:'25px', display:'inline-block', marginBottom:'12px'}}/>
          <Channel>{this.state.youtube}
            <Delete onClick={ () => this.handleLinkDelete('Youtube') }>(X)</Delete>
          </Channel>
        </Link>
      }
      {
        this.state.twitter !== '' &&
        <Link>
          <TwitterColorIcon className="banner-link-option" style={{height:'25px', width:'25px', display:'inline-block', marginBottom:'12px'}}/>
          <Channel>{this.state.twitter}
            <Delete onClick={ () => this.handleLinkDelete('Twitter') }>(X)</Delete>
          </Channel>
        </Link>
      }
      {
        this.state.twitch !== '' &&
        <Link>
          <TwitchColorIcon className="banner-link-option" style={{height:'25px', width:'25px', display:'inline-block', marginBottom:'12px'}}/>
          <Channel>{this.state.twitch}
            <Delete onClick={ () => this.handleLinkDelete('Twitch') }>(X)</Delete>
          </Channel>
        </Link>
      }
    </div>
  }

  renderDropdown(){

      if(this.state.linkSelection){
        return (
          <div style={{position:'absolute', backgroundColor:'white', height:'100px', width:'55px', borderRadius:'4px', marginLeft:'11px', paddingTop:'5px', marginTop:'5px', border: '1px solid lightGray', boxShadow: '0 3px 4px rgba(0,0,0,0.16), 0 3px 4px rgba(0,0,0,0.23)'}}>
            <div onClick={ () => this.handleLinkOption('Youtube') } className="banner-link-option" style={{textAlign:'center', margin:'2px', cursor:'pointer'}}>
              <YoutubeColorIcon style={{height:'25px', width:'25px', margin:'auto'}}/>
            </div>
            <div onClick={ () => this.handleLinkOption('Twitter') } className="banner-link-option" style={{textAlign:'center', margin:'2px', cursor:'pointer'}}>
              <TwitterColorIcon style={{height:'25px', width:'25px', margin:'auto'}}/>
            </div>
            <div onClick={ () => this.handleLinkOption('Twitch') } className="banner-link-option" style={{textAlign:'center', margin:'2px', cursor:'pointer'}}>
              <TwitchColorIcon style={{height:'25px', width:'25px', margin:'auto'}}/>
            </div>
          </div>
        )
      }
  }

  async save() {
    this.setState({state: 'save', saving: 'true'}, () => Spinner.show('save-spinner', 'save-container'))

    let url = '/publishers/' + document.getElementById("publisher_id").value + "/site_banners/"
    this.state.defaultSiteBannerMode ? url += this.props.defaultSiteBanner.id : url += this.props.channelBanners[this.state.channelIndex].id;

    let body = new FormData();
    body.append('title', this.state.title);
    body.append('description', this.state.description);
    body.append('donation_amounts', JSON.stringify(this.state.donationAmounts));
    body.append('social_links', JSON.stringify({youtube: this.state.youtube, twitter: this.state.twitter, twitch: this.state.twitch}));

    if(this.state.logo.data){
      let logo = await this.readData(this.state.logo.data);
      body.append('logo', logo);
    }
    if(this.state.cover.data){
      let cover = await this.readData(this.state.cover.data);
      body.append('cover', cover);
    }

    let options = {
      method: 'PUT',
      credentials: "same-origin",
      headers: {'Accept': 'text/html', 'X-Requested-With': 'XMLHttpRequest', 'X-CSRF-Token': document.head.querySelector("[name=csrf-token]").content},
      body: body
    }

    let save = await fetch(url, options)

    document.getElementById('save-spinner').remove();
    this.setState({saving: false});

  }

  readData(file) {
    let reader = new FileReader();
    reader.readAsDataURL(file.files[0])
    return new Promise(resolve =>
      reader.onloadend = function () {
        resolve(reader.result);
      });
  }

  incrementChannelIndex(){
    this.setState((prevState) => { return { channelIndex: (prevState.channelIndex += 1), loading: true }},
    () => {this.fetchBanner()})
  }

  decrementChannelIndex(){
    this.setState((prevState) => { return { channelIndex: (prevState.channelIndex -= 1), loading: true }},
    () => {this.fetchBanner()})
  }

  async toggleDefaultSiteBannerMode(){
    if(this.state.defaultSiteBannerMode === true){
      let toggle = await this.setDefaultSiteBannerMode(false)
      this.setState({defaultSiteBannerMode: !this.state.defaultSiteBannerMode, loading: true},
      () => { this.fetchBanner() })
    }
    else{
      this.setState({state: 'same'});
    }
  }

  async setDefaultSiteBannerMode(value){
    let url = '/publishers/' + document.getElementById("publisher_id").value + "/site_banners/set_default_site_banner_mode?dbm=" + value
    let options = {
      method: 'POST',
      credentials: "same-origin",
      headers: {'Accept': 'text/html', 'X-Requested-With': 'XMLHttpRequest', 'X-CSRF-Token': document.head.querySelector("[name=csrf-token]").content}
    }
    let response = await fetch(url, options);
  }

  render() {

    initLocale(locale);

    return (
      <Editor onClick={ (e) => this.handleLinkSelection(e) }>
        {this.renderLoadingScreen()}
        {this.renderDialogue()}

        <Navbar defaultSiteBanner={this.props.defaultSiteBanner} channelBanners={this.props.channelBanners} channelIndex={this.state.channelIndex} defaultSiteBannerMode={this.state.defaultSiteBannerMode} incrementChannelIndex={this.incrementChannelIndex} decrementChannelIndex={this.decrementChannelIndex} toggleDefaultSiteBannerMode={this.toggleDefaultSiteBannerMode} save={this.save} close={this.close} preview={ this.preview }/>

        <Template>
          <Logo url={this.state.logo.url}>
            <Input type="file" id="logoInput" onChange={ (e) => this.addLogo(e) }/>
            <Label logo htmlFor="logoInput"/>
          </Logo>

          <Cover url={this.state.cover.url}>
            <Input type="file" id="backgroundInput" onChange={ (e) => this.addCover(e) }/>
            <Label htmlFor="backgroundInput"/>
          </Cover>

          <Content>
            <Links>
              <Text links>Links</Text>

              {this.renderLinks()}

              {
                this.renderLinkInput() &&
                 <LinkInputWrapper>
                   <DropdownToggle>
                     {this.renderIcon(this.state.linkOption)}
                     <Caret onClick={ (e) => this.toggleDropdown(e) }  id='toggle'>&#9662;</Caret>
                  </DropdownToggle>
                  <TextInput link onChange={ (e) => this.updateCurrentLink(e) } value={this.state.currentLink} maxLength={80}/>
                    {this.renderDropdown()}
                  <Text add onClick={ () => this.addLink() }>+ Add Link</Text>

                 </LinkInputWrapper>
              }

            </Links>

            <ExplanatoryText>
              <TextInput headline onChange={this.updateTitle} value={this.state.title} maxLength={21} type='text'/>
              <TextArea description onChange={this.updateDescription} value={this.state.description} maxLength={330} type='text'/>
            </ExplanatoryText>

            <Donations>
              <Text donations>Tip amounts</Text>
              <DonationWrapper>
                <Button donation>
                  <BatColorIcon style={{display:'inline', height:'25px', width:'25px', marginRight:'10px'}}/>
                  <Text donationAmount>{this.state.donationAmounts[0]}</Text>
                  <Text BAT>BAT</Text>
                </Button>
                  <Text convertedAmount>{(this.state.donationAmounts[0] * this.props.conversionRate).toFixed(2)} {this.props.preferredCurrency}</Text>
              </DonationWrapper>
              <DonationWrapper>
                <Button donation>
                  <BatColorIcon style={{display:'inline', height:'25px', width:'25px', marginRight:'10px'}}/>
                  <Text donationAmount>{this.state.donationAmounts[1]}</Text>
                  <Text BAT>BAT</Text>
                </Button>
                  <Text convertedAmount>{(this.state.donationAmounts[1] * this.props.conversionRate).toFixed(2)} {this.props.preferredCurrency}</Text>
              </DonationWrapper>
              <DonationWrapper>
                <Button donation>
                  <BatColorIcon style={{display:'inline', height:'25px', width:'25px', marginRight:'10px'}}/>
                  <Text donationAmount>{this.state.donationAmounts[2]}</Text>
                  <Text BAT>BAT</Text>
                </Button>
                  <Text convertedAmount>{(this.state.donationAmounts[2] * this.props.conversionRate).toFixed(2)} {this.props.preferredCurrency}</Text>
              </DonationWrapper>
            </Donations>
          </Content>

        </Template>
      </Editor>
    )
  }
}

export function renderBannerEditor(preferredCurrency, conversionRate, defaultSiteBannerMode, defaultSiteBanner, channelBanners, mode) {

  let props = {
    preferredCurrency: preferredCurrency,
    conversionRate: conversionRate,
    defaultSiteBannerMode: defaultSiteBannerMode,
    defaultSiteBanner: defaultSiteBanner,
    channelBanners: channelBanners,
    mode: mode
  }

  ReactDOM.render(
    <BannerEditor {...props}/>,
    document.getElementById("rewards-banner-container").parentElement.parentElement
  )
}
