import React from 'react'

import BatsBackground from '../../assets/images/bg_bats.svg'
import HeartsBackground from '../../assets/images/bg_hearts.svg'
import { BatColorIcon, YoutubeColorIcon, TwitterColorIcon, TwitchColorIcon } from 'brave-ui/components/icons'
import Checkbox from 'brave-ui/components/formControls/checkbox'

import {styles} from '../packs/brave_rewards_banner.style.jsx'

export default class BraveRewardsBanner extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      title: 'Your title',
      description: 'Welcome to Brave Rewards banner',
      backgroundImage: null,
      backgroundImageData: '',
      logoImage: null,
      logoImageData: '',
      youtube: '',
      twitter: '',
      twitch: '',
      conversionRate: 0.2,
      donationAmounts: [1, 5, 10],
      mode: 'Edit',
      width: '1320'
    }
     this.handleBackgroundImageUpload = this.handleBackgroundImageUpload.bind(this);
     this.handleLogoImageUpload = this.handleLogoImageUpload.bind(this);
     this.updateTitle = this.updateTitle.bind(this);
     this.updateDescription = this.updateDescription.bind(this)
     this.handleSave = this.handleSave.bind(this);
     this.fetchSiteBanner = this.fetchSiteBanner.bind(this);
     this.updateYoutube = this.updateYoutube.bind(this);
     this.updateTwitter = this.updateTwitter.bind(this);
     this.updateTwitch = this.updateTwitch.bind(this);
     this.fetchSiteBanner = this.fetchSiteBanner.bind(this);
     this.updateWindowDimensions = this.updateWindowDimensions.bind(this);
  }

  componentDidMount(){
    this.modalize();
    this.fetchSiteBanner();
    document.getElementsByClassName('brave-rewards-banner-control-bar-save-button')[0].addEventListener("click", this.handleSave);
    window.addEventListener('resize', this.updateWindowDimensions);
  }

  updateWindowDimensions() {
    if(window.innerWidth < 991){
      this.close();
    }
    else{
      this.setState({ width: 1320});
    }
}

  modalize(){
    document.getElementsByClassName("modal-panel")[0].style.maxWidth = 'none';
    document.getElementsByClassName("modal-panel")[0].style.padding = '0px';
    document.getElementsByClassName("modal-panel--content")[0].style.padding = '0px';
  }

  close(){
    document.getElementsByClassName("modal-panel--close js-deny")[0].click();
  }

  fetchSiteBanner(){
    let that = this
    let id = document.getElementsByClassName('container')[0].id
    let url = '/publishers/' + id + "/site_banners/fetch";

    fetch(url, {
      method: 'GET',
      headers: {
        'Accept': 'text/html',
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': document.head.querySelector("[name=csrf-token]").content
        },
        credentials: "same-origin",
        }).then(function(response) {
          return response.json();
        })
        .then(function(banner) {
          that.setState({
            title: banner.title,
            description: banner.description,
            backgroundImage: banner.backgroundImage,
            logoImage: banner.logoImage,
            youtube: banner.social_links.youtube,
            twitter: banner.social_links.twitter,
            twitch: banner.social_links.twitch,
            donationAmounts: banner.donation_amounts,
          })
          console.log(banner);
        });
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
    temp[index] = event.target.value
    this.setState({donationAmounts: temp})
  }

  handleBackgroundImageUpload(event) {
    if (!event.target.files[0]) {
      return
    }
    this.setState({backgroundImage: URL.createObjectURL(event.target.files[0]), backgroundImageData: event.target})
  }

  handleLogoImageUpload(event) {
    if (!event.target.files[0]) {
      return
    }
    this.setState({logoImage: URL.createObjectURL(event.target.files[0]), logoImageData: event.target})
  }

  handleSave(event) {
    let that = this
    let id = document.getElementsByClassName('container')[0].id
    let url = '/publishers/' + id + "/site_banners/";
    let body = new FormData();

    body.append('title', this.state.title);
    body.append('description', this.state.description);
    body.append('donation_amounts', JSON.stringify(this.state.donationAmounts));
    body.append('social_links', JSON.stringify({youtube: this.state.youtube, twitter: this.state.twitter, twitch: this.state.twitch}));

    fetch(url, {
      method: 'POST',
      headers: {
            'Accept': 'text/html',
            'X-Requested-With': 'XMLHttpRequest',
            'X-CSRF-Token': document.head.querySelector("[name=csrf-token]").content
          },
          credentials: "same-origin",
          body: body
        }).then (
          function(response) {
            function submitById(id, suffix) {

            const url = '/publishers/' + document.getElementsByClassName('container')[0].id + "/site_banners/update_" + suffix;

            let file

            if(suffix === 'background_image'){ file = that.state.backgroundImageData }
            else if(suffix === 'logo'){ file = that.state.logoImageData }

            if (file === "" || file === null) { return; }
              var reader = new FileReader();
              reader.readAsDataURL(file.files[0]);

              reader.onloadend = function () {
                const body = new FormData();
                body.append('image', reader.result);
                fetch(url, {
                  method: 'POST',
                  headers: {
                    'Accept': 'text/html',
                    'X-Requested-With': 'XMLHttpRequest',
                    'X-CSRF-Token': document.head.querySelector("[name=csrf-token]").content
                  },
                  credentials: "same-origin",
                  body: body
                });
              }
            }

            if (response.status === 200) {
              submitById("background-image-select-input", "background_image");
              submitById("logo-image-select-input", "logo");
            }
            }).then(
              function(response) {
                that.close();
              });
  }

  render() {

    let style = styles

    let logoImg
    let logoLabel
    let backgroundImageLabel
    let backgroundImg
    let donationsInput
    let explanatoryTitle
    let explanatoryDescription
    let socialLinkText

    let rewardsBanner = {
      maxWidth: this.state.width,
      height:'488px',
      overflow:'hidden'
    }



    if(this.props.mode === 'Edit'){
      logoLabel = { height:'100%', width:'100%', borderRadius: '50%', border: '2px dotted white', cursor:'pointer'}
      backgroundImageLabel = {height:'100%', width:'100%', border: '2px dotted white', cursor:'pointer'}

      explanatoryTitle = {width:'100%', height:'50px', backgroundColor: 'rgba(0, 0, 0, 0)', border: '1px solid lightGray', borderRadius: '4px', marginTop: '15px', fontSize: '32px', color: '#686978'}
      explanatoryDescription = {width:'100%', height:'150px', resize: 'none', backgroundColor: 'rgba(0, 0, 0, 0)', border:'1px solid lightGray', borderRadius: '4px', marginTop: '25px', fontSize: '22px', color: '#686978'}
      donationsInput = {backgroundColor: 'rgba(0, 0, 0, 0)', marginRight:'5px', border: '1px solid lightGray', borderRadius: '4px', color: 'white', height:'19px'}
      socialLinkText = {marginTop:'auto', marginBottom:'auto', borderBottom: '1px solid lightGray', borderTop: '1px solid rgba(0, 0, 0, 0)', borderLeft: '1px solid rgba(0, 0, 0, 0)', color: '#686978', width: '90px', fontSize: '15px', backgroundColor: 'rgba(0, 0, 0, 0)', borderRadius: '0px'}

      if(this.state.backgroundImage === null){
        backgroundImg = {height: '176px', padding: '10px', background: `url(${BatsBackground}) left top no-repeat, url(${HeartsBackground}) right top no-repeat, rgb(158, 159, 171)`}
      }
      else{
        backgroundImg = {height: '176px', padding: '10px', background: `linear-gradient(rgba(0, 0, 0, 0.5), rgba(0, 0, 0, 0.5)), url(${this.state.backgroundImage})`}
      }
      if(this.state.logoImage === null){
        logoImg = {position: 'absolute', top: '190px', left: '35px', borderRadius: '50%', width: '160px', height: '160px', border: '6px solid white', padding: '10px', backgroundColor:'#FB542B'}
      }
      else{
        logoImg = {position: 'absolute', top: '190px', left: '35px', borderRadius: '50%', width: '160px', height: '160px', border: '6px solid white', padding: '10px', background:`url(${this.state.logoImage})`}
      }
    }
    else{
      logoLabel = { height:'100%', width:'100%', borderRadius: '50%', border: 'none', pointerEvents: 'none'}
      backgroundImageLabel = {height:'100%', width:'100%', border: 'none', pointerEvents: 'none'}

      explanatoryTitle = {width:'100%', height:'50px', backgroundColor: 'rgba(0, 0, 0, 0)', border: '1px solid rgba(0, 0, 0, 0)', borderRadius: '4px', marginTop: '15px', fontSize: '32px', color: '#686978', userSelect:'none'}
      explanatoryDescription = {width:'100%', height:'150px', resize: 'none', backgroundColor: 'rgba(0, 0, 0, 0)', border:'1px solid rgba(0, 0, 0, 0)', borderRadius: '4px', marginTop: '25px', fontSize: '22px', color: '#686978', userSelect:'none'}
      donationsInput = {backgroundColor: 'rgba(0, 0, 0, 0)', marginRight:'5px', border: '1px solid rgba(0, 0, 0, 0)', borderRadius: '4px', color: 'white'}
      socialLinkText = {marginTop:'auto', marginBottom:'auto', borderBottom: '1px solid rgba(0, 0, 0, 0)', borderTop: '1px solid rgba(0, 0, 0, 0)', borderLeft: '1px solid rgba(0, 0, 0, 0)', color: '#686978', width: '90px', fontSize: '15px', backgroundColor: 'rgba(0, 0, 0, 0)', borderRadius: '0px', userSelect: 'none'}

      if(this.state.backgroundImage === null){
        backgroundImg = {height: '176px', padding: '10px', background: `url(${BatsBackground}) left top no-repeat, url(${HeartsBackground}) right top no-repeat, rgb(158, 159, 171)`}
      }
      else{
        backgroundImg = {height: '176px', padding: '10px', background: `url(${this.state.backgroundImage})`}
      }
      if(this.state.logoImage === null){
        logoImg = {position: 'absolute', top: '190px', left: '35px', borderRadius: '50%', width: '160px', height: '160px', border: '6px solid white', padding: '10px', backgroundColor:'#FB542B'}
      }
      else{
        logoImg = {position: 'absolute', top: '190px', left: '35px', borderRadius: '50%', width: '160px', height: '160px', border: '6px solid white', padding: '10px', background:`url(${this.state.logoImage})`}
      }
    }

    style.logoLabel = logoLabel
    style.backgroundImageLabel = backgroundImageLabel
    style.logoImg = logoImg
    style.backgroundImg = backgroundImg
    style.explanatoryTitle = explanatoryTitle
    style.explanatoryDescription = explanatoryDescription
    style.donationsInput = donationsInput
    style.socialLinkText = socialLinkText
    style.rewardsBanner = rewardsBanner

    return (
      <div style={style.rewardsBanner} className="brave-rewards-banner">

        <div className="brave-rewards-banner-logo" style={style.logoImg}>
          <input type="file" id="logoImageInput" style={style.imageInput} onChange={this.handleLogoImageUpload}/>
          <label className="brave-rewards-banner-logo" style={style.logoLabel} htmlFor="logoImageInput" >
          </label>
        </div>

        <div className="brave-rewards-banner-background-image" style={style.backgroundImg}>
        <input type="file" id="backgroundImageInput" style={style.imageInput} onChange={this.handleBackgroundImageUpload}  />
        <label style={style.backgroundImageLabel} htmlFor="backgroundImageInput"></label>
        </div>

        <div className="brave-rewards-banner-content" style={style.bannerContent}>

          <div className="brave-rewards-banner-content-social-links" style={style.socialLinks}>
          <div className="brave-rewards-banner-content-social-links-youtube" style={style.socialLink}>
          <YoutubeColorIcon/>
          <input onChange={this.updateYoutube} className="brave-rewards-banner-content-social-links-youtube" style={style.socialLinkText} readOnly={this.props.mode !== 'Edit'} type="text" value={this.state.youtube}/>
          </div>
          <div className="brave-rewards-banner-content-social-links-twitter" style={style.socialLink}>
          <TwitterColorIcon/>
          <input onChange={this.updateTwitter} className="brave-rewards-banner-content-social-links-twitter" style={style.socialLinkText} readOnly={this.props.mode !== 'Edit'} type="text" value={this.state.twitter}/>
          </div>
          <div className="brave-rewards-banner-content-social-links-twitch" style={style.socialLink}>
          <TwitchColorIcon/>
          <input onChange={this.updateTwitch} className="brave-rewards-banner-content-social-links-twitch" style={style.socialLinkText} readOnly={this.props.mode !== 'Edit'} type="text" value={this.state.twitch}/>
          </div>
          </div>

          <div className="brave-rewards-banner-content-explanatory-text" style={style.explanatoryText}>
            <input style={style.explanatoryTitle} onChange={this.updateTitle} readOnly={this.props.mode !== 'Edit'} value={this.state.title} className="brave-rewards-banner-content-explanatory-text-headline" type='text'/>
            <textarea style={style.explanatoryDescription} onChange={this.updateDescription} readOnly={this.props.mode !== 'Edit'} value={this.state.description} className="brave-rewards-banner-content-explanatory-text-headline" type='text'/>
          </div>

          <div className="brave-rewards-banner-content-donations" style={style.donations}>
            <BatColorIcon style={style.batIcon}/>

          <div className="brave-rewards-banner-content-donations-buttons" style={{height:'262px', marginLeft:'50px', paddingTop:'15px'}}>
          <div className="brave-rewards-banner-content-donations-label" style={{fontSize:'15px'}}>Donation Amount</div>
          <div className="brave-rewards-banner-content-donations-label" style={{fontSize:'12px'}}>Wallet Balance: 25 BAT</div>


          <div style={style.donationsButtonContainer}>
            <div className="brave-rewards-banner-content-donations-button" style={style.donationButton}>

              {
                this.props.mode === 'Edit'?
                <input style={style.donationsInput} onChange={(e) => this.updateDonationAmounts(e, 0)} value={this.state.donationAmounts[0]} className="brave-rewards-banner-content-explanatory-text-headline" maxLength="3" size="3" type='text'/>:
                (this.state.donationAmounts[0])
              }
              &nbsp;BAT
            </div>
          <div className="brave-rewards-banner-content-donations-converted" style={style.donationsConverted}>${(this.state.donationAmounts[0] * this.state.conversionRate).toFixed(2)} USD</div>
          </div>
          <div style={style.donationsButtonContainer}>
            <div className="brave-rewards-banner-content-donations-button" style={style.donationButton}>
              {
                this.props.mode === 'Edit'?
                <input style={style.donationsInput} onChange={(e) => this.updateDonationAmounts(e, 1)} value={this.state.donationAmounts[1]} className="brave-rewards-banner-content-explanatory-text-headline" maxLength="3" size="3" type='text'/>:
                (this.state.donationAmounts[1])
              }
              &nbsp;BAT

            </div>
          <div className="brave-rewards-banner-content-donations-converted" style={style.donationsConverted}>${(this.state.donationAmounts[1] * this.state.conversionRate).toFixed(2)} USD</div>
          </div>
          <div style={style.donationsButtonContainer}>
            <div className="brave-rewards-banner-content-donations-button" style={style.donationButton}>

              {
                this.props.mode === 'Edit'?
                <input style={style.donationsInput} onChange={(e) => this.updateDonationAmounts(e, 2)} value={this.state.donationAmounts[2]} className="brave-rewards-banner-content-explanatory-text-headline" maxLength="3" size="3" type='text'/>:
                (this.state.donationAmounts[2])
              }
              &nbsp;BAT

            </div>
          <div className="brave-rewards-banner-content-donations-converted" style={style.donationsConverted}>${(this.state.donationAmounts[2] * this.state.conversionRate).toFixed(2)} USD</div>
          </div>

          <div className="brave-rewards-banner-content-donations-checkbox" style={{paddingTop:'5px', marginLeft:'35px'}}>
          <Checkbox value={'Checkbox values', {monthly : true}} size={'small'} multiple={false} disabled={false} type={'dark'}>
            <div data-key='monthly'>Make this monthly</div>
          </Checkbox>
          </div>

          </div>


          </div>
        </div>

        <div className="brave-rewards-banner-bottom-bar" style={style.bottomBar}>
        <div className="brave-rewards-banner-content-donations-send"
        style={style.donationsCurrent}>
        CURRENTLY DONATING BAT MONTHLY
        </div>

        <div className="brave-rewards-banner-content-donations-send"
        style={style.donationsSend}>
        SEND MY DONATION
        </div>
        </div>

      </div>
    );
  }
}
