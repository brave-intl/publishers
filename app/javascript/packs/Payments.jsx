import * as React from 'react'
import * as ReactDOM from 'react-dom'
import Payments from '../views/payments/index.tsx'

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <Payments/>,
    document.body.appendChild(document.getElementsByClassName('main-content')[0]),
  )
})
