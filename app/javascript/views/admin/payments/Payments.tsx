import * as React from "react";

import { Cell, Container, Grid } from "../../../components/grid/Grid";
import UserNavbar from "../components/userNavbar/UserNavbar";
import { templateAreas, templateRows } from "./PaymentsStyle";

import Card from "../../../components/card/Card";
import Statements from "../../statements/Statements";
import CurrentChart from "./components/currentChart/CurrentChart";
import CurrentTable from "./components/currentTable/CurrentTable";
import EarningsChart from "./components/earningsChart/EarningsChart";
import TotalTable from "./components/totalTable/TotalTable";

import routes from "../../../routes/routes";

interface IPaymentsProps {
  data: any;
}

interface IPaymentsState {
  data: any;
  isLoading: boolean;
}

export enum NavbarSelection {
  Dashboard,
  Channels,
  Referrals,
  Payments
}

export default class Payments extends React.Component<
  IPaymentsProps,
  IPaymentsState
> {
  constructor(props) {
    super(props);
    this.state = {
      data: this.props.data,
      isLoading: false
    };
  }

  public componentDidMount() {
    if (this.state.data.current === undefined) {
      this.loadData();
    }
  }

  public async loadData() {
    this.setState({ isLoading: true });

    const result = await fetch(
      routes.admin.userNavbar.payments.path.replace(
        "{id}",
        this.props.data.publisher.id
      ),
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
      response.json().then(json => {
        this.setState({ data: json });
      });
    });

    this.setState({ isLoading: false });
  }

  public render() {
    return (
      <React.Fragment>
        <UserNavbar
          navbarSelection={"Payments"}
          publisher={this.props.data.publisher}
        />
        <Container>
          <Grid
            templateAreas={templateAreas}
            templateRows={templateRows}
            style={{ marginTop: "30px", marginBottom: "30px" }}
          >
            <Cell gridArea={"a"}>
              <CurrentChart current={this.state.data.current} />
            </Cell>
            <Cell gridArea={"b"}>
              <EarningsChart historic={this.state.data.historic} />
            </Cell>
            <Cell gridArea={"c"}>
              <TotalTable historic={this.state.data.historic} />
            </Cell>
            <Cell gridArea={"d"}>
              <CurrentTable current={this.state.data.current} />
            </Cell>
          </Grid>
          <Card>
            <Statements publisher_id={this.props.data.publisher.id} />
          </Card>
        </Container>
      </React.Fragment>
    );
  }
}
