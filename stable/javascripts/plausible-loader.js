// docs/javascripts/plausible-loader.js
(function() {
  var s = document.createElement('script');
  s.async = true;
  s.src = 'https://plausible.io/js/pa-Xfh1nboraWR_Grq3rwHpu.js'; // your custom Plausible script URL
  document.head.appendChild(s);

  // Provide Plausible’s queue + init API
  window.plausible = window.plausible || function(){ (plausible.q = plausible.q || []).push(arguments) };
  plausible.init = plausible.init || function(opts){ plausible.o = opts || {} };
  plausible.init({
    // domain: 'docs.k0rdent-enterprise.io' // optional
  });
})();
