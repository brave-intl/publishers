import * as React from "react";

import { LoaderIcon } from "brave-ui/components/icons";

import Card from "../../../../../components/card/Card";

import Table from "brave-ui/components/dataTables/table";

interface ICurrentTableProps {
  current: any;
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
    if (this.props.current) {
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
            content: this.props.current.contributionBalance + " BAT"
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
            content: this.props.current.currentDownloads
          }
        ]
      },
      {
        content: [
          {
            content: "Installs"
          },
          {
            content: this.props.current.currentInstalls
          }
        ]
      },
      {
        content: [
          {
            content: "Confirmations"
          },
          {
            content: this.props.current.currentConfirmations
          }
        ]
      },
      {
        content: [
          {
            content: "Referrals Balance"
          },
          {
            content: this.props.current.referralBalance + " BAT"
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
            content: this.props.current.totalBalance + " BAT"
          }
        ]
      }
    ];
    if (this.props.current.channelBalances) {
      this.props.current.channelBalances.forEach((channel, index) => {
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
