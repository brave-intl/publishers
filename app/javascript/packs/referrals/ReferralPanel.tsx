import * as moment from "moment";
import * as React from "react";
import * as ReactDOM from "react-dom";

import { FormattedMessage, injectIntl, IntlProvider } from "react-intl";
import en, { flattenMessages } from "../../locale/en";
import ja from "../../locale/ja";

import { LoaderIcon } from "brave-ui/components/icons";
import Arrow from "./Arrow";
import Information from "./Information";

import routes from "../../views/routes";

interface IReferralGroupsState {
  errorMessage: string;
  groups: Array<{
    id: string;
    name: string;
    amount: string;
    currency: string;
    count: number;
  }>;
  isLoading: boolean;
  month: string;
  lastUpdated: string;
  totals: {
    finalized: number;
    first_runs: number;
    retrievals: number;
  };
}

// This react component is used on the promo panel for the homepage.
// This displays a listing of group, price, and confirmed count to the end user

class ReferralPanel extends React.Component<any, IReferralGroupsState> {
  constructor(props) {
    super(props);

    this.state = {
      errorMessage: null,
      groups: [],
      isLoading: true,
      lastUpdated: null,
      month: moment()
        .locale("en")
        .format("MMMM YYYY"),
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
      routes.publishers.promo_registrations.overview.path.replace(
        "{id}",
        this.props.publisherId
      ) + `?month=${this.state.month}&locale=${document.body.dataset.locale}`,
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
      response
        .json()
        .then(json => {
          const groups = json.groups;
          groups.map(g => {
            g.name = g.name.replace(
              "Group",
              this.props.intl.formatMessage({ id: "homepage.referral.group" })
            );
            return g;
          });

          this.setState({
            groups,
            isLoading: false,
            lastUpdated: json.lastUpdated,
            totals: json.totals
          });
        })
        .catch(() => {
          this.setState({
            errorMessage: this.props.intl.formatMessage({
              id: "common.unexpectedError"
            }),
            isLoading: false
          });
        });
    });
  }

  public monthOptions = () => {
    const dateStart = moment("2019-10-01");
    const dateEnd = moment();
    const interim = dateStart.clone();
    const timeValues = [];

    while (dateEnd > interim || interim.format("M") === dateEnd.format("M")) {
      timeValues.push({
        key: interim.locale(document.body.dataset.locale).format("MMMM YYYY"),
        value: interim.locale("en").format("MMMM YYYY")
      });
      interim.add(1, "month");
    }

    return timeValues;
  };

  public render() {
    const content = (
      <React.Fragment>
        <div className="d-flex align-items-center justify-content-between flex-wrap">
          <h1 className="promo-panel-title-item m-0 p-0">
            <FormattedMessage id="homepage.referral.title" />
          </h1>
          <div className="promo-period">
            <select onChange={this.setMonth} value={this.state.month}>
              {this.monthOptions().map(month => (
                <option key={month.value} value={month.value}>
                  {month.key}
                </option>
              ))}
            </select>
          </div>
        </div>

        <div className="py-2">
          <FormattedMessage id="homepage.referral.statement" />
        </div>

        {this.state.errorMessage && (
          <div className="h-100">
            <strong>{this.state.errorMessage}</strong>
          </div>
        )}

        {!this.state.errorMessage && (
          <React.Fragment>
            <div className="row">
              <Stats totals={this.state.totals} />

              <div className="col-xs d-none d-lg-block d-xl-block">
                <div className="mt-3">
                  <Arrow />
                </div>
              </div>

              <Groups groups={this.state.groups} />
            </div>

            <div className="row promo-info mb-2">
              <Information />
              <a href="https://support.brave.com/hc/en-us/articles/360025284131-What-do-the-referral-metrics-on-my-dashboard-mean-">
                <FormattedMessage id="homepage.referral.details" />
              </a>
            </div>
            <small
              style={{
                bottom: "0.5rem",
                color: "rgba(255,255,255, 0.7)",
                position: "absolute",
                right: "1.5rem"
              }}
            >
              {this.state.lastUpdated}
            </small>
          </React.Fragment>
        )}
      </React.Fragment>
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
  <div className="col-md">
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
  </div>
);

const Groups = props => (
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
            <td className="font-weight-bold">{group.count}</td>
          </tr>
        ))}
      </tbody>
    </table>
  </div>
);

const ReferralPanelWrapped = injectIntl(ReferralPanel);

document.addEventListener("DOMContentLoaded", () => {
  const element = document.getElementById("react-promo-panel");
  const props = JSON.parse(element.dataset.props);
  const locale = document.body.dataset.locale;
  let localePackage: object = en;
  if (locale === "ja") {
    localePackage = ja;
  }

  moment.locale(locale);
  ReactDOM.render(
    <IntlProvider
      locale={document.body.dataset.locale}
      messages={flattenMessages(localePackage)}
    >
      <ReferralPanelWrapped {...props} />
    </IntlProvider>,
    element
  );
});
