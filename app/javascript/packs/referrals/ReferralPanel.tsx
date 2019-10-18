import * as React from "react";
import * as ReactDOM from "react-dom";

import { FormattedMessage, IntlProvider } from "react-intl";
import en, { flattenMessages } from "../../locale/en";

import { LoaderIcon } from "brave-ui/components/icons";
import Arrow from "./Arrow";
import Information from "./Information";

import routes from "../../views/routes";

interface IReferralGroupsState {
  isLoading: boolean;
  groups: Array<{
    id: string;
    name: string;
    amount: string;
    currency: string;
    count: number;
  }>;
  month: string;
  totals: {
    finalized: number;
    first_runs: number;
    retrievals: number;
  };
}

// This react component is used on the promo panel for the homepage.
// This displays a listing of group, price, and confirmed count to the end user

export default class ReferralPanel extends React.Component<
  any,
  IReferralGroupsState
> {
  constructor(props) {
    super(props);

    this.state = {
      groups: [],
      isLoading: true,
      month: "",
      totals: {
        finalized: 0,
        first_runs: 0,
        retrievals: 0
      }
    };
  }

  public componentDidMount = () => {
    this.loadGroups();
  };

  public setMonth = e => {
    this.setState({ month: e.target.value, isLoading: true }, this.loadGroups);
  };

  public async loadGroups() {
    await fetch(
      routes.publishers.promo_registrations.overview.path +
        `?month=${this.state.month}`,
      {
        headers: {
          Accept: "application/json",
          "X-CSRF-Token": document.head
            .querySelector("[name=csrf-token]")
            .getAttribute("content"),
          "X-Requested-With": "XMLHttpRequest"
        },
        method: "GET"
      }
    ).then(response => {
      response.json().then(json => {
        this.setState({
          groups: json.groups,
          isLoading: false,
          totals: json.totals
        });
      });
    });
  }

  public render() {
    const content = (
      <>
        <div className="d-flex align-items-center justify-content-between flex-wrap">
          <h1 className="promo-panel-title-item m-0 p-0">
            <FormattedMessage id="homepage.referral.title" />
          </h1>
          <div className="promo-period">
            <select onChange={this.setMonth} value={this.state.month}>
              <option value="October 2019">October 2019</option>
              <option value="November 2019">November 2019</option>
            </select>
          </div>
        </div>
        <FormattedMessage id="homepage.referral.statement" />
        <div className="row">
          <div className="col-md">
            <Stats totals={this.state.totals} />
          </div>
          <div className="col-xs d-none d-lg-block d-xl-block">
            <div className="mt-3">
              <Arrow />
            </div>
          </div>
          <div className="col-md">
            <Groups groups={this.state.groups} />
          </div>
        </div>
        <div className="promo-info">
          <Information />
          <a href="https://support.brave.com/hc/en-us/articles/360025284131-What-do-the-referral-metrics-on-my-dashboard-mean-">
            <FormattedMessage id="homepage.referral.details" />
          </a>
        </div>
      </>
    );

    return (
      <>
        {this.state.isLoading && (
          <LoaderIcon style={{ width: "36px", margin: "0 auto" }} />
        )}
        {!this.state.isLoading && content}
      </>
    );
  }
}
const Stats = props => (
  <table className="promo-table w-100 font-weight-bold">
    <tbody>
      <tr className="promo-selected">
        <td>
          <FormattedMessage id="homepage.referral.confirmed" />
        </td>
        <td className="promo-panel-number">{props.totals.finalized}</td>
      </tr>
      <tr>
        <td>
          <FormattedMessage id="homepage.referral.installed" />
        </td>
        <td className="promo-panel-number">{props.totals.first_runs}</td>
      </tr>
      <tr>
        <td>
          <FormattedMessage id="homepage.referral.downloaded" />
        </td>
        <td className="promo-panel-number">{props.totals.retrievals}</td>
      </tr>
    </tbody>
  </table>
);

const Groups = props => (
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
          <td className="font-weight-bold">{group.count}</td>
        </tr>
      ))}
    </tbody>
  </table>
);

document.addEventListener("DOMContentLoaded", () => {
  ReactDOM.render(
    <IntlProvider
      locale={document.body.dataset.locale}
      messages={flattenMessages(en)}
    >
      <ReferralPanel />
    </IntlProvider>,
    document.getElementById("react-promo-panel")
  );
});
