import * as React from "react";

import {
  Button,
  Card,
  Cell,
  Container,
  Table,
  TableHeader,
  Wrapper
} from "../style";

import ReportsHeader from "../payments/header/Header";
import routes from "../routes";
import { FlexWrapper, ReportHeader } from "./ReportsStyle";

import locale from "../../locale/en";
import UploadDialog from "./uploadDialog/UploadDialog";

const initialState = { showUpload: false };
type IPaymentHistoryState = Readonly<typeof initialState>;

export default class Reports extends React.Component<
  any,
  IPaymentHistoryState
> {
  public readonly state: IPaymentHistoryState = initialState;

  public reloadTable = () => {
    console.log("reload te table");
  };

  public render() {
    return (
      <Wrapper>
        <ReportsHeader />
        <Container>
          <Card>
            <FlexWrapper>
              <ReportHeader>{locale.payments.reports.title}</ReportHeader>
              <UploadDialog
                route={routes.payments.reports.path}
                text={locale.payments.reports.upload}
                afterSave={this.reloadTable}
              />
            </FlexWrapper>

            <Table>
              <thead>
                <tr>
                  <TableHeader>{locale.payments.reports.fileName}</TableHeader>
                  <TableHeader>{locale.payments.reports.createdAt}</TableHeader>
                  <TableHeader>
                    {locale.payments.reports.uploadedBy}
                  </TableHeader>
                </tr>
              </thead>
              <tbody />
            </Table>
          </Card>
        </Container>
      </Wrapper>
    );
  }
}
