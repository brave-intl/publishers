import * as moment from "moment";
import * as React from "react";
import { FormattedMessage, FormattedNumber, injectIntl } from "react-intl";
import ReactTooltip from "react-tooltip";

import {
  DisplayEarningPeriod,
  DisplayPaymentDate,
  IStatementOverview,
  IStatementTotal,
} from "../Statements";

import { TableHeader } from "../StatementsStyle";
import {
  Amount,
  ChannelHeader,
  Date,
  Description,
  Details,
  HideOverflow,
  Table,
  TableCell,
  Total,
  TotalCell,
} from "./StatementDetailsStyle";

import DetailSection from "./statementDetails/DetailSection";
import RateCardStatements from "./statementDetails/RateCardStatements";

import routes from "../../routes";

interface IStatementProps {
  statement: IStatementOverview;
  showPage?: boolean;
}

class StatementDetails extends React.Component<IStatementProps, any> {
  constructor(props) {
    super(props);

    this.state = { rateCardStatement: [] };
  }

  public componentDidMount() {
    if (this.props.statement.showRateCards) {
      this.setState({ isLoading: true });
      this.loadGroups();
    }
  }

  public async loadGroups() {
    await fetch(
      routes.publishers.statements.rate_card.path +
        `?start_date=${this.props.statement.earningPeriod.startDate}&end_date=${
          this.props.statement.earningPeriod.endDate
        }`,
      {
        headers: {
          Accept: "application/json",
          "X-CSRF-Token": document.head
            .querySelector("[name=csrf-token]")
            .getAttribute("content"),
          "X-Requested-With": "XMLHttpRequest",
        },
        method: "GET",
      }
    ).then((response) => {
      response.json().then((json) => {
        this.setState({
          isLoading: false,
          rateCardStatement: json.rateCardStatement,
        });
      });
    });
  }

  public render() {
    return (
      <Details>
        <div className="mx-5 ">
          <div className="d-flex align-items-center justify-content-between">
            <div>
              <h6 className="m-0">
                <span>
                  <FormattedMessage id="statements.overview.brand" />{" "}
                </span>
                <span className="text-muted font-weight-light ml-1">
                  <FormattedMessage id="statements.overview.statement" />
                </span>
              </h6>
            </div>
            <Date>
              {DisplayEarningPeriod(this.props.statement.earningPeriod)}
            </Date>
          </div>

          <div className="mb-4 mt-3">
            {this.props.statement.name}

            <span className="mx-2 text-muted font-weight-light">|</span>
            <span className="text-muted">{this.props.statement.email}</span>
          </div>

          <div className="d-flex justify-content-between mb-3">
            <div>
              <div>
                <FormattedMessage id="statements.overview.amountDeposited" />
              </div>
              <div>
                {Object.keys(this.props.statement.deposited).map((name) => (
                  <React.Fragment key={name}>
                    <Amount data-tip data-for={name}>
                      <FormattedNumber
                        value={this.props.statement.deposited[name]}
                        maximumFractionDigits={2}
                      />{" "}
                      <small>{name}</small>
                      <br />
                    </Amount>
                    <DepositBreakdown
                      name={name}
                      results={getParameterCaseInsensitive(
                        this.props.statement.depositedTypes,
                        name
                      )}
                    />
                  </React.Fragment>
                ))}
              </div>
            </div>

            <table className="table ml-4 border-bottom statement-table">
              <tbody>
                {/* Total Earned Section */}
                <tr>
                  <td colSpan={2}>
                    <strong>
                      <FormattedMessage id="statements.overview.totalEarned" />
                    </strong>
                  </td>
                  <td className="text-right">
                    <FormattedNumber
                      value={this.props.statement.totalEarned}
                      maximumFractionDigits={2}
                    />{" "}
                    <FormattedMessage id="bat" />
                  </td>
                </tr>

                {/* Subsection for totals */}
                <TotalSubTable {...this.props.statement.totals} />

                <tr>
                  <td colSpan={2}>
                    <strong>
                      <FormattedMessage id="statements.overview.totalDeposited" />
                    </strong>
                  </td>
                  <td className="text-right">
                    <FormattedNumber
                      value={this.props.statement.batTotalDeposited}
                      maximumFractionDigits={2}
                    />{" "}
                    <FormattedMessage id="bat" />
                  </td>
                </tr>
                <tr>
                  <td colSpan={2}>
                    <strong>
                      <FormattedMessage id="statements.overview.depositDate" />
                    </strong>
                  </td>
                  <td className="text-right">
                    {DisplayPaymentDate(this.props.statement.paymentDate)}
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <div className="">
          <h5 className="px-5 mb-3">
            <FormattedMessage id="statements.overview.totalEarned" />
            <span className="text-muted ml-2 font-weight-light">
              <FormattedMessage id="statements.overview.details.summary" />
            </span>
          </h5>

          {this.props.statement.details.map((detail, index) => (
            <DetailSection detail={detail} index={index} key={detail.title} />
          ))}
        </div>

        {this.props.statement.showRateCards && (
          <RateCardStatements
            rateCardStatement={this.state.rateCardStatement}
            isLoading={this.state.isLoading}
          />
        )}

        {!this.props.showPage && (
          <div className="px-5 py-3">
            <a
              data-piwik-action="StatementViewMore"
              data-piwik-name="Clicked"
              data-piwik-value=""
              href={routes.publishers.statements.show.path.replace(
                "{period}",
                this.props.statement.earningPeriod.startDate
              )}
            >
              <FormattedMessage id="statements.overview.viewMore" />
            </a>
          </div>
        )}
      </Details>
    );
  }
}

