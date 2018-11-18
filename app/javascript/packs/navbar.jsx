import React from 'react'

import styled from 'styled-components'
import { Container, BrandBar, ControlBar, BrandImage, BrandText, ToggleText, ToggleWrapper, Button, Channels, Text} from '../packs/style.jsx'

import DonationJar from '../../assets/images/icn-donation-jar@1x.png'
import Toggle from 'brave-ui/components/formControls/toggle'
import { YoutubeColorIcon, TwitterColorIcon, TwitchColorIcon, CaratLeftIcon, CaratRightIcon, VerifiedFillIcon} from 'brave-ui/components/icons'
import { initLocale } from 'brave-ui'
import locale from 'locale/en'

export default class Navbar extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      toggled: false
    }
  }

  render(){
    initLocale(locale);

    return(
      <Container>

        <BrandBar>
          <BrandImage src={DonationJar}/>
          <BrandText>Tipping Banner</BrandText>
          <ToggleText>Same banner content for all channels</ToggleText>
          <ToggleWrapper>
            <Toggle id='banner-toggle' checked={!this.props.channelMode} disabled={false} type={'light'} size={'large'} onToggle={this.props.toggleChannelMode}></Toggle>
          </ToggleWrapper>
        </BrandBar>

        <ControlBar>

          <Channels active={this.props.channelMode}>
          {
            this.props.channelIndex > 0 ?
            <CaratLeftIcon onClick={this.props.decrementChannelIndex} style={{height:'35px', width:'35px', marginBottom:'5px', color: '#fb542b', cursor:'pointer'}}/>
            :
            <CaratLeftIcon style={{height:'35px', width:'35px', marginBottom:'5px', color: '#C5C5D3', opacity:.3}}/>
          }
            <VerifiedFillIcon style={{height:'25px', width:'25px', marginBottom:'5px', marginRight:'5px', color: '#58CD92'}}/>
            <Text channel style={{display:'inline'}}>{this.props.channels[this.props.channelIndex].name}</Text>
          {
            this.props.channelIndex < this.props.channels.length-1 ?
            <CaratRightIcon onClick={this.props.incrementChannelIndex} style={{height:'35px', width:'35px', marginBottom:'5px', color: '#fb542b', cursor:'pointer'}}/>
            :
            <CaratRightIcon style={{height:'35px', width:'35px', marginBottom:'5px', color: '#C5C5D3', opacity:.3}}/>
          }
          </Channels>

          <Button onClick={this.props.preview} style={{marginLeft:'auto', marginRight:'20px'}} outline>Preview</Button>
          <Button onClick={this.props.save} style={{marginRight:'20px'}} primary>Save Changes</Button>
          <Button onClick={this.props.close} subtle>Done</Button>
        </ControlBar>

      </Container>
    )
  }
}
