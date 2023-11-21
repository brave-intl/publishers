import axios from "axios";
import * as React from "react";
import * as ReactDOM from "react-dom";
import CryptoWalletServices from "../views/cryptoWalletServices/CryptoWalletServices";
import { IntlProvider } from "react-intl";
import en, { flattenMessages } from "../locale/en";
import ja from "../locale/ja";

document.addEventListener("DOMContentLoaded", () => {
  const crsfToken = document.head
    .querySelector("[name=csrf-token]")
    .getAttribute("content");
  axios.defaults.headers.Accept = "application/json";
  axios.defaults.headers["X-CSRF-Token"] = crsfToken;

  const locale = document.body.dataset.locale;
  let localePackage = en;
  if (locale === "ja") {
    localePackage = ja;
  }

  const channels = document.querySelectorAll(".crypto-wallet-services")

  const createStore = (reducer, initialState) => {
    const store = {};

    store.state = initialState;
    store.listeners = [];
    store.subscribe = listener => store.listeners.push(listener);
    store.dispatch = async action => {
      store.state = await reducer(store.state, action);
      store.listeners.forEach(listener => listener(action));
    };
    store.getState = () => store.state;

    return store;
  };

  const initialState = {
    addressesInUse: []
  };

  const reducer = async (state = initialState, action) => {
    if ( action.type === "ADD_ADDRESS" ) {
      state.addressesInUse.push(action.payload.newAddress);
      return state;
    } else if (action.type === "REMOVE_ADDRESS") {
      const idx = state.addressesInUse.findIndex(address => address.id === action.payload.addressId);
      return idx > -1 ? { addressesInUse: state.addressesInUse.splice(idx, 1) } : state;
    }
  }

  const store = createStore(reducer, initialState);

  channels.forEach((channel) => {
    const props = JSON.parse(channel.dataset.props);
    props.store = store;
    
    ReactDOM.render(
      <IntlProvider locale={locale} messages={flattenMessages(localePackage)}>
        <CryptoWalletServices {...props} />
      </IntlProvider>,
      channel
    );
  });
});
