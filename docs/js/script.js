// Documentation Content Dictionary
const docsContent = {
  'intro': `
    <h2>Introduction</h2>
    <p>Argonaut is a library for parsing command-line arguments in Zig. It aims to provide a pleasant Developer Experience (DX) without sacrificing performance.</p>
    <p>It supports flags, positional arguments, subcommands, and generates help messages automatically.</p>
  `,
  'install': `
    <h2>Installation</h2>
    <p>Argonaut is available via the Zig Build System.</p>
    <h3>1. Fetch the dependency</h3>
    <pre><code>zig fetch --save=argonaut git+https://github.com/OhMyDitzzy/argonaut</code></pre>
    <h3>2. Add to build.zig</h3>
    <pre><code>const argonaut = b.dependency("argonaut", .{
    .target = target,
    .optimize = optimize,
});
exe.root_module.addImport("argonaut", argonaut.module("argonaut"));</code></pre>
  `,
  'quickstart': `
    <h2>Quick Start</h2>
    <p>Create a <code>main.zig</code> file:</p>
    <pre><code>const std = @import("std");
const argsparse = @import("argonaut");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // 1. Init Parser
    var parser = try argsparse.newParser(allocator, "demo", "A demo app");
    defer parser.deinit();

    // 2. Define Args
    const name = try parser.string("n", "name", "Your Name");
    const count = try parser.int("c", "count", "Repetitions");

    // 3. Parse
    const args = try std.process.argsAlloc(allocator);
    try parser.parse(args);

    // 4. Use logic
    std.debug.print("Hello {s}\\n", .{name.*});
}</code></pre>
  `,
  'api': `
    <h2>Core Methods</h2>
    <p>These methods define arguments on the parser instance.</p>
    <ul>
        <li><code>flag(short, long, help)</code>: Returns <code>*bool</code></li>
        <li><code>string(short, long, help)</code>: Returns <code>*[]const u8</code></li>
        <li><code>int(short, long, help)</code>: Returns <code>*i64</code></li>
        <li><code>float(short, long, help)</code>: Returns <code>*f64</code></li>
    </ul>
  `,
  'subcommands': `
    <h2>Subcommands</h2>
    <p>Argonaut handles nested commands gracefully.</p>
    <pre><code>var cmd = try parser.command("server", "Start the server");
const port = try cmd.int("p", "port", "Port to listen on");

try parser.parse(args);

if (cmd.happened()) {
    // Start server logic...
}</code></pre>
  `
};

// Application Logic
const app = {
  elements: {
    home: document.getElementById('home'),
    docs: document.getElementById('docs'),
    menu: document.getElementById('mobileMenu'),
    btn: document.getElementById('hamburgerBtn'),
    docBody: document.getElementById('doc-content'),
    year: document.getElementById('yr')
  },

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

  render: function(hash) {
    const key = hash.replace(/^#/, '') || 'home';
    const isDocs = key.startsWith('docs');
    
    // Toggle Pages
    this.elements.home.classList.toggle('hidden', isDocs);
    this.elements.docs.classList.toggle('hidden', !isDocs);

    // Inject Content
    if(isDocs) {
      const slug = key.split('/')[1] || 'intro';
      this.elements.docBody.innerHTML = docsContent[slug] || '<h2>404 Not Found</h2>';
    }

    // Update Active Links
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
    this.elements.year.innerText = new Date().getFullYear();
    window.addEventListener('popstate', () => this.render(location.hash));
    this.render(location.hash);
  }
};

// Start the app
app.init();