function getParameterCaseInsensitive(object, key) {
  return object[
    Object.keys(object).find((k) => k.toLowerCase() === key.toLowerCase())
  ];
}

const DepositBreakdown = (props) => (
  <ReactTooltip id={props.name}>
    {Object.keys(props.results).map((type) => (
      <React.Fragment key={type}>
        <FormattedMessage id={`statements.overview.types.${type}`} />
        {": "}
        <FormattedNumber
          value={props.results[type]}
          maximumFractionDigits={2}
        />
        {" BAT"}
        <br />
      </React.Fragment>
    ))}
  </ReactTooltip>
);

const TotalSubTable = (props: IStatementTotal) => (
  <React.Fragment>
    <tr>
      <TotalCell />
      <TotalCell>
        <Total>
          <FormattedMessage id="statements.overview.braveSettledContributions" />
        </Total>
      </TotalCell>
      <TotalCell textRight>
        <Total>
          <FormattedNumber
            value={props.contributionSettlement}
            maximumFractionDigits={2}
          />{" "}
          <FormattedMessage id="bat" />
        </Total>
      </TotalCell>
    </tr>
    <tr>
      <TotalCell />
      <TotalCell>
        <Total>
          <FormattedMessage id="statements.overview.fees" />
        </Total>
      </TotalCell>
      <TotalCell textRight>
        <Total>
          -
          <FormattedNumber value={props.fees} maximumFractionDigits={2} />{" "}
          <FormattedMessage id="bat" />
        </Total>
      </TotalCell>
    </tr>

    <tr>
      <TotalCell />
      <TotalCell>
        <Total>
          <FormattedMessage id="statements.overview.referralPromoEarnings" />
        </Total>
      </TotalCell>
      <TotalCell textRight>
        <Total>
          <FormattedNumber
            value={props.referralSettlement}
            maximumFractionDigits={2}
          />{" "}
          <FormattedMessage id="bat" />
        </Total>
      </TotalCell>
    </tr>

    <tr>
      <TotalCell />
      <TotalCell hasBorder>
        <Total isDark>
          <FormattedMessage id="statements.overview.totalBraveSettled" />
        </Total>
      </TotalCell>
      <TotalCell hasBorder textRight>
        <Total isDark>
          <FormattedNumber
            value={props.totalBraveSettled}
            maximumFractionDigits={2}
          />{" "}
          <FormattedMessage id="bat" />
        </Total>
      </TotalCell>
    </tr>

    <tr>
      <TotalCell />
      <TotalCell>
        <Total isDark>
          <FormattedMessage id="statements.overview.directUserTips" />
        </Total>
      </TotalCell>
      <TotalCell textRight>
        <Total isDark>
          <FormattedNumber
            value={props.upholdContributionSettlement}
            maximumFractionDigits={2}
          />{" "}
          <FormattedMessage id="bat" />
        </Total>
      </TotalCell>
    </tr>
  </React.Fragment>
);

export default injectIntl(StatementDetails);
