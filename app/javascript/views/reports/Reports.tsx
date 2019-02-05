import * as React from "react";

import Modal, { ModalSize } from "../../components/Modal";
import {
  Button,
  Card,
  Cell,
  Container,
  Table,
  TableHeader,
  Wrapper
} from "../style";

import PaymentsHeader from "../payments/header/Header";
import routes from "../routes";
import { FlexWrapper, LoadingIcon, ReportHeader, Status } from "./ReportsStyle";

import locale from "../../locale/en";
import ReportDialog from "./reportDialog/ReportDialog";

interface IReport {
  approved?: boolean;
  amount_bat: string;
  id: string;
  filename: string;
  file_url: string;
  uploaded_by_user: string;
  created_at: string;
}
interface IReportsProps {
  reports: IReport[];
}

interface IReportsState {
  isLoading: boolean;
  reports: IReport[];
  showModal: boolean;
  showUpload: boolean;
}

export default class Reports extends React.Component<
  IReportsProps,
  IReportsState
> {
  public readonly state: IReportsState = {
    isLoading: false,
    reports: this.props.reports,
    showModal: false,
    showUpload: false
  };

  constructor(props) {
    super(props);
    this.reloadTable = this.reloadTable.bind(this);
  }

  public setLoading = isLoading => {
    this.setState({ isLoading });
  };

  public async reloadTable() {
    this.setLoading(true);
    const result = await fetch(routes.payments.reports.path, {
      headers: {
        Accept: "application/json",
        "X-CSRF-Token": document.head
          .querySelector("[name=csrf-token]")
          .getAttribute("content"),
        "X-Requested-With": "XMLHttpRequest"
      },
      method: "GET"
    }).then(response => {
      response.json().then(json => {
        this.setState({ reports: json.reports });
      });
    });

    this.setLoading(false);
  }

  public triggerModal = () => {
    this.setState({ showModal: !this.state.showModal });
  };

  public reportStatus = report => {
    let status = (
      <Status>
        <span>{locale.payments.reports.unpaid}</span>
      </Status>
    );

    if (report.paid === true) {
      status = (
        <Status>
          <span>{locale.payments.reports.paid}</span>
        </Status>
      );
    }

    return status;
  };
  public render() {
    let noResults;

    if (this.state.reports.length === 0) {
      noResults = (
        <tr>
          <td colSpan={5} align="center">
            {locale.payments.reports.noResults}
          </td>
        </tr>
      );
    }

    return (
      <Wrapper>
        <PaymentsHeader />
        <Container>
          <Card>
            <FlexWrapper>
              <ReportHeader>{locale.payments.reports.title}</ReportHeader>
              <Button onClick={this.triggerModal}>
                {locale.payments.reports.upload.button}
              </Button>

              <Modal
                handleClose={this.triggerModal}
                show={this.state.showModal}
                size={ModalSize.Small}
              >
                <ReportDialog
                  route={routes.payments.reports.path}
                  afterSave={this.reloadTable}
                  closeModal={this.triggerModal}
                />
              </Modal>

              <LoadingIcon isLoading={this.state.isLoading} />
            </FlexWrapper>

            <Table>
              <thead>
                <tr>
                  <TableHeader>{locale.payments.reports.fileName}</TableHeader>
                  <TableHeader>{locale.payments.reports.amountBAT}</TableHeader>
                  <TableHeader>{locale.payments.reports.createdAt}</TableHeader>
                  <TableHeader>
                    {locale.payments.reports.uploadedBy}
                  </TableHeader>
                  <TableHeader>{locale.payments.reports.status}</TableHeader>
                </tr>
              </thead>
              <tbody>
                {noResults}
                {this.state.reports.map(report => (
                  <tr key={report.id}>
                    <Cell>
                      <a href={report.file_url}>{report.filename}</a>
                    </Cell>
                    <Cell>{report.amount_bat}</Cell>
                    <Cell>{report.created_at}</Cell>
                    <Cell>{report.uploaded_by_user}</Cell>
                    <Cell>{this.reportStatus(report)}</Cell>
                  </tr>
                ))}
              </tbody>
            </Table>
          </Card>
        </Container>
      </Wrapper>
    );
  }
}
