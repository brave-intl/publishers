import React from "react";
import { Nav } from "../sections";
import { theme } from "../theme";
import { Grommet } from "grommet";
import SentEmailSection from "../sections/main-section/sentEmail";

export const SentEmail = () => {
  document.title = "Emailed ";
  return (
    <Grommet theme={theme}>
      <Nav />
      <SentEmailSection />
    </Grommet>
  );
};
