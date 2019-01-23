import * as React from "react";

import { Container, Wrapper } from "../style";
import { Card, Layout, Row } from "./style";

import PaymentHistory from "./paymentHistory/PaymentHistory";
import PaymentOverview from "./paymentOverview/PaymentOverview";
import UpholdCard from "./upholdCard/UpholdCard";

export default class Payments extends React.Component {
  public render() {
    return (
      <Wrapper>
        <Container>
          <Layout>
            <Row>
              <Card>
                <PaymentOverview />
              </Card>
              <Card>
                <UpholdCard name="AliceBlogette" />
              </Card>
            </Row>
            <Card>
              <PaymentHistory />
            </Card>
          </Layout>
        </Container>
      </Wrapper>
    );
  }
}
