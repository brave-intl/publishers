import * as React from "react";

import Table from "brave-ui/components/dataTables/table";
import Card from "../../../../../components/card/Card";

export default class TotalTable extends React.Component<{}, {}> {
  constructor(props) {
    super(props);
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
            content: "Coming Soon..."
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
