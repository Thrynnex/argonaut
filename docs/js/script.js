const app = {
  elements: {
    home: document.getElementById('home'),
    docs: document.getElementById('docs'),
    menu: document.getElementById('mobileMenu'),
    btn: document.getElementById('hamburgerBtn'),
    docBody: document.getElementById('doc-content'),
    year: document.getElementById('yr')
  },

  // CACHE SYSTEM: Prevents loading same file twice
  cache: {},

  toggleMenu: function() {
    const isOpen = this.elements.menu.classList.toggle('is-open');
    this.elements.btn.classList.toggle('is-active', isOpen);
    document.body.style.overflow = isOpen ? 'hidden' : '';
  },

  closeMenu: function() {
    this.elements.menu.classList.remove('is-open');
    this.elements.btn.classList.remove('is-active');
    document.body.style.overflow = '';
  },

  // Load Markdown from 'details/' folder with Caching
  loadMarkdown: async function(slug) {
    // 1. Check Cache (Instant Load)
    if (this.cache[slug]) {
      this.elements.docBody.innerHTML = this.cache[slug];
      return;
    }

    // 2. Show Loading State
    this.elements.docBody.innerHTML = '<div style="padding:20px; color:#888; font-weight:600;">Loading...</div>';
    
    try {
      // 3. Fetch file
      const response = await fetch(`details/${slug}.md`);
      
      if (!response.ok) throw new Error('File not found');

      const markdown = await response.text();
      let htmlContent = '';

      // 4. Parse (Marked.js)
      if (typeof marked !== 'undefined') {
        htmlContent = marked.parse(markdown);
      } else {
        htmlContent = `<pre>${markdown}</pre>`;
        console.warn("Marked.js library is missing.");
      }

      // 5. Save to Cache
      this.cache[slug] = htmlContent;

      // 6. Render
      this.elements.docBody.innerHTML = htmlContent;

    } catch (error) {
      this.elements.docBody.innerHTML = `
        <h2>Error 404</h2>
        <p>Could not load: <code>details/${slug}.md</code></p>
        <p style="font-size:14px; color:#c026d3;">
          <strong>Tip:</strong> If you are opening this file locally, 
          you must use a local server (localhost), not just double-click index.html.
        </p>
      `;
    }
  },

  render: function(hash) {
    const key = hash.replace(/^#/, '') || 'home';
    const isDocs = key.startsWith('docs');
    
    // Toggle Pages
    this.elements.home.classList.toggle('hidden', isDocs);
    this.elements.docs.classList.toggle('hidden', !isDocs);

    // Load Content
    if(isDocs) {
      const slug = key.split('/')[1] || 'intro';
      this.loadMarkdown(slug);
    }

    // Update Active States
    document.querySelectorAll('[data-route]').forEach(el => {
      const route = el.dataset.route;
      const isActive = (key === 'home' && route === '#home') || 
                       (isDocs && route.includes(key));
      el.classList.toggle('active', isActive);
    });
    
    window.scrollTo(0,0);
  },

  navigate: function(hash) {
    history.pushState(null, null, hash);
    this.render(hash);
  },

  init: function() {
    if(this.elements.year) this.elements.year.innerText = new Date().getFullYear();
    window.addEventListener('popstate', () => this.render(location.hash));
    this.render(location.hash);
  }
};

app.init();
