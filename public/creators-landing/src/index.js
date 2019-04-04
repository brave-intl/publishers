import React from "react";
import ReactDOM from "react-dom";
import { BrowserRouter as Router, Route, Switch } from "react-router-dom";
import { Home, SignUp, LogIn, SentEmail } from "./views";
import "./style/normalize-style.css";
import "./style/style.css";

const App = () => (
  <Router>
    <Switch>
      <Route exact path="/" component={Home} />
      <Route path="/sign-up" component={SignUp} />
      <Route path="/log-in" component={LogIn} />
      <Route path="/sent-email" component={SentEmail} />
    </Switch>
  </Router>
);

ReactDOM.render(<App />, document.getElementById("root"));
