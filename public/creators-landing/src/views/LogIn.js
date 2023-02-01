import React from "react";
import { Nav } from "../sections";
import { theme } from "../theme";
import { Grommet } from "grommet";
import { MainSignIn } from "../sections/main-section";

export const LogIn = () => {
  document.title = "Log In - Brave Creators";
  return (
    <Grommet style={{height:"100%"}} theme={theme}>
      <Nav />
      <MainSignIn />
    </Grommet>
  );
};
