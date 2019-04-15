import * as React from "react";

import Select from "brave-ui/components/formControls/select";
import Chart from "chart.js";
import Card from "../../../components/card/Card";

import Table from "brave-ui/components/dataTables/table";
import UserNavbar from "../components/userNavbar/UserNavbar";

export default class Payments extends React.Component<{}, {}> {
  constructor(props) {
    super(props);
    this.state = {
      data: { referralCodes: [{ stats: null }] }
    };
  }

  public componentDidMount() {
    this.fetchData();
  }

  public componentDidUpdate() {}

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
    return (
      <div
        style={{
          margin: "30px",
          display: "grid",
          gridTemplateColumns:
            "1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr",
          gridGap: "30px"
        }}
      >
        <div style={{ gridColumn: "1 / 13" }}>
          <UserNavbar />
        </div>
        <div style={{ gridColumn: "1 / 7" }}>
          <Card>
            <div>CURRENT CYCLE</div>
            <CurrentTable />
          </Card>
        </div>
        <div style={{ gridColumn: "7 / 13" }}>
          <Card>
            <div>EARNED TO DATE</div>
            <TotalTable />
          </Card>
        </div>
      </div>
    );
  }
}

function CurrentTable(props) {
  const header = [
    {
      content: "Key"
    },
    {
      content: "value"
    }
  ];
  const rows = [
    {
      content: [
        {
          content: "Downloads"
        },
        {
          content: "123"
        }
      ]
    },
    {
      content: [
        {
          content: "Installs"
        },
        {
          content: "123"
        }
      ]
    },
    {
      content: [
        {
          content: "Confirmations"
        },
        {
          content: "123"
        }
      ]
    },
    {
      content: [
        {
          content: "Referrals Balance"
        },
        {
          content: "267.56 BAT"
        }
      ]
    },
    {
      content: [
        {
          content: "Mind Half Full"
        },
        {
          content: "227.56 BAT"
        }
      ]
    },
    {
      content: [
        {
          content: "Contributions Balance"
        },
        {
          content: "287.56 BAT"
        }
      ]
    },
    {
      content: [
        {
          content: "Total Balance"
        },
        {
          content: "500 BAT"
        }
      ]
    }
  ];
  return (
    <div>
      <Table header={header} rows={rows}>
        &nbsp;
      </Table>
    </div>
  );
}

function TotalTable(props) {
  const header = [
    {
      content: "Key"
    },
    {
      content: "value"
    }
  ];
  const rows = [
    {
      content: [
        {
          content: "Referrals"
        },
        {
          content: "123"
        }
      ]
    },
    {
      content: [
        {
          content: "Contributions"
        },
        {
          content: "123"
        }
      ]
    },
    {
      content: [
        {
          content: "Total"
        },
        {
          content: "123"
        }
      ]
    }
  ];
  return (
    <div>
      <Table header={header} rows={rows}>
        &nbsp;
      </Table>
    </div>
  );
}
