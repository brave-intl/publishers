// Run this example by adding <%= javascript_pack_tag 'hello_react' %> to the head of your layout file,
// like app/views/layouts/application.html.erb. All it does is render <div>ButtonPrimary</div> at the bottom
// of the page.

import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import ButtonPrimary from 'brave-ui/rewards/buttonPrimary'

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <ButtonPrimary
      color={"brand"}
      size={"medium"}
      text={'Button'}
      disabled={false}/>,
    document.body.appendChild(document.createElement('div')),
  )
})
