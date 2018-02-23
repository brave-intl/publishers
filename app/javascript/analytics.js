if (document.head.dataset.piwikHost) {
  window._paq = window._paq || [];
  /* tracker methods like "setCustomDimension" should be called before "trackPageView" */
  window._paq.push(['trackPageView']);
  window._paq.push(['enableLinkTracking']);
  (function() {
    var u=document.head.dataset.piwikHost;
    window._paq.push(['setTrackerUrl', u+'piwik.php']);
    window._paq.push(['setSiteId', '6']);
    var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
    g.type='text/javascript'; g.async=true; g.defer=true; g.src=u+'piwik.js'; s.parentNode.insertBefore(g,s);
  })();

  document.addEventListener('click', function (e) {
    e = e || window.event;
    var target = e.target || e.srcElement;

    if (target.dataset.piwikAction) {
      window._paq.push(['trackEvent', target.dataset.piwikAction, target.dataset.piwikName, target.dataset.piwikValue]);
    }
  }, false);
}
