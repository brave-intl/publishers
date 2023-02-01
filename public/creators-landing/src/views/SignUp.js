import React from "react";
import { Nav } from "../sections";
import { theme } from "../theme";
import { Grommet } from "grommet";
import { MainSignUp } from "../sections/main-section";

export const SignUp = () => {
  document.title = "Become a Creator - Brave Creators";
  return (
    <Grommet style={{height:"100%"}} theme={theme}>
      <Nav />
      <MainSignUp />
    </Grommet>
  );
};
