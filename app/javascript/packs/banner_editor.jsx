import React from 'react'
import ReactDOM from 'react-dom'

import BannerPreview from '../packs/banner_preview.jsx'

import DonationJar from '../../assets/images/icn-donation-jar@1x.png'
import BatsBackground from '../../assets/images/bg_bats.svg'
import HeartsBackground from '../../assets/images/bg_hearts.svg'

import { initLocale } from 'brave-ui'
import locale from 'locale/en'

import { BatColorIcon, YoutubeColorIcon, TwitterColorIcon, TwitchColorIcon } from 'brave-ui/components/icons'
import Checkbox from 'brave-ui/components/formControls/checkbox'
import Toggle from 'brave-ui/components/formControls/toggle'

import {styles} from '../packs/brave_rewards_banner.style.jsx'
import '../../assets/stylesheets/components/banner-editor.scss'

export default class BannerEditor extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      title: 'Your title',
      description: 'Welcome to Brave Rewards banner',
      backgroundImage: null,
      backgroundImageData: '',
      logoImage: null,
      logoImageData: '',
      linkSelection: false,
      linkOption: 'Youtube',
      currentLink: '',
      youtube: '',
      twitter: '',
      twitch: '',
      donationAmounts: [1, 5, 10],
      conversionRate: this.props.conversionRate,
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

  componentWillMount(){
    this.modalize();
  }

  componentDidMount(){
    this.fetchSiteBanner();
    // this.cleanup();
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
    document.getElementsByClassName("modal-panel")[0].style.maxWidth = '40rem';
    document.getElementsByClassName("modal-panel")[0].style.padding = '2rem 2rem';
    document.getElementsByClassName("modal-panel--content")[0].style.padding = '1rem 1rem 0 1rem';
    document.getElementsByClassName("modal-panel--close js-deny")[0].click();
  }

  cleanup(){
    document.getElementsByClassName("sc-eilVRo gUSzmU")[0].remove();
  }

  fetchSiteBanner(){
    let that = this
    let id = document.getElementById("publisher_id").value;
    let url = '/publishers/' + id + "/site_banners/fetch";

    fetch(url, {
      method: 'GET',
      headers: {
        'Accept': 'text/html',
        'X-Requested-With': 'XMLHttpRequest'
        },
        credentials: "same-origin",
        }).then(function(response) {
          return response.json();
        })
        .then(function(banner) {
          if(Object.keys(banner).length === 0 && banner.constructor === Object){
            return;
          }
          else{
            that.setState({
              title: banner.title,
              description: banner.description,
              youtube: banner.socialLinks.youtube,
              twitter: banner.socialLinks.twitter,
              twitch: banner.socialLinks.twitch,
              donationAmounts: banner.donationAmounts,
            })
            that.cropFetchedLogo(banner.logoImage, that);
            that.cropFetchedBackgroundImage(banner.backgroundImage, that)
          }
        });
  }

  handlePreview(){

    let div = document.createElement("div");
    div.id = "preview-container";
    let PreviewContainer = document.body.appendChild(div);

    ReactDOM.render(
      <BannerPreview {...this.state}/>,
      PreviewContainer
    )
    this.close();
  }

  handleLinkSelection(e){
    let toggle = document.getElementsByClassName("banner-link-selection-toggle")[0];
      if(e.target === toggle){
        this.setState({linkSelection: !this.state.linkSelection})
      }
      else{
        this.setState({linkSelection: false})
      }
  }

  handleLinkSubmit(){
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

  handleBackgroundImageUpload(event) {
    let that = this;
    this.cropBackgroundImage(event, that);
  }

  handleLogoImageUpload(event) {
    let that = this;
    this.cropLogo(event, that);
  }

  cropFetchedBackgroundImage(backgroundImage, that){
    let img = new Image();
    img.crossOrigin = "Anonymous";
    img.src = backgroundImage;
    img.onload = function() {
      var canvas = document.createElement('canvas');
      var ctx = canvas.getContext('2d');
      canvas.width = 1200;
      canvas.height = 176;
      ctx.drawImage(img, 0, 0, canvas.width, canvas.height);
      let url = canvas.toDataURL('image/jpg', 1);
      that.setState({backgroundImage: url});
    }
  }

  cropBackgroundImage(event, that){
    if (event.target.files && event.target.files[0]) {
      var filerdr = new FileReader();

      filerdr.onload = function(e) {
        var img900 = new Image();
        var img1200 = new Image();

      img1200.onload = function() {
        var canvas = document.createElement('canvas');
        var ctx = canvas.getContext('2d');
        canvas.width = 900;
        canvas.height = 176;
        ctx.drawImage(img900, 0, 0, canvas.width, canvas.height);
        canvas.toBlob(function(blob){
          let file = {};
          file["files"] = [blob]
          that.setState({backgroundImageData: file});
        });
      }

      img900.onload = function() {
        var canvas = document.createElement('canvas');
        var ctx = canvas.getContext('2d');
        canvas.width = 1200;
        canvas.height = 176;
        ctx.drawImage(img1200, 0, 0, canvas.width, canvas.height);
        let url = canvas.toDataURL('image/jpg', 1);
        that.setState({backgroundImage: url});
      }

      img900.src = e.target.result;
      img1200.src = e.target.result;
    }
    filerdr.readAsDataURL(event.target.files[0]);
  }
  }

  cropFetchedLogo(logo, that){
    let img = new Image();
    img.crossOrigin = "Anonymous";
    img.src = logo;
    img.onload = function() {
      var canvas = document.createElement('canvas');
      var ctx = canvas.getContext('2d');
      canvas.width = 160;
      canvas.height = 160;
      ctx.drawImage(img, 0, 0, canvas.width, canvas.height);
      let url = canvas.toDataURL('image/jpeg', 1);
      that.setState({logoImage: url});
    }
  }

  cropLogo(event, that){
    if (event.target.files && event.target.files[0]) {
      var filerdr = new FileReader();

      filerdr.onload = function(e) {
        var img160 = new Image();
        var img480 = new Image();

      img480.onload = function() {
        var canvas = document.createElement('canvas');
        var ctx = canvas.getContext('2d');
        canvas.width = 480;
        canvas.height = 480;
        ctx.drawImage(img480, 0, 0, canvas.width, canvas.height);
        canvas.toBlob(function(blob){
          let file = {};
          file["files"] = [blob]
          that.setState({logoImageData: file});
        });
      }

      img160.onload = function() {
        var canvas = document.createElement('canvas');
        var ctx = canvas.getContext('2d');
        canvas.width = 160;
        canvas.height = 160;
        ctx.drawImage(img160, 0, 0, canvas.width, canvas.height);
        let url = canvas.toDataURL('image/jpeg', 1);
        that.setState({logoImage: url});
      }

      img160.src = e.target.result;
      img480.src = e.target.result;
    }
    filerdr.readAsDataURL(event.target.files[0]);
  }
  }

  renderLinkOption(option){
    switch(option) {
      case 'Youtube':
        return <YoutubeColorIcon className="banner-link-option" style={{height:'25px', width:'25px', display:'inline', margin:'auto', cursor:'pointer'}}/>
      case 'Twitter':
        return <TwitterColorIcon className="banner-link-option" style={{height:'25px', width:'25px', display:'inline', margin:'auto', cursor:'pointer'}}/>
      case 'Twitch':
        return <TwitchColorIcon className="banner-link-option" style={{height:'25px', width:'25px', display:'inline', margin:'auto', cursor:'pointer'}}/>
    }
  }

  renderLinks(){
    return <div>
      {
        this.state.youtube !== '' && <div style={{marginTop:'10px', marginBottom:'10px'}}>
          <YoutubeColorIcon className="banner-link-option" style={{height:'25px', width:'25px', display:'inline-block', marginBottom:'10px'}}/>
          <p style={{display:'inline-block', paddingLeft:'5px', maxWidth:'200px', margin:'auto', overflow:'hidden', whiteSpace:'nowrap', textOverflow:'ellipsis'}}>{this.state.youtube}</p>
          <p onClick={ () => this.handleLinkDelete('Youtube') } style={{display:'inline', paddingLeft:'5px', cursor:'pointer', fontSize:'.85rem', color:'#7d7bdc'}}>(X)</p>
        </div>
      }
      {
        this.state.twitter !== '' && <div style={{marginTop:'10px', marginBottom:'10px'}}>
          <TwitterColorIcon className="banner-link-option" style={{height:'25px', width:'25px', display:'inline-block', marginBottom:'10px'}}/>
          <p style={{display:'inline-block', paddingLeft:'5px', maxWidth:'200px', margin:'auto', overflow:'hidden', whiteSpace:'nowrap', textOverflow:'ellipsis'}}>{this.state.twitter}</p>
          <p onClick={ () => this.handleLinkDelete('Twitter') } style={{display:'inline', paddingLeft:'5px', cursor:'pointer', fontSize:'.85rem', color:'#7d7bdc'}}>(X)</p>
        </div>
      }
      {
        this.state.twitch !== '' && <div style={{marginTop:'10px', marginBottom:'10px'}}>
          <TwitchColorIcon className="banner-link-option" style={{height:'25px', width:'25px', display:'inline-block', marginBottom:'10px'}}/>
          <p style={{display:'inline-block', paddingLeft:'5px', maxWidth:'200px', margin:'auto', overflow:'hidden', whiteSpace:'nowrap', textOverflow:'ellipsis'}}>{this.state.twitch}</p>
          <p onClick={ () => this.handleLinkDelete('Twitch') } style={{display:'inline', paddingLeft:'5px', cursor:'pointer', fontSize:'.85rem', color:'#7d7bdc'}}>(X)</p>
        </div>
      }
    </div>
  }

  handleSave(event) {
    let that = this
    let id = document.getElementById("publisher_id").value;
    let url = '/publishers/' + id + "/site_banners";
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

        const url = '/publishers/' + document.getElementById("publisher_id").value + "/site_banners/update_" + suffix;

        let file;
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
    initLocale(locale);
    let style = styles

    let rewardsBannerContainer = {width:'1200px'}

    let logoImg
    let logoLabel
    let backgroundImageLabel
    let backgroundImg
    let explanatoryTitle
    let explanatoryDescription
    let socialLinkText

    let rewardsBanner = {
      maxWidth: this.state.width,
      overflow:'hidden',
      borderBottomRightRadius: '8px',
      borderBottomLeftRadius: '8px'
    }

      logoLabel = { height:'100%', width:'100%', borderRadius: '50%', border: 'none', cursor:'pointer'}
      backgroundImageLabel = {height:'100%', width:'100%', border: 'none', cursor:'pointer', transition:'5s  ease-in-out'}

      explanatoryTitle = {width:'100%', height:'50px', backgroundColor: 'rgba(0, 0, 0, 0)', border: '1px solid lightGray', borderRadius: '4px', marginTop: '15px', fontSize: '38px', fontWeight:'bold', color: '#686978'}
      explanatoryDescription = {width:'100%', height:'200px', resize: 'none', backgroundColor: 'rgba(0, 0, 0, 0)', border:'1px solid lightGray', borderRadius: '4px', marginTop: '25px', fontSize: '22px', color: '#686978'}

      socialLinkText = {marginTop:'auto', marginBottom:'auto', borderBottom: '1px solid rgba(0, 0, 0, 0)', borderTop: '1px solid rgba(0, 0, 0, 0)', borderLeft: '1px solid rgba(0, 0, 0, 0)', color: '#686978', width: '90px', fontSize: '15px', backgroundColor: 'rgba(0, 0, 0, 0)', borderRadius: '0px', userSelect: 'none'}

      if(this.state.backgroundImage === null){
        backgroundImg = {height: '176px', background: `url(${BatsBackground}) left top no-repeat, url(${HeartsBackground}) right top no-repeat, rgb(158, 159, 171)`}
      }
      else{
        backgroundImg = {height: '176px', background: `url(${this.state.backgroundImage})`}
      }
      if(this.state.logoImage === null){
        logoImg = {position: 'absolute', top: '250px', left: '125px', borderRadius: '50%', width: '160px', height: '160px', border: '6px solid white', backgroundColor:'#FB542B'}
      }
      else{
        logoImg = {position: 'absolute', top: '250px', left: '125px', borderRadius: '50%', width: '160px', height: '160px', border: '6px solid white', background:`url(${this.state.logoImage})`}
      }

        let controlButton = {
          width: '150px',
          textAlign: 'center',
          borderRadius: '24px',
          padding: '9px 10px',
          fontSize: '14px',
          marginLeft:'20px',
          border: '1px solid #fc4145',
          color: '#fc4145',
          cursor: 'pointer',
          userSelect: 'none'
        }

        let saveButton = {
          width: '150px',
          backgroundColor: '#fc4145',
          color: 'white',
          textAlign: 'center',
          borderRadius: '24px',
          padding: '9px 10px',
          fontSize: '14px',
          marginLeft:'20px',
          border: '1px solid #fc4145',
          cursor: 'pointer',
          userSelect: 'none'
        }

        let socialLinksHeader = {
          color:'rgb(104, 105, 120)',
        }

        let donationHeader = {
          color:'#F1F1F9',
          paddingTop:'55px',
          textAlign:'center',
          paddingBottom: '20px',
          paddingRight: '32.5px'
        }

        let donationButton = {
          display: 'inline-block',
          width: '125px',
          textAlign: 'center',
          borderRadius: '24px',
          padding: '6px 7px',
          border: '1px solid #AAAFEF',
          color: '#F1F1F9',
          cursor: 'pointer',
          userSelect: 'none'
        }

        let donationAmount = {
          display: 'inline-block',
          color: '#F1F1F9',
          width: '125px',
          padding:'5px',
          fontSize: '14px',
        }

        let donationRow = {
          textAlign:'center',
          paddingTop:'5px',
          paddingBottom:'5px'
        }

    style.logoLabel = logoLabel
    style.backgroundImageLabel = backgroundImageLabel
    style.logoImg = logoImg
    style.backgroundImg = backgroundImg
    style.explanatoryTitle = explanatoryTitle
    style.explanatoryDescription = explanatoryDescription
    style.socialLinkText = socialLinkText
    style.rewardsBanner = rewardsBanner

    return (
      <div onClick={ (e) => this.handleLinkSelection(e) } className="brave-rewards-banner-container" style={rewardsBannerContainer}>

      <div className="brave-rewards-banner-control-bar" style={{height: '80px', display:'flex', alignItems:'center', paddingLeft:'60px', backgroundColor:'#E9E9F4', borderTopLeftRadius:'8px', borderTopRightRadius:'8px' }}>
        <img style={{height:'45px'}} src={DonationJar}></img>
        <h5 style={{marginTop:'auto', marginBottom:'auto', paddingLeft:'20px', paddingTop:'7px'}}>Tipping Banner</h5>
      </div>
      <div className="brave-rewards-banner-control-bar" style={{height: '70px', display:'flex', alignItems:'center', paddingLeft:'40px'}}>
        <div onClick={ () => this.handleSave() } className="brave-rewards-banner-control-bar-save-button" style={saveButton}>Save change</div>
        <div onClick={ () => this.handlePreview() } className="brave-rewards-banner-control-bar-save-button" id="edit-button" style={controlButton}>Preview</div>
        <p style={{marginTop:'auto', marginBottom:'auto', marginLeft:'auto', paddingRight:'20px'}}>Same banner content for all channels</p>
        <div style={{marginRight:'25px', paddingTop:'5px'}}>
        <Toggle checked={true} disabled={false} type={'light'} size={'large'} onToggle={null}></Toggle>
      </div>
      </div>

      <div style={style.rewardsBanner} className="brave-rewards-banner">

        <div className="brave-rewards-banner-logo" style={style.logoImg}>
          <input type="file" id="logoImageInput" style={style.imageInput} onChange={this.handleLogoImageUpload}/>
          <label className="banner-logo-label" style={style.logoLabel} htmlFor="logoImageInput" >
          </label>
        </div>

        <div className="brave-rewards-banner-background-image" style={style.backgroundImg}>
        <input type="file" id="backgroundImageInput" style={style.imageInput} onChange={this.handleBackgroundImageUpload}  />
        <label className="banner-background-image-label" style={style.backgroundImageLabel} htmlFor="backgroundImageInput"></label>
        </div>

        <div className="brave-rewards-banner-content" style={style.bannerContent}>

          <div className="brave-rewards-banner-content-social-links" style={style.socialLinks}>
            <h6 style={socialLinksHeader}>Links</h6>
            {this.renderLinks()}

            {
              (this.state.youtube === '' || this.state.twitter === '' || this.state.twitch === '') &&
            <div>
              {this.renderLinkOption(this.state.linkOption)}
              <div className="banner-link-selection-toggle" style={{display:'inline', height:'25px', width:'50px', fontSize:'20px', margin:'auto', fontFamily:'Segoe UI Symbol', opacity:'0.5', padding:'7px', cursor:'pointer'}}>&#9662;</div>
              <input onChange={ (e) => this.updateCurrentLink(e) } value={this.state.currentLink} maxLength={80} className="banner-social-link-input" style={{display:'inline', backgroundColor: 'rgba(0, 0, 0, 0)', border: '1px solid lightGray', borderRadius: '4px', width:'150px', height:'35px', marginLeft:'15px'}}/>

              {
                this.state.linkSelection ? (
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
                ) :
                (<div></div>)
              }

              <h6 onClick={ () => this.handleLinkSubmit() } style={{width:'90px', paddingTop:'10px', marginLeft:'75px', color:'#7d7bdc', cursor:'pointer', fontSize:'0.9rem'}}>+ Add Link</h6>
            </div>
          }

          </div>

          <div className="brave-rewards-banner-content-explanatory-text" style={style.explanatoryText}>
            <input style={style.explanatoryTitle} onChange={this.updateTitle} placeholder={this.state.title} maxLength={21} className="banner-headline" type='text'/>
            <textarea style={style.explanatoryDescription} onChange={this.updateDescription} placeholder={this.state.description} maxLength={250} className="banner-description" type='text'/>
          </div>

          <div className="brave-rewards-banner-content-donations" style={style.donations}>
            <h6 style={donationHeader}>Set tipping amount</h6>
            <div style={donationRow}>
              <div style={donationButton}>
                <BatColorIcon style={{display:'inline', height:'25px', width:'25px', marginRight:'10px'}}/>
                <p style={{display:'inline', fontWeight:'bold', fontFamily:'Poppins', color:'#F1F1F9'}}>{this.state.donationAmounts[0]}</p>
                <p style={{display:'inline', fontFamily:'Poppins', fontSize:'.85rem', marginLeft:'5px'}}>BAT</p>
              </div>
                <div style={donationAmount}>About {(this.state.donationAmounts[0] * this.props.conversionRate).toFixed(2)} {this.props.preferredCurrency}</div>
            </div>
            <div style={donationRow}>
              <div style={donationButton}>
                <BatColorIcon style={{display:'inline', height:'25px', width:'25px', marginRight:'10px'}}/>
                <p style={{display:'inline', fontWeight:'bold', fontFamily:'Poppins', color:'#F1F1F9'}}>{this.state.donationAmounts[1]}</p>
                <p style={{display:'inline', fontFamily:'Poppins', fontSize:'.85rem', marginLeft:'5px'}}>BAT</p>
              </div>
                <div style={donationAmount}>About {(this.state.donationAmounts[1] * this.props.conversionRate).toFixed(2)} {this.props.preferredCurrency}</div>
            </div>
            <div style={donationRow}>
              <div style={donationButton}>
                <BatColorIcon style={{display:'inline', height:'25px', width:'25px', marginRight:'10px'}}/>
                <p style={{display:'inline', fontWeight:'bold', fontFamily:'Poppins', color:'#F1F1F9'}}>{this.state.donationAmounts[2]}</p>
                <p style={{display:'inline', fontFamily:'Poppins', fontSize:'.85rem', marginLeft:'5px'}}>BAT</p>
              </div>
                <div style={donationAmount}>About {(this.state.donationAmounts[2] * this.props.conversionRate).toFixed(2)} {this.props.preferredCurrency}</div>
            </div>
          </div>
        </div>

      </div>
      </div>
    );
  }
}

export function renderBannerEditor(preferredCurrency, conversionRate) {

  let props = {
    preferredCurrency: preferredCurrency,
    conversionRate: conversionRate
  }

  ReactDOM.render(
    <BannerEditor {...props}/>,
    document.getElementById("rewards-banner-container").parentElement.parentElement
  )
}
