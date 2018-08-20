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
    this.handleLogoImageChange = this.handleLogoImageChange.bind(this);
    this.handleBackgroundImageChange = this.handleBackgroundImageChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }

  handleTitleChange(event) {
    this.setState({title: event.target.value});
  }

  handleDescriptionChange(event) {
    this.setState({description: event.target.value});
  }

  handleLogoImageChange(event) {
    this.setState({logo: URL.createObjectURL(event.target.files[0])});
  }

  handleBackgroundImageChange(event) {
    this.setState({backgroundImage: URL.createObjectURL(event.target.files[0])});
  }

  setupBackgroundLabel() {
    // Allow uploads
    var backgroundButton = document.createElement("button");
    backgroundButton.id = "background-image-select-button";
    backgroundButton.innerHTML = "Upload background image";

    var backgroundInput = document.createElement("input");
    backgroundInput.id="background-image-select-input";
    backgroundInput.type="file";
    backgroundInput.style.display = "none";
    backgroundInput.onchange = this.handleBackgroundImageChange;

    backgroundButton.addEventListener("click", function (e) {
      if (backgroundInput) {
        backgroundInput.click();
      }
    }, false);

    var backgroundDiv = "sc-chPdSV";
    document.getElementsByClassName(backgroundDiv)[0].appendChild(backgroundInput);
    document.getElementsByClassName(backgroundDiv)[0].appendChild(backgroundButton);
  }

  setupLogoLabel() {
    // Allow uploads
    var logoButton = document.createElement("button");
    logoButton.id = "logo-image-select-button";
    logoButton.innerHTML = "Upload logo image";

    var logoInput = document.createElement("input");
    logoInput.id="logo-image-select-input";
    logoInput.type="file";
    logoInput.style.display = "none";
    logoInput.onchange = this.handleLogoImageChange;

    logoButton.addEventListener("click", function (e) {
      if (logoInput) {
        logoInput.click();
      }
    }, false);

    var logoDiv = "sc-dnqmqq";
    document.getElementsByClassName(logoDiv)[0].appendChild(logoInput);
    document.getElementsByClassName(logoDiv)[0].appendChild(logoButton);
  }

  componentDidMount() {
    this.setupBackgroundLabel();
    this.setupLogoLabel();
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

    this.submitById("background-image-select-input", "background_image");
    this.submitById("logoSelect", "logo");
  }

  render() {
    initLocale(locale);

    return (
      <div id="site_banner">
        <div id="controller-form" className="nav navbar navbar-default navbar-static-top">
          <div className="container-fluid">
              <div className="menu-container">
                <div className="nav pull-left float-left">
                  <h4 style={{'marginTop': '12px'}}>All Channels</h4>
                </div>
                <div className="nav pull-right float-right">
                  <a data-js-confirm-with-modal="instant-donation-selection" className="btn btn-link-primary" id="instant-donation-dont-save-changes" href="#" style={{'color': '#808080'}}>Don't Change</a>
                  <a data-js-confirm-with-modal="instant-donation-selection" className="btn btn-link-primary" id="instant-donation-save-changes" href="#">Preview Banner</a>
                  <a data-js-confirm-with-modal="instant-donation-selection" className="btn btn-primary" id="instant-donation-save-changes" href="#">Save Change</a>
                </div>
              </div>
          </div>
        </div>
        <SiteBanner
          bgImage={this.state.backgroundImage}
          logo={this.state.logo}
          title={this.state.title}
          currentAmount={5}
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
        ><p style={{'whiteSpace': "pre-line"}}>{this.state.description}</p></SiteBanner>
        <div>
          <input type="file" id="background-image-select-input" style={{display:"none"}} onChange={this.handleBackgroundImageChange}/>
          <label htmlFor="background-image-select-input">Select a background image</label>
        </div>
      </div>
    );
  }
}

/*
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
              <input type="file" id="background-image-select-input" style={{display:"none"}} onChange={this.handleBackgroundImageChange}/>
              <label htmlFor="background-image-select-input">Select a background image</label>
            </div>
            <div>
              <input type="file" id="logoSelect" style={{display:"none"}} onChange={this.handleLogoImageChange}/>
              <label htmlFor="logoSelect">Select a logo</label>
            </div>
            <input type="submit" value="Submit"/>
          </form>
        </div>
        */

export function renderBraveRewardsBannerDisplay() {
  const braveRewardsPageForm = <BraveRewardsPageForm />;

  ReactDOM.render(
    braveRewardsPageForm,
    document.getElementById("instant-donation-modal").parentElement.parentElement
  )
  document.getElementById('site_banner').children[1].style.height = '0vh';

  // Resize modal container
  document.getElementsByClassName("modal-container")[0].style.height = document.getElementById('site_banner').children[1].children[0].offsetHeight + "px";
  document.getElementsByClassName("modal-container")[0].style.width = document.getElementById('site_banner').children[1].children[0].offsetWidth + "px";

  // Reset margins
  document.getElementsByClassName("modal-panel")[0].style.marginLeft = "0px";
  document.getElementById("controller-form").style.marginLeft = "-48px";
  document.getElementById("controller-form").style.marginTop = "-128px";
  document.getElementById("controller-form").style.paddingTop = "16px";
  document.getElementById("controller-form").style.width = document.getElementById('site_banner').children[1].children[0].offsetWidth + "px";
  document.getElementById("controller-form").style.backgroundColor = "white";

  // Hide unused close button
  document.getElementsByClassName("modal-panel--close")[0].style.visibility = 'hidden';

  // Set h3 editable
  document.getElementsByClassName("sc-gZMcBi fvLbBz")[0].setAttribute("contenteditable", true)

  // Set p editable
  document.getElementsByClassName("sc-gqjmRU gfESut")[0].setAttribute("contenteditable", true)

  document.getElementById("instant-donation-dont-save-changes").onclick = function() {
    ReactDOM.unmountComponentAtNode(document.getElementsByClassName("modal-panel--content")[0]);
    document.getElementsByClassName("modal-panel--close")[0].click();
  }
}

/*
  const braveRewardsPageForm = <BraveRewardsPageForm />;

  ReactDOM.render(
    braveRewardsPageForm,
    document.body.appendChild(document.createElement("div"))
  )

  document.getElementById('site_banner').children[0].style.height = '50vh';
*/
