import React from 'react'
import ReactDOM from 'react-dom'

import BraveRewardsBannerControlBar from '../packs/brave_rewards_banner_control_bar.jsx'
import BraveRewardsBannerIntro from '../packs/brave_rewards_banner_intro.jsx'
import BraveRewardsBanner from '../packs/brave_rewards_banner.jsx'

import BraveRewardsLogo from '../../assets/images/icn-donation-jar@1x.png'


export default class BraveRewardsBannerContainer extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      mode: 'Edit',
      preferredCurrency: this.props.preferredCurrency,
      conversionRate: this.props.conversionRate,
    }

    this.setMode = this.setMode.bind(this)
  }

  componentWillMount(){
    this.modalize();
  }

  modalize(){
    document.getElementsByClassName("modal-panel")[0].style.maxWidth = 'none';
    document.getElementsByClassName("modal-panel")[0].style.padding = '0px';
    document.getElementsByClassName("modal-panel--content")[0].style.padding = '0px';
  }

  setMode(mode){
    this.setState({mode: mode})
  }

  render() {

    let controlButton = {
      width: '200px',
      textAlign: 'center',
      borderRadius: '24px',
      padding: '14px 15px',
      fontSize: '14px',
      marginLeft:'20px',
      border: '1px solid #fc4145',
      color: '#fc4145',
      cursor: 'pointer',
      userSelect: 'none'
    }

    let introButton = {
      width: '200px',
      textAlign: 'center',
      borderRadius: '24px',
      padding: '14px 15px',
      fontSize: '14px',
      margin: 'auto',
      marginTop: '20px',
      border: '1px solid #fc4145',
      color: '#fc4145',
      cursor: 'pointer',
      userSelect: 'none'
    }

    let rewardsBannerContainer

    if(this.state.isIntro){
      rewardsBannerContainer = {height:'590px', width:'840px', display: 'flex', flexDirection: 'column', justifyContent: 'center'}
    }
    else{
      rewardsBannerContainer = {height:'590px', width:'840px'}
    }

    let modeButton;

    if (this.state.mode === 'Edit') {
      modeButton = <div onClick={() => this.setMode('Preview')} className="brave-rewards-banner-control-bar-save-button" id="edit-button" style={controlButton}>Preview banner</div>;
    } else {
      modeButton = <div onClick={() => this.setMode('Edit')} className="brave-rewards-banner-control-bar-save-button" id="preview-button" style={controlButton}>Edit banner</div>;
    }

    return (
      <div className="brave-rewards-banner-container" style={rewardsBannerContainer}>

      {
        this.state.isIntro ?
        (
          <div className="brave-rewards-banner-intro" style={{textAlign:'center'}}>
            <h1 style={{margin:'20px'}}>
              {this.props.headline}
            </h1>
            <p style={{margin:'auto', textAlign:'left', width:'60%'}}>
              {this.props.intro}
            </p>
            <img style={{margin:'10px', marginTop:'20px'}} src={BraveRewardsLogo}></img>
            <img style={{margin:'10px', marginTop:'20px'}} src={BraveRewardsLogo}></img>
            <img style={{margin:'10px', marginTop:'20px'}} src={BraveRewardsLogo}></img>
            <div className="brave-rewards-banner-intro-button" onClick={() => this.setState({isIntro:false})} style={introButton}>Begin</div>
          </div>) :
        (
        <div>
          <div className="brave-rewards-banner-control-bar" style={{height: '80px', display:'flex', alignItems:'center'}}>
            <div className="brave-rewards-banner-control-bar-save-button" style={controlButton}>Save change</div>
            {modeButton}
            </div>
            <BraveRewardsBanner {...this.state}/>
        </div>
        )
      }

      </div>
    );
  }
}

export function renderBraveRewardsBannerContainer(preferredCurrency, conversionRate) {

  let props = {
    preferredCurrency: preferredCurrency,
    conversionRate: conversionRate
  }

  ReactDOM.render(
    <BraveRewardsBannerContainer {...props}/>,
    document.getElementById("rewards-banner-container").parentElement.parentElement
  )
}

export function unmountBraveRewardsBannerContainer() {
  ReactDOM.unmountComponentAtNode(
    <BraveRewardsBannerContainer/>,
    document.getElementsByClassName("react")[0]
  )
}
