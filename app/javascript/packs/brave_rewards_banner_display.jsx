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
    this.state = {
      title: props.details.title || 'YOUR TITLE', 
      description: props.details.description || 'A brief description',
      backgroundImage: props.details.backgroundUrl,
      logo: props.details.logoUrl,
      appliedFade: false
    };
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
    var logoImageDiv = document.getElementsByClassName("brave-rewards-banner--logo-no-attachment")[0];
    var logoDiv = document.getElementsByClassName("sc-dnqmqq")[0];

    if (this.state.logo != null) {
      logoImageDiv.classList.remove("brave-rewards-banner--logo-no-attachment");
      logoImageDiv.classList.add("brave-rewards-banner--logo-camera");
      logoDiv.classList.add("brave-rewards-banner--logo-parent");
    }
  }

  attemptToApplyFade() {
    // Apply fade
    if (this.state.backgroundImage == null || this.state.appliedFade) {
      return;
    }
    var divClass = document.getElementsByClassName("sc-EHOje")[0].classList[1]
    document.querySelectorAll('[data-styled-components]').forEach(function(element) {
        if (element.innerHTML.includes(divClass)) {
          element.innerHTML = element.innerHTML.replace(/background:url/g, "background:linear-gradient(rgba(0, 0, 0, 0.5), rgba(0, 0, 0, 0.5)), url");
        }
    });

    this.setState({appliedFade: true});
  }

  handleBackgroundImageChange(event) {
    this.setState({backgroundImage: URL.createObjectURL(event.target.files[0])});
    this.attemptToApplyFade();
  }

  setupBackgroundLabel() {
    // Allow uploads
    var backgroundButton = document.createElement("button");
    backgroundButton.id = "background-image-select-button";
    backgroundButton.classList.add("camera-background");

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

    var label = document.createElement("label");
    label.innerHTML="900 x 176";
    label.classList.add("brave-rewards-banner--background-label");

    var backgroundDiv = document.getElementsByClassName("sc-EHOje")[0];
    var callToActionDiv = document.createElement("div");
    callToActionDiv.classList.add("brave-rewards-banner--background-camera");
    backgroundDiv.append(callToActionDiv);
    callToActionDiv.appendChild(backgroundInput);
    callToActionDiv.appendChild(backgroundButton);
    callToActionDiv.appendChild(label);
    this.attemptToApplyFade();
  }

  setupLogoLabel() {
    // Allow uploads
    var logoButton = document.createElement("button");
    logoButton.id = "logo-image-select-button";
    logoButton.classList.add("camera-background");

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

    var label = document.createElement("label");
    label.innerHTML="148 x 148";
    label.classList.add("brave-rewards-banner--logo-label");

    var logoDiv = document.getElementsByClassName("sc-dnqmqq")[0];
    logoDiv.classList.add("brave-rewards-banner--logo-parent");
    var callToActionDiv = document.createElement("div");
    if (this.state.logo == null) {
      callToActionDiv.classList.add("brave-rewards-banner--logo-no-attachment");
    } else {
      callToActionDiv.classList.add("brave-rewards-banner--logo-camera");
    }
    logoDiv.prepend(callToActionDiv);
    callToActionDiv.appendChild(logoInput);
    callToActionDiv.appendChild(logoButton);
    callToActionDiv.appendChild(label);
  }

  componentDidMount() {
    if (this.props.editMode) {
      this.setupBackgroundLabel();
      this.setupLogoLabel();

      // Hide X-mark
      document.getElementsByClassName("sc-bZQynM")[0].style = "display: none";
    }
  }

  submitById(id, suffix) {
    const url = '/publishers/' + this.props.publisher_id + "/site_banners/update_" + suffix;
    var file = document.getElementById(id);
    var reader = new FileReader();

    // Don't upload if user didn't upload a new image
    if (file.value == "" || file.value == null) {
      return;
    }
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
    };
  }

  setTextsFromDiv() {
    this.setState({
      title: document.getElementsByClassName("sc-gZMcBi")[0].innerText,
      description: document.getElementsByClassName("sc-gqjmRU")[0].innerText
    });
  }

  handleSubmit(event) {
    const url = '/publishers/' + this.props.publisher_id + "/site_banners";
    var request = new XMLHttpRequest();
    const body = new FormData();

    body.append('title', document.getElementsByClassName("sc-gZMcBi")[0].innerText);
    body.append('description', document.getElementsByClassName("sc-gqjmRU")[0].innerText);

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
    this.submitById("logo-image-select-input", "logo");
    ReactDOM.unmountComponentAtNode(document.getElementsByClassName("modal-panel--content")[0]);
    document.getElementsByClassName("modal-panel--close")[0].click();
  }

  render() {
    initLocale(locale);

    let topController;

    if (this.props.editMode) {
      topController = 
                    <React.Fragment>
                      <a data-js-confirm-with-modal="instant-donation-selection" className="btn btn-link-primary" id="instant-donation-dont-save-changes" href="#" style={{'color': '#808080'}}>Don't Change</a>
                      <a data-js-confirm-with-modal="instant-donation-selection" className="btn btn-link-primary" id="instant-donation-save-changes" href="#">Preview Banner</a>
                      <a data-js-confirm-with-modal="instant-donation-selection" className="btn btn-primary" id="instant-donation-save-changes" href="#" onClick={this.handleSubmit}>Save Change</a>
                    </React.Fragment>
    } else {
      topController = <a data-js-confirm-with-modal="instant-donation-selection" className="btn btn-link-primary" id="instant-donation-dont-save-changes" href="#" >Close</a>
    }

    return (
      <div id="site_banner">
        <div id="controller-form" className="nav navbar navbar-default navbar-static-top">
          <div className="container-fluid">
              <div className="menu-container">
                <div className="nav pull-left float-left">
                  <h4 style={{'marginTop': '12px'}}>All Channels</h4>
                </div>
                <div className="nav pull-right float-right">
                  {topController}
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

export function renderBraveRewardsBannerDisplay(editMode) {
  const braveRewardsPageForm = <BraveRewardsPageForm publisher_id={document.getElementById("publisher_id").value} editMode={editMode} details={JSON.parse(document.getElementById('site-banner-react-props').value)} />;

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

  if (editMode) {
    // Set h3 editable
    document.getElementsByClassName("sc-gZMcBi")[0].setAttribute("contenteditable", true)

    // Set p editable
    document.getElementsByClassName("sc-gqjmRU")[0].setAttribute("contenteditable", true)
  }

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
