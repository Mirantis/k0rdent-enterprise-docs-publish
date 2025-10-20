/* Fire a pageview after every client-side navigation (MkDocs-Material) */
if (typeof document$ !== 'undefined') {
  document$.subscribe(() => {
    if (window.plausible) {
      window.plausible('pageview');
    }
  });
}
