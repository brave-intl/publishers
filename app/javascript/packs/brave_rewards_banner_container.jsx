import React from 'react'
import ReactDOM from 'react-dom'

import BraveRewardsBannerControlBar from '../packs/brave_rewards_banner_control_bar.jsx'
import BraveRewardsBannerIntro from '../packs/brave_rewards_banner_intro.jsx'
import BraveRewardsBanner from '../packs/brave_rewards_banner.jsx'


export default class BraveRewardsBannerContainer extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      mode: 'Edit'
    }

    this.setMode = this.setMode.bind(this)
  }

  setMode(mode){
    this.setState({mode: mode})
  }

  render() {

    let controlButton = {
    width: '200px',
    textAlign: 'center',
    borderRadius: '24px',
    // margin: '10px 0px 10px 0px',
    padding: '14px 15px',
    fontSize: '14px',
    marginLeft:'20px',
    border: '1px solid #fc4145',
    color: '#fc4145',
    cursor: 'pointer',
    userSelect: 'none'
  }

    let modeButton;

    if (this.state.mode === 'Edit') {
      modeButton = <div onClick={() => this.setMode('Preview')} className="brave-rewards-banner-control-bar-save-button" id="edit-button" style={controlButton}>Preview banner</div>;
    } else {
      modeButton = <div onClick={() => this.setMode('Edit')} className="brave-rewards-banner-control-bar-save-button" id="preview-button" style={controlButton}>Edit banner</div>;
    }

    return (
      <div className="brave-rewards-banner-container" style={{width:'950px', paddingBottom:'30px'}}>



      {/* <BraveRewardsBannerControlBar/>
      <BraveRewardsBannerIntro/> */}

      <div className="brave-rewards-banner-control-bar" style={{height: '80px', display:'flex', alignItems:'center'}}>
        <div className="brave-rewards-banner-control-bar-save-button" style={controlButton}>Save change</div>
        {modeButton}
      </div>
      <BraveRewardsBanner {...this.state}/>

      </div>
    );
  }
}

export function renderBraveRewardsBannerContainer() {

  ReactDOM.render(
    <BraveRewardsBannerContainer/>,
    document.getElementById("react-container").parentElement.parentElement
  )
}

export function unmountBraveRewardsBannerContainer() {
  ReactDOM.unmountComponentAtNode(
    <BraveRewardsBannerContainer/>,
    document.getElementsByClassName("react")[0]
  )
}
