import React from 'react'
import ReactDOM from 'react-dom'

import { renderBannerEditor } from '../packs/banner_editor'

import SiteBanner from 'brave-ui/features/rewards/siteBanner'
import { initLocale } from 'brave-ui'
import locale from 'locale/en'

export default class BannerPreview extends React.Component {

  constructor(props) {
    super(props);

    this.state = {
    }
  }

  componentWillMount(){
    this.prepareContainer();
  }

  componentDidMount(){
    // this.cleanup();
  }

  prepareContainer(){
    let container = document.getElementById('preview-container');
    container.setAttribute("style", "position: absolute; top: 0; left: 0; z-index:10000; height:100%; width:100%; background-color:rgba(12, 13, 33, 0.85)")
  }

  getSocial(){
    let social = [];
    if(this.props.youtube){
      social.push({
        type:'youtube',
        url:this.props.youtube
      })
    }
    if(this.props.twitter){
      social.push({
        type:'twitter',
        url:this.props.twitter
      })
    }
    if(this.props.twitch){
      social.push({
        type:'twitch',
        url:this.props.twitch
      })
    }
    return social
  }

  handleClose(){
    let instantDonationButton = document.getElementById("instant-donation-button");
    instantDonationButton.click();
    renderBannerEditor(this.props.preferredCurrency, this.props.conversionRate);
    setTimeout(function(){
      document.getElementById("preview-container").remove();
    }, 100)

  }

  cleanup(){
    document.getElementsByClassName("sc-bZQynM rOiyj")[0].remove();
    document.getElementsByClassName("sc-fjdhpX jopENR")[0].style.visibility = 'hidden';
  }

  render() {
    initLocale(locale);

    return (
      <div style={{height:'100%', width:'97%', margin:'auto'}}>
      <SiteBanner
        domain={""}
        title={this.props.title}
        currentDonation={0}
        balance={25.0}
        currentAmount={0}
        bgImage={this.props.backgroundImage}
        logo={this.props.logoImage}
        donationAmounts={
          [
            { tokens: this.props.donationAmounts[0], converted: (this.props.donationAmounts[0] * this.props.conversionRate).toFixed(2), selected: false },
            { tokens: this.props.donationAmounts[1], converted: (this.props.donationAmounts[1] * this.props.conversionRate).toFixed(2), selected: false },
            { tokens: this.props.donationAmounts[2], converted: (this.props.donationAmounts[2] * this.props.conversionRate).toFixed(2), selected: false }
          ]
        }
        social={this.getSocial()}
      >
        <p>{this.props.description}</p>
      </SiteBanner>
      <div onClick={ () => this.handleClose() } style={
      {
          top:'10%', transform: 'translate(-50%, -10%)', left:'50%', backgroundColor:'rgba(0,0,0,0)', zIndex:'10000',
          position:'relative', borderRadius:'24px', padding: '9px 10px', fontSize: '14px',
          border: '1px solid white', color: 'white', width:'250px', textAlign:'center', cursor:'pointer'
      }
    }>CLOSE PREVIEW</div>
      </div>
    )
    }
}
