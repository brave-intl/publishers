import * as React from "react";

import Card from "../../../../../components/card/Card";

import Table from "brave-ui/components/dataTables/table";

interface ICurrentTableProps {
  referralBalance: any;
  contributionBalance: any;
  channelBalances: any;
  totalBalance: any;
}

export default class CurrentTable extends React.Component<
  ICurrentTableProps,
  {}
> {
  constructor(props) {
    super(props);
    this.state = {
      data: { referralCodes: [{ stats: null }] }
    };
  }

  public render() {
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
            content: "Current Cycle",
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
            content: "Contributions Balance"
          },
          {
            content: this.props.contributionBalance + " BAT"
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
            content: "Coming Soon..."
          }
        ]
      },
      {
        content: [
          {
            content: "Installs"
          },
          {
            content: "Coming Soon..."
          }
        ]
      },
      {
        content: [
          {
            content: "Confirmations"
          },
          {
            content: "Coming Soon..."
          }
        ]
      },
      {
        content: [
          {
            content: "Referrals Balance"
          },
          {
            content: this.props.referralBalance + " BAT"
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
            content: "Total Balance"
          },
          {
            content: this.props.totalBalance + " BAT"
          }
        ]
      }
    ];
    if (this.props.channelBalances) {
      this.props.channelBalances.forEach((channel, index) => {
        rows.splice(index + 2, 0, {
          content: [
            { content: channel.title },
            { content: channel.balance + " BAT" }
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
