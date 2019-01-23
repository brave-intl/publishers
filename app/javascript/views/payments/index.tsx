import * as React from "react";

import { Container, Wrapper } from "../style";
import { Card, Layout, Row } from "./style";

import PaymentHistory from "./paymentHistory";
import PaymentOverview from "./paymentOverview";
import UpholdCard from "./upholdCard";

export default class Referrals extends React.Component {
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
