import React from 'react'

import styled from 'styled-components'
import { Container, BrandBar, ControlBar, BrandImage, BrandText, ToggleText, ToggleWrapper, Button} from '../packs/style.jsx'

import DonationJar from '../../assets/images/icn-donation-jar@1x.png'
import Toggle from 'brave-ui/components/formControls/toggle'

export default class Navbar extends React.Component {
  constructor(props) {
    super(props);
  }

  render(){
    return(
      <Container>

        <BrandBar mode={this.props.mode}>
          <BrandImage src={DonationJar}/>
          <BrandText>Tipping Banner</BrandText>
          <ToggleText>Same banner content for all channels</ToggleText>
          <ToggleWrapper>
            <Toggle checked={true} disabled={false} type={'light'} size={'large'} onToggle={null}></Toggle>
          </ToggleWrapper>
        </BrandBar>

        <ControlBar>
          <Button onClick={this.props.preview} style={{marginLeft:'auto', marginRight:'20px'}} outline>Preview</Button>
          <Button onClick={this.props.save} style={{marginRight:'20px'}} primary>Save Changes</Button>
          <Button onClick={this.props.close} subtle>Done</Button>
        </ControlBar>

      </Container>
    )
  }
}
