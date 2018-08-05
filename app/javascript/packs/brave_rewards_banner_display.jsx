// Run this example by adding <%= javascript_pack_tag 'hello_react' %> to the head of your layout file,
// like app/views/layouts/application.html.erb. All it does is render <div>ButtonPrimary</div> at the bottom
// of the page.

import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import SiteBanner from 'brave-ui'

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <SiteBanner 
      bgImage={"https://www.popsci.com/sites/popsci.com/files/styles/655_1x_/public/images/2017/07/mars-surface.jpg?itok=wZc9vU-e&fc=50,50"}
      logo={"https://pbs.twimg.com/profile_images/920841899992236032/mSDhBoC9_400x400.jpg"}
      title={"Alexis Ren"}
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
    />,
    document.body.appendChild(document.createElement('div')),
  )
})
