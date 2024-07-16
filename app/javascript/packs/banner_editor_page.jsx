import axios from "axios";
import * as React from "react";
import * as ReactDOM from "react-dom";
import { renderBannerEditor } from "../packs/banner_editor";

document.addEventListener("DOMContentLoaded", () => {
  const crsfToken = document.head
    .querySelector("[name=csrf-token]")
    .getAttribute("content");
  axios.defaults.headers.Accept = "application/json";
  axios.defaults.headers["X-CSRF-Token"] = crsfToken;

  const element =  document.getElementById("rewards-banner-container")
  const props = JSON.parse(element.dataset.props);
  
  axios.get("/publishers/get_site_banner_data").then((response) => {
    let bannerEditorData = response.data;
    let channelBanners = bannerEditorData.channel_banners;

    renderBannerEditor({}, 'USD', 0, channelBanners, "Editor", props.publisher);
  });
});
