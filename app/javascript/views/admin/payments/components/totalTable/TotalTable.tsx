import * as React from "react";

import Table from "brave-ui/components/dataTables/table";
import Card from "../../../../../components/card/Card";

export default class TotalTable extends React.Component<{}, {}> {
  constructor(props) {
    super(props);
  }

  public render() {
    let contributionsBalance = 0;
    let referralsBalance = 0;
    let totalBalance = 0;

    console.log(this.props.transactions);

    if (this.props.transactions) {
      this.props.transactions.forEach(transaction => {
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

    totalBalance = (contributionsBalance + referralsBalance).toFixed(2);
    contributionsBalance = contributionsBalance.toFixed(2);
    referralsBalance = referralsBalance.toFixed(2);

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
              "font-weight": "bold",
              "font-size": "22px",
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
              "font-weight": "bold",
              "font-size": "18px",
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
              "font-weight": "bold",
              "font-size": "18px",
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
            content: this.props.downloads
          }
        ]
      },
      {
        content: [
          {
            content: "Installs"
          },
          {
            content: this.props.installs
          }
        ]
      },
      {
        content: [
          {
            content: "Confirmations"
          },
          {
            content: this.props.confirmations
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
              "font-weight": "bold",
              "font-size": "18px",
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
    if (this.props.channelBalances) {
      this.props.channelBalances.forEach((channel, index) => {
        let channelBalance = 0;
        if (this.props.transactions) {
          this.props.transactions.forEach(transaction => {
            if (
              transaction.transaction_type === "contribution" &&
              transaction.channel === channel.title
            ) {
              console.log(transaction.amount);
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
