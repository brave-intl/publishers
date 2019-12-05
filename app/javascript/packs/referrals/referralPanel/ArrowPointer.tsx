import * as React from "react";
import { ReferralType } from "../ReferralPanel";
import Arrow from "./arrowPointer/Arrow";

const ArrowPointer = props => (
  <div className="col-xs d-none d-lg-block d-xl-block">
    <table>
      <tbody>
        <tr>
          <td className="py-4">
            {props.selected === ReferralType.Finalized && <Arrow />}
          </td>
        </tr>
        <tr>
          <td className="py-4">
            {props.selected === ReferralType.FirstRuns && <Arrow />}
          </td>
        </tr>
        <tr>
          <td className="py-4">
            {props.selected === ReferralType.Retrievals && <Arrow />}
          </td>
        </tr>
      </tbody>
    </table>
  </div>
);

export default ArrowPointer;
