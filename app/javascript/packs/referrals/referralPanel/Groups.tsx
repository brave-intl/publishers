import * as React from "react";

import { ReferralType, IGroup } from "../ReferralPanel";

interface IGroupProps {
  groups: IGroup[],
  selected: ReferralType
}

const Groups = (props : IGroupProps) => (
  <div className="col-md">
    <table className="promo-table w-100 promo-selected">
      <tbody>
        {props.groups.map(group => (
          <tr key={group.id}>
            <td>
              <span className="font-weight-bold">{group.name} </span>
              <span className="ml-2">
                {Number.parseFloat(group.amount)
                  .toFixed(2)
                  .toString()}{" "}
                {group.currency}
              </span>
            </td>
            <td className="font-weight-bold">
              {props.selected === ReferralType.Finalized  && (group.counts.finalized  || 0)}
              {props.selected === ReferralType.FirstRuns  && (group.counts.first_runs || 0)}
              {props.selected === ReferralType.Retrievals && (group.counts.retrievals || 0)}
            </td>
          </tr>
        ))}
      </tbody>
    </table>
  </div>
);

export default Groups;
