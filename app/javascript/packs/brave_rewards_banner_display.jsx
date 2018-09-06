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

    //check for undefined
    let social;
    props.details.socialLinks === undefined ? social = {'twitter': '@', 'youtube': '@', 'twitch': '@'} : social = JSON.parse(props.details.socialLinks);

    this.state = {
      title: props.details.title || 'YOUR TITLE',
      description: props.details.description || 'A brief description',
      backgroundImage: props.details.backgroundUrl,
      logo: props.details.logoUrl,
      donationAmounts: props.details.donationAmounts || [1, 5, 10],
      socialLinks: social,
      appliedFade: false
    };
    this.updateDescription = this.updateDescription.bind(this);
    this.updateSocialLink = this.updateSocialLink.bind(this);
    this.updateTwitch = this.updateTwitch.bind(this);
    this.updateYoutube = this.updateYoutube.bind(this);
    this.updateTwitter = this.updateTwitter.bind(this);
    this.handleLogoImageChange = this.handleLogoImageChange.bind(this);
    this.handleBackgroundImageChange = this.handleBackgroundImageChange.bind(this);
    this.handleDonationAmountsChange = this.handleDonationAmountsChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }

  isNormalInteger(str) {
    return /^\+?(0|[1-9]\d*)$/.test(str);
  }

  convertDonationAmounts(donationAmounts) {
    if (donationAmounts == null) return null;

    return donationAmounts.map(
      amount => ({
        'tokens': amount,
        'converted': this.props.conversionRate * amount,
        'selected': false
      })
    );
  }

  handleDonationAmountsChange(event) {
    this.setState({
      donationAmounts:
        document.getElementById("donation-amounts-input").value.split(',').map(Number)
    });
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
    return;
    var divClass = document.getElementsByClassName("sc-EHOje")[0].classList[1]
    document.querySelectorAll('[data-styled-components]').forEach(function(element) {
      if (element.innerHTML.includes(divClass)) {
        element.innerHTML = element.innerHTML.replace(/height:176px;background:url/g, "height:176px;background:linear-gradient(rgba(0, 0, 0, 0.5), rgba(0, 0, 0, 0.5)), url");
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

      // Set h3 editable
      document.getElementsByClassName("sc-gZMcBi")[0].setAttribute("contenteditable", true)

      // Set p editable
      // document.getElementsByClassName("sc-gqjmRU")[0].setAttribute("contenteditable", true)

      var hiddenDonationAmounts = document.createElement('input');
      hiddenDonationAmounts.id = 'donation-amounts-input';
      hiddenDonationAmounts.type = "hidden"
      hiddenDonationAmounts.style.display = 'none';
      hiddenDonationAmounts.onchange = this.handleDonationAmountsChange;
      document.body.appendChild(hiddenDonationAmounts);

      // Editable for tokens
      for (let element of document.getElementsByClassName("sc-brqgnP")) {
        element.setAttribute("contenteditable", true);
        var observer = new MutationObserver(function(mutations) {
          mutations.forEach(function(mutation) {
            if (mutation.type == "contentList") {
              return;
            }
            // TODO: (Albert Wang) Make sure the input are valid numbers
            var donationAmounts = [];
            for (let amountSpan of document.getElementsByClassName("sc-brqgnP")) {
              donationAmounts.push(parseInt(amountSpan.textContent));
            }
            document.getElementById("donation-amounts-input").value = donationAmounts;
            document.getElementById("donation-amounts-input").onchange();
          });
        });
        // configuration of the observer:
        var config = { characterData: true, attributes: false, childList: true, subtree: true };
        // pass in the target node, as well as the observer options
        observer.observe(element, config);
      };

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

  updateSocialLink(event) {
      this.setState({socialLink : event.target.value});
  }

  updateDescription(event) {
    this.setState({description: event.target.value})
  }

  updateTwitch(event) {
    let temp = this.state.socialLinks
    temp.twitch = event.target.value
    this.setState({socialLink : temp});
  }

  updateYoutube(event) {
    let temp = this.state.socialLinks
    temp.youtube = event.target.value
    this.setState({socialLink : temp});
  }

  updateTwitter(event) {
    let temp = this.state.socialLinks
    temp.twitter = event.target.value
    this.setState({socialLink : temp});
  }

  addSocialLink() {
    console.log(this.state.socialLinks)
  }

  /*
  setTextsFromDiv() {
    this.setState({
      title: document.getElementsByClassName("sc-gZMcBi")[0].innerText,
      description: document.getElementsByClassName("sc-gqjmRU")[0].innerText
    });
  }
  */

  handleSubmit(event) {
    const url = '/publishers/' + this.props.publisher_id + "/site_banners";
    var request = new XMLHttpRequest();
    const body = new FormData();

    body.append('title', document.getElementsByClassName("sc-gZMcBi")[0].innerText);
    body.append('title', document.getElementsByClassName("sc-gZMcBi")[0].innerText);
    body.append('description', this.state.description);
    body.append('donation_amounts', JSON.stringify(this.state.donationAmounts));
    body.append('social_links', JSON.stringify(this.state.socialLinks));

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
        if (response.status === 200) {
          submitById("background-image-select-input", "background_image");
          submitById("logo-image-select-input", "logo");
        }
        // TODO: (Albert Wang): Make sure the above code doesn't reach here until a response is received
      }).then(
        function(response) {
          ReactDOM.unmountComponentAtNode(document.getElementsByClassName("modal-panel--content")[0]);
          document.getElementsByClassName("modal-panel--close")[0].click();
        });
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
          donationAmounts={this.convertDonationAmounts(this.state.donationAmounts)}
        >

        <input style={{backgroundColor:'rgba(0, 0, 0, 0)', border:'none', outline:'none', color:'#686978', paddingLeft:'4px'}} className="social-link" type="text" readOnly={!this.props.editMode} onChange={this.updateDescription} value={this.state.description} />
        <div style={{marginTop:'24px'}}>
        {
          // this.state.socialLinks.twitter !== undefined &&
          <div>
          <svg style={{display:'inline-block', marginBottom:'2px'}} width="16" height="13" xmlns="http://www.w3.org/2000/svg"><path d="M16 1.538c-.586.26-1.221.44-1.885.519A3.307 3.307 0 0 0 15.56.239a6.54 6.54 0 0 1-2.09.796A3.283 3.283 0 0 0 7.88 4.03 9.318 9.318 0 0 1 1.115.6a3.259 3.259 0 0 0-.445 1.652c0 1.137.58 2.144 1.46 2.729a3.232 3.232 0 0 1-1.484-.41v.04a3.291 3.291 0 0 0 2.631 3.223 3.386 3.386 0 0 1-1.484.054 3.293 3.293 0 0 0 3.066 2.28A6.595 6.595 0 0 1 .781 11.57c-.264 0-.522-.015-.781-.044A9.287 9.287 0 0 0 5.033 13c6.035 0 9.336-5.001 9.336-9.337l-.01-.425A6.612 6.612 0 0 0 16 1.538z" fill="#1DA1F2" fill-rule="evenodd"></path></svg>
          <input readOnly={!this.props.editMode} style={{backgroundColor:'rgba(0, 0, 0, 0)', border:'none', outline:'none', color:'#686978', paddingLeft:'4px'}} className="social-link" type="text" onChange={this.updateTwitter} value={this.state.socialLinks.twitter} />
          </div>
        }
        {
          // this.state.socialLinks.youtube !== undefined &&
          <div>
          <svg style={{display:'inline-block', marginBottom:'2px'}} width="16" height="12" xmlns="http://www.w3.org/2000/svg"><g fill="none" fill-rule="evenodd"><path fill="#FFF" d="M5 2l8 3-8 5z"></path><path d="M10.43 5.889L6.055 7.975a.176.176 0 0 1-.252-.158V3.513c0-.131.138-.216.255-.157l4.375 2.217a.176.176 0 0 1-.003.316zM12.677 0H3.323A3.323 3.323 0 0 0 0 3.323v4.676a3.323 3.323 0 0 0 3.323 3.323h9.354A3.323 3.323 0 0 0 16 7.999V3.323A3.323 3.323 0 0 0 12.677 0z" fill="#D9292A"></path></g></svg>
          <input readOnly={!this.props.editMode} style={{backgroundColor:'rgba(0, 0, 0, 0)', border:'none', outline:'none', color:'#686978', paddingLeft:'4px'}} className="social-link" type="text" onChange={this.updateYoutube} value={this.state.socialLinks.youtube} />
          </div>
        }
        {
          // this.state.socialLinks.twitch !== undefined &&
          <div>
          <svg style={{display:'inline-block', marginBottom:'2px'}} width="13" height="14" xmlns="http://www.w3.org/2000/svg"><path d="M5.281 7.31H6.5V3.657H5.281V7.31zm3.25 0H9.75V3.657H8.531V7.31zm3.25.63L9.75 10.03H6.5l-1.727 1.776V10.03H2.031V1.254h9.75V7.94zM.914 0L0 2.403v9.82h3.25V14h1.828l1.727-1.776h2.64L13 8.567V0H.914z" fill="#5A3D84" fill-rule="evenodd"></path></svg>
          <input readOnly={!this.props.editMode} style={{backgroundColor:'rgba(0, 0, 0, 0)', border:'none', outline:'none', color:'#686978', paddingLeft:'4px'}} className="social-link" type="text" onChange={this.updateTwitch} value={this.state.socialLinks.twitch} />
          </div>
        }
        </div>
        </SiteBanner>
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
  const braveRewardsPageForm = <BraveRewardsPageForm
    publisher_id={document.getElementById("publisher_id").value}
    editMode={editMode}
    details={JSON.parse(document.getElementById('site-banner-react-props').value)}
    conversionRate={document.getElementById("conversion-rate").value}
  />;

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

  /*
  if (editMode) {
    // Set h3 editable
    document.getElementsByClassName("sc-gZMcBi")[0].setAttribute("contenteditable", true)

    // Set p editable
    document.getElementsByClassName("sc-gqjmRU")[0].setAttribute("contenteditable", true)

    // Editable for tokens
    for (let element of document.getElementsByClassName("sc-brqgnP")) {
      element.setAttribute("contenteditable", true)
    };
  }
  */

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
