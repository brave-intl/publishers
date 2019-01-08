import * as React from 'react'
import * as ReactDOM from 'react-dom'
import Referrals from '../views/referrals/index.tsx'

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <Referrals/>,
    document.body.appendChild(document.getElementsByClassName('main-content')[0]),
  )
})
