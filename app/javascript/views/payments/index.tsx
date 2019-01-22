import * as React from "react";

import { Container, Wrapper } from "../style";
import { Layout, Row } from "./style";
import PaymentOverview from "./paymentOverview";
import UpholdCard from "./upholdCard";
import PaymentHistory from "./paymentHistory";

export default class Referrals extends React.Component {
  public render() {
    return (
      <Wrapper>
        <Container>
          <Layout>
            <Row>
              <PaymentOverview />
              <UpholdCard name="AliceBlogette" />
            </Row>
            <PaymentHistory />
          </Layout>
        </Container>
      </Wrapper>
    );
  }
}
