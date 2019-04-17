import * as React from "react";

import Card from "../../../../../components/card/Card";

import Table from "brave-ui/components/dataTables/table";

export default class CurrentTable extends React.Component<{}, {}> {
  constructor(props) {
    super(props);
    this.state = {
      data: { referralCodes: [{ stats: null }] }
    };
  }

  public componentDidMount() {
    this.fetchData();
  }

  public async fetchData() {
    const id = window.location.pathname.substring(
      window.location.pathname.lastIndexOf("/") + 1
    );
    const url = "/admin/payments/" + id;
    const options = {
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
        "X-Requested-With": "XMLHttpRequest"
      },
      method: "GET"
    };
    const response = await fetch(url, options);
    const data = await response.json();
    this.setState({
      data
    });
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
      }
    ];

    return (
      <Card>
        <Table header={header} rows={rows}>
          &nbsp;
        </Table>
      </Card>
    );
  }
}
