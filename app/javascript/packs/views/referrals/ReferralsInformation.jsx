import * as React from 'react'
import * as ReactDOM from 'react-dom'
import ReferralsInformation from '../../../views/referrals/referralsInformation/ReferralsInformation'

document.addEventListener("DOMContentLoaded", () => {
  ReactDOM.render(
    <ReferralsInformation />,
    document.body.appendChild(
      document.getElementsByClassName("main-content")[0]
    )
  );
});
