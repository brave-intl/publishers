// Run this example by adding <%= javascript_pack_tag 'hello_react' %> to the head of your layout file,
// like app/views/layouts/application.html.erb. All it does is render <div>ButtonPrimary</div> at the bottom
// of the page.

import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import SiteBanner from 'brave-ui/features/rewards/siteBanner'
import { initLocale } from 'brave-ui'
import locale from 'locale/en'

class BraveRewardsPageForm extends React.Component {
  constructor(props) {
    super(props);
    this.state = {title: 'YOUR TITLE', description: 'A brief description'};
    this.handleTitleChange = this.handleTitleChange.bind(this);
    this.handleDescriptionChange = this.handleDescriptionChange.bind(this);
    this.handleLogoChange = this.handleLogoChange.bind(this);
    this.handleBackgroundImageChange = this.handleBackgroundImageChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }

  handleTitleChange(event) {
    this.setState({title: event.target.value});
  }

  handleDescriptionChange(event) {
    this.setState({description: event.target.value});
  }

  handleLogoChange(event) {
    this.setState({logo: URL.createObjectURL(event.target.files[0])});
  }

  handleBackgroundImageChange(event) {
    this.setState({backgroundImage: URL.createObjectURL(event.target.files[0])});
  }

  handleSubmit(event) {
    alert('A name was submitted: ' + this.state.title);
    event.preventDefault();
  }

  render() {
    initLocale(locale);

    return (
      <div>
        <div id="site_banner" style={{height: '50vh'}}>
          <SiteBanner
            bgImage={this.state.backgroundImage}
            logo={this.state.logo}
            title={this.state.title}
            currentDonation={"5"}
            donationAmounts={[
              {
                "tokens": 1,
                "converted": 0.3,
                "selected": false
              },
              {
                "tokens": 5,
                "converted": 1.5,
                "selected": false
              },
              {
                "tokens": 10,
                "converted": 3,
                "selected": false
              }
            ]}
          ><p style={{'white-space': "pre-line"}}>{this.state.description}</p></SiteBanner>
        </div>
        <div id="controller_form">
          <hr/>
          <h4>PREVIEW</h4>
          <form onSubmit={this.handleSubmit}>
            <label>
              Title:
              <input type="title" value={this.state.value} onChange={this.handleTitleChange} />
            </label>
            <div>
              Description:
              <label>
                <textarea type="description" value={this.state.description} onChange={this.handleDescriptionChange} />
              </label>
            </div>
            <div>
              <input type="file" id="backgroundImageSelect" style={{display:"none"}} onChange={this.handleBackgroundImageChange}/>
              <label htmlFor="backgroundImageSelect">Select a background image</label>
            </div>
            <div>
              <input type="file" id="logoSelect" style={{display:"none"}} onChange={this.handleLogoChange}/>
              <label htmlFor="logoSelect">Select a logo</label>
            </div>
            <input type="submit" value="Submit"/>
          </form>
        </div>
      </div>
    );
  }
}

const braveRewardsPageForm = <BraveRewardsPageForm />;

ReactDOM.render(
  braveRewardsPageForm,
  document.body.appendChild(document.createElement("div"))
)

document.getElementById('site_banner').children[0].style.height = '50vh';
