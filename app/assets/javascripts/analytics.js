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

    // A switch would feel better, but would eval on target.dataset actually work?
    if (target.dataset.trackWordpress) {
      _paq.push(['trackEvent', 'WordpressVerificationClicked', 'Clicked', 'WordpressFlow']);
    }else if (target.dataset.trackPublicFile) {
      _paq.push(['trackEvent', 'PublicFileVerificationClicked', 'Clicked', 'PublicFileFlow']);
    }else if (target.dataset.trackGithub) {
      _paq.push(['trackEvent', 'GithubVerificationClicked', 'Clicked', 'GithubFlow']);
    }else if (target.dataset.trackDns) {
      _paq.push(['trackEvent', 'DNSVerificationClicked', 'Clicked', 'DNSFlow']);
    }else if (target.dataset.trackAddedContactInfo) {
      _paq.push(['trackEvent', 'ContactInfoClicked', 'Clicked', 'ContactInfoFlow']);
    }else if (target.dataset.trackChoseTrustedFile) {
      _paq.push(['trackEvent', 'ChosePublicFileClicked', 'Clicked', 'ChooserFlow']);
    }else if (target.dataset.trackChoseDns) {
      _paq.push(['trackEvent', 'ChoseDNSClicked', 'Clicked', 'ChooserFlow']);
    }else if (target.dataset.trackChoseSupport) {
      _paq.push(['trackEvent', 'ChoseSupportClicked', 'Clicked', 'ChooserFlow']);
    }else if (target.dataset.trackReturnToOptions) {
      _paq.push(['trackEvent', 'ReturnToOptionsClicked', 'Clicked', 'ChooserFlow']);
    }else if (target.dataset.trackConnectToUphold) {
      _paq.push(['trackEvent', 'ConnectToUpholdClicked', 'Clicked', 'PostVerificationFlow']);
    }
  }, false);
}
