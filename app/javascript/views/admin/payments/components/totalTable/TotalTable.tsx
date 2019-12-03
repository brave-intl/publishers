import * as React from "react";

import Table from "brave-ui/components/dataTables/table";
import Card from "../../../../../components/card/Card";

import { LoaderIcon } from "brave-ui/components/icons";

interface ITotalTableProps {
  historic: any;
}

export default class TotalTable extends React.Component<ITotalTableProps, {}> {
  constructor(props) {
    super(props);
  }

  public render() {
    if (this.props.historic) {
      return <React.Fragment>{this.createTable()}</React.Fragment>;
    } else {
      return (
        <Card>
          <LoaderIcon style={{ width: "32px", height: "32px" }} />
        </Card>
      );
    }
  }

  public createTable() {
    let contributionsBalance = 0;
    let referralsBalance = 0;
    let totalBalance = 0;

    if (this.props.historic.transactions) {
      this.props.historic.transactions.forEach(transaction => {
        switch (transaction.transaction_type) {
          case "contribution_settlement":
            contributionsBalance += Math.abs(transaction.amount);
            break;
          case "referral_settlement":
            referralsBalance += Math.abs(transaction.amount);
            break;
        }
      });
    }

    totalBalance = parseFloat(
      (contributionsBalance + referralsBalance).toFixed(2)
    );
    contributionsBalance = parseFloat(contributionsBalance.toFixed(2));
    referralsBalance = parseFloat(referralsBalance.toFixed(2));

    const header = [
      {
        content: "Key",
        customStyle: {
          display: "none"
        }
      },
      {
        content: "value",
        customStyle: {
          display: "none"
        }
      }
    ];
    const rows = [
      {
        content: [
          {
            content: "Earned To Date",
            customStyle: {
              "font-size": "22px",
              "font-weight": "bold",
              padding: "16px 0px 16px 0px"
            }
          },
          {
            content: ""
          }
        ]
      },
      {
        content: [
          {
            content: "Contributions",
            customStyle: {
              "font-size": "18px",
              "font-weight": "bold",

              padding: "16px 0px 16px 0px"
            }
          },
          {
            content: ""
          }
        ]
      },
      {
        content: [
          {
            content: "Contributions Earned"
          },
          {
            content: contributionsBalance + " BAT"
          }
        ]
      },
      {
        content: [
          {
            content: "Referrals",
            customStyle: {
              "font-size": "18px",
              "font-weight": "bold",

              padding: "16px 0px 16px 0px"
            }
          },
          {
            content: ""
          }
        ]
      },
      {
        content: [
          {
            content: "Downloads"
          },
          {
            content: this.props.historic.downloads
          }
        ]
      },
      {
        content: [
          {
            content: "Installs"
          },
          {
            content: this.props.historic.installs
          }
        ]
      },
      {
        content: [
          {
            content: "Confirmations"
          },
          {
            content: this.props.historic.confirmations
          }
        ]
      },
      {
        content: [
          {
            content: "Referrals Earned"
          },
          {
            content: referralsBalance + " BAT"
          }
        ]
      },
      {
        content: [
          {
            content: "Total",
            customStyle: {
              "font-size": "18px",
              "font-weight": "bold",

              padding: "16px 0px 16px 0px"
            }
          },
          {
            content: ""
          }
        ]
      },
      {
        content: [
          {
            content: "Total"
          },
          {
            content: totalBalance + " BAT"
          }
        ]
      }
    ];
    if (this.props.historic.channelBalances) {
      this.props.historic.channelBalances.forEach((channel, index) => {
        let channelBalance = 0;
        if (this.props.historic.transactions) {
          this.props.historic.transactions.forEach(transaction => {
            if (
              transaction.transaction_type === "contribution" &&
              transaction.channel === channel.title
            ) {
              channelBalance += parseFloat(transaction.amount);
            }
          });
        }
        rows.splice(index + 2, 0, {
          content: [
            { content: <a href={channel.url}>{channel.title}</a> },
            { content: channelBalance.toFixed(2) + " BAT" }
          ]
        });
      });
    }
    return (
      <Card>
        <Table header={header} rows={rows}>
          &nbsp;
        </Table>
      </Card>
    );
  }
}
