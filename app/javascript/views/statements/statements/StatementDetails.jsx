import * as moment from "moment";
import * as React from "react";
import { FormattedMessage, injectIntl, useIntl } from "react-intl";

import {
  CurrencyNumber,
  DepositBreakdown,
  DisplayEarningPeriod,
  DisplayPaymentDate,
  GetParameterCaseInsensitive,
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

class StatementDetails extends React.Component {
  constructor(props) {
    super(props);

    this.state = { rateCardStatement };
  }

  componentDidMount() {
    if (this.props.statement.showRateCards) {
      this.setState({ isLoading: true });
      this.loadGroups();
    }
  }

  async loadGroups() {
    await fetch(
      routes.publishers.statements.rate_card.path +
        `?start_date=${this.props.statement.earningPeriod.startDate}&end_date=${
          this.props.statement.earningPeriod.endDate
        }&id=${this.props.statement.publisherId}`,
      {
        headers: {
          Accept: "application/json",
          "X-CSRF-Token": document.head
            .querySelector("[name=csrf-token]")
            .getAttribute("content"),
          "X-Requested-With": "XMLHttpRequest",
        },
        method: "GET",
      },
    ).then((response) => {
      response.json().then((json) => {
        this.setState({
          isLoading: false,
          rateCardStatement: json.rateCardStatement,
        });
      });
    });
  }

  render() {
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
                    <DepositBreakdown
                      name={name}
                      results={GetParameterCaseInsensitive(
                        this.props.statement.depositedTypes,
                        name,
                      )}
                    >
                      <Amount>
                        <CurrencyNumber
                          value={this.props.statement.deposited[name]}
                        />{" "}
                        <small>{name}</small>
                        <br />
                      </Amount>
                    </DepositBreakdown>
                  </React.Fragment>
                ))}
              </div>
            </div>

            <table className="table ml-4 border-bottom statement-table">
              <tbody>
                <tr>
                  <td colSpan={2}>
                    <strong>
                      <FormattedMessage id="statements.overview.totalDeposited" />
                    </strong>
                  </td>
                  <td className="text-right">
                    <CurrencyNumber
                      value={this.props.statement.batTotalDeposited}
                    />{" "}
                    <FormattedMessage id="bat" />
                  </td>
                </tr>
                {/* Subsection for totals */}
                <TotalSubTable
                  {...this.props.statement.totals}
                  settlementDestination={
                    this.props.statement.settlementDestination
                  }
                />

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
              href={routes.publishers.statements.show.path.replace(
                "{period}",
                this.props.statement.earningPeriod.startDate,
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

const TotalSubTable = (props) => (
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
          <CurrencyNumber value={props.contributionSettlement} />{" "}
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
          <CurrencyNumber value={props.referralSettlement} />{" "}
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
          <SettlementDestinationLink
            settlementDestination={props.settlementDestination}
          >
            <CurrencyNumber value={props.totalBraveSettled} />{" "}
            <FormattedMessage id="bat" />
          </SettlementDestinationLink>
        </Total>
      </TotalCell>
    </tr>
  </React.Fragment>
);

export const SettlementDestinationLink = (props) => {
  const intl = useIntl();
  if (props.settlementDestination) {
    return (
      <a
        href={intl.formatMessage(
          { id: "statements.overview.upholdCardLink" },
          { cardId: props.settlementDestination },
        )}
      >
        {props.children}
      </a>
    );
  }

  return props.children;
};

export default injectIntl(StatementDetails);
