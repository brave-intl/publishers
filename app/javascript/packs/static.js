import "analytics";

(function() {
  // After the javascript has loaded request the fonts
  let ss = document.createElement("link");
  ss.type = "text/css";
  ss.rel = "stylesheet";
  ss.href =
    "https://fonts.googleapis.com/css?family=Muli:300,400,700|Poppins:300,500";
  document.getElementsByTagName("head")[0].appendChild(ss);
})();
