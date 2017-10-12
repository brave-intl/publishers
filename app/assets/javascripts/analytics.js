//Piwik analytics shim
//data is sent to https://analytics.brave.com

<!-- Piwik -->

  var _paq = _paq || [];
  /* tracker methods like "setCustomDimension" should be called before "trackPageView" */
  _paq.push(['trackPageView']);
  _paq.push(['enableLinkTracking']);
  (function() {
    var u="//analytics.brave.com/";
    _paq.push(['setTrackerUrl', u+'piwik.php']);
    _paq.push(['setSiteId', '6']);
    var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
    g.type='text/javascript'; g.async=true; g.defer=true; g.src=u+'piwik.js'; s.parentNode.insertBefore(g,s);
  })();

<!-- End Piwik Code -->


//trying to track if a user clicked on the verify button for a Wordpress flow
$(document).addEventListener('click', function(e) {
    e = e || window.event;
    var target = e.target || e.srcElement,
        text = target.textContent || text.innerText;
    if (target.dataset.trackWordpress === 1){
       _paq.push(['trackEvent', 'WordpressVerificationClicked', 'Clicked', 'WordpressFlow'])
    }
}, false);
