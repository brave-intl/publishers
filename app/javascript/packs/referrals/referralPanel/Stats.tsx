import * as React from "react";

import { ReferralType, IReferralCounts } from "../ReferralPanel";
import { FormattedMessage } from "react-intl";

interface IStatsProps {
  selected: ReferralType;
  changeSelected: Function;
  totals: IReferralCounts;
}

const Stats = ( props: IStatsProps ) => (
  <div className="col-md">
    <table className="promo-table w-100 font-weight-bold">
      <tbody>
        <tr
          className={
            props.selected === ReferralType.Finalized
              ? "promo-selected selectable"
              : "selectable"
          }
          onClick={() => props.changeSelected(ReferralType.Finalized)}
        >
          <td>
            <FormattedMessage id="homepage.referral.confirmed" />
          </td>
          <td className="promo-panel-number">{props.totals.finalized}</td>
        </tr>
        <tr
          className={
            props.selected === ReferralType.FirstRuns
              ? "promo-selected selectable"
              : "selectable"
          }
          onClick={() => props.changeSelected(ReferralType.FirstRuns)}
        >
          <td>
            <FormattedMessage id="homepage.referral.installed" />
          </td>
          <td className="promo-panel-number">{props.totals.first_runs}</td>
        </tr>
        <tr
          className={
            props.selected === ReferralType.Retrievals
              ? "promo-selected selectable"
              : "selectable"
          }
          onClick={() => props.changeSelected(ReferralType.Retrievals)}
        >
          <td>
            <FormattedMessage id="homepage.referral.downloaded" />
          </td>
          <td className="promo-panel-number">{props.totals.retrievals}</td>
        </tr>
      </tbody>
    </table>
  </div>
);

export default Stats
