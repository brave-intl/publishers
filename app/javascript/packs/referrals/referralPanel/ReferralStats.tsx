import * as React from "react";

import { FormattedMessage } from "react-intl";
import { IReferralCounts, ReferralType } from "../ReferralPanel";
import Arrow from "./arrowPointer/Arrow";

interface IStatsProps {
  selected: ReferralType;
  changeSelected: (ReferralType) => void;
  totals: IReferralCounts;
}

const ReferralStats = (props: IStatsProps) => (
  <div className="col-lg-7 p-0">
    <Option
      type={ReferralType.FINALIZED}
      number={props.totals.finalized}
      {...props}
    >
      <FormattedMessage id="homepage.referral.confirmed" />
    </Option>

    <Option
      type={ReferralType.FIRST_RUNS}
      number={props.totals.first_runs}
      {...props}
    >
      <FormattedMessage id="homepage.referral.installed" />
    </Option>

    <Option
      type={ReferralType.RETRIEVALS}
      number={props.totals.retrievals}
      {...props}
    >
      <FormattedMessage id="homepage.referral.downloaded" />
    </Option>
  </div>
);

const Option = props => (
  <div
    className={
      props.selected === props.type ? "selected selectable" : "selectable"
    }
    onClick={() => props.changeSelected(props.type)}
  >
    {props.children}

    <div className="d-flex promo-panel-number">
      {props.number}

      {props.selected === props.type && <Arrow />}
    </div>
  </div>
);

export default ReferralStats;
