import * as React from "react";
import * as ReactDOM from "react-dom";

import { LoaderIcon } from "brave-ui/components/icons";
import Arrrow from './Arrow'

import routes from "../../views/routes";

interface IReferralGroupsState {
  isLoading: boolean;
  groups: Array<{
    id: string;
    name: string;
    amount: string;
    currency: string;
  }>;
}


// This react component is used on the promo panel for the homepage.
// This displays a listing of group, price, and confirmed count to the end user

export default class ReferralGroups extends React.Component<
  any,
  IReferralGroupsState
> {
  constructor(props) {
    super(props);

    this.state = {
      groups: [],
      isLoading: true
    };
  }

  public componentDidMount = () => {
    this.loadGroups();
  };

  public async loadGroups() {
    await fetch(routes.publishers.promo_registrations.overview.path, {
      headers: {
        Accept: "application/json",
        "X-CSRF-Token": document.head
          .querySelector("[name=csrf-token]")
          .getAttribute("content"),
        "X-Requested-With": "XMLHttpRequest"
      },
      method: "GET"
    }).then(response => {
      response.json().then(json => {
        this.setState({ groups: json.groups, isLoading: false });
      });
    });
  }

  public render() {
    return (
      <>
        {this.state.isLoading && (
          <LoaderIcon style={{ width: "36px", margin: "0 auto" }} />
        )}
        {!this.state.isLoading && (
          <table className="promo-table w-100 promo-selected">
            {this.state.groups.map(group => (
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
                <td className="font-weight-bold">0</td>
              </tr>
            ))}
          </table>
        )}
      </>
    );
  }
}

document.addEventListener("DOMContentLoaded", () => {
  ReactDOM.render(<ReferralGroups />, document.getElementById("promo-groups"));
});
