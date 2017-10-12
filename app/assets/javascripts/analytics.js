if (document.head.dataset.piwikHost) {
  var _paq = _paq || [];
  /* tracker methods like "setCustomDimension" should be called before "trackPageView" */
  _paq.push(['trackPageView']);
  _paq.push(['enableLinkTracking']);
  (function() {
    var u=document.head.dataset.piwikHost;
    _paq.push(['setTrackerUrl', u+'piwik.php']);
    _paq.push(['setSiteId', '6']);
    var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
    g.type='text/javascript'; g.async=true; g.defer=true; g.src=u+'piwik.js'; s.parentNode.insertBefore(g,s);
  })();

  document.addEventListener('click', function (e) {
    e = e || window.event;
    var target = e.target || e.srcElement;

    // Track if a user clicked on the verify button for a Wordpress flow
    if (target.dataset.trackWordpress) {
      _paq.push(['trackEvent', 'WordpressVerificationClicked', 'Clicked', 'WordpressFlow']);
    }
  }, false);
}
