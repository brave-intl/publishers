import * as React from "react";

import { FormattedMessage } from "react-intl";
import { IReferralCounts, ReferralType } from "../ReferralPanel";

interface IStatsProps {
  selected: ReferralType;
  changeSelected: (ReferralType) => void;
  totals: IReferralCounts;
}

const ReferralStats = (props: IStatsProps) => (
  <div className="col-md">
    <table className="promo-table w-100 font-weight-bold">
      <tbody>
        <tr
          className={
            props.selected === ReferralType.FINALIZED
              ? "promo-selected selectable"
              : "selectable"
          }
          onClick={() => props.changeSelected(ReferralType.FINALIZED)}
        >
          <td>
            <FormattedMessage id="homepage.referral.confirmed" />
          </td>
          <td className="promo-panel-number">{props.totals.finalized}</td>
        </tr>
        <tr
          className={
            props.selected === ReferralType.FIRST_RUNS
              ? "promo-selected selectable"
              : "selectable"
          }
          onClick={() => props.changeSelected(ReferralType.FIRST_RUNS)}
        >
          <td>
            <FormattedMessage id="homepage.referral.installed" />
          </td>
          <td className="promo-panel-number">{props.totals.first_runs}</td>
        </tr>
        <tr
          className={
            props.selected === ReferralType.RETRIEVALS
              ? "promo-selected selectable"
              : "selectable"
          }
          onClick={() => props.changeSelected(ReferralType.RETRIEVALS)}
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

export default ReferralStats;
