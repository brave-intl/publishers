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

  submitById(id, suffix) {
    console.log(id);
    var file = document.getElementById(id);
    var reader = new FileReader();
    reader.readAsDataURL(file.files[0]);
    reader.onloadend = function () {
      const body = new FormData();
      body.append('image', reader.result);
      fetch("/publishers/" + document.getElementById('publisher_id').value + "/site_banners/update_" + suffix, {
        method: 'POST',
        headers: {
          'Accept': 'text/html',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': document.head.querySelector("[name=csrf-token]").content
        },
        credentials: "same-origin",
        body: body
      });
    };
  }

  handleSubmit(event) {
    const url = '/publishers/' + document.getElementById('publisher_id').value + "/site_banners";
    var request = new XMLHttpRequest();
    const body = new FormData();
    body.append('title', this.state.title);
    body.append('description', this.state.description);

    /*
    request.open('POST', url);
    request.setRequestHeader('Content-Type', 'application/json; charset=UTF-8');
    request.setRequestHeader('X-CSRF-Token', document.head.querySelector("[name=csrf-token]").content);
    request.send(body);
    */
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

    this.submitById("backgroundImageSelect", "background_image");
    this.submitById("logoSelect", "logo");
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
