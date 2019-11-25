import React, { Component } from "react";
import * as ReactDOM from "react-dom";
import Select from "react-select";
import CreatableSelect from "react-select/creatable";

document.addEventListener("DOMContentLoaded", function() {
  document.querySelectorAll(".searchForm").forEach(element => {
    const props = JSON.parse(element.dataset.props);

    const optionsMap = props.options.map(x => ({
      value: x,
      label: x
    }));

    const defaultValue = optionsMap.find(x => x.label == props.defaultValue);

    let select = undefined;

    const selectProps = {
      options: optionsMap,
      name: props.name || "filter",
      defaultValue: defaultValue
    };

    if (props.creatable) {
      select = <CreatableSelect {...selectProps} />;
    } else {
      select = <Select {...selectProps} />;
    }

    ReactDOM.render(select, element);
  });
});

document.addEventListener("DOMContentLoaded", function() {
  const copyToClipboard = str => {
    const el = document.createElement("textarea");
    el.value = str;
    document.body.appendChild(el);
    el.select();
    document.execCommand("copy");
    document.body.removeChild(el);
  };

  document.getElementById("copyRefCodes").onclick = () => {
    let string = ""
    document
      .querySelectorAll("input[name^='referral_codes[']:checked")
      .forEach(e => string += `https://laptop-updates.brave.com/download/${e.value}\n`);
    copyToClipboard(string);
  };
});
