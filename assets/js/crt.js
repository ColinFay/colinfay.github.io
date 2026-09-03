// CRT chrome: shell prompt above page titles, blinking prompt at the end of the page.
document.addEventListener('DOMContentLoaded', () => {
  const main = document.getElementById('quarto-document-content') || document.querySelector('main.content');
  if (!main) return;
  const P = '<span class="p">colin@colinfay.me:~$</span>';
  const parts = location.pathname.replace(/\/index\.html$/, '/').split('/').filter(Boolean);
  const title = document.getElementById('title-block-header');
  if (title && parts.length) {
    const file = parts[parts.length - 1].replace(/\.html$/, '') + '.md';
    const cmd = parts[0] === 'posts' ? 'cat ~/blog/' + file : 'cat ~/' + file;
    const d = document.createElement('div');
    d.className = 'crt-prompt';
    d.innerHTML = P + ' ' + cmd;
    title.insertAdjacentElement('beforebegin', d);
    // "// date · #category" under the title, from Quarto's own meta blocks
    const date = title.querySelector('.quarto-title-meta .date, .quarto-title-meta-contents p');
    const cats = [...title.querySelectorAll('.quarto-categories .quarto-category')];
    const bits = [];
    if (date) bits.push(date.textContent.trim());
    cats.forEach(c => { const t = c.textContent.trim(); bits.push('<a href="/categories/#' + t.toLowerCase().replace(/[^a-z0-9]+/g, '-') + '">#' + t + '</a>'); });
    if (bits.length) {
      const m = document.createElement('div');
      m.className = 'crt-meta';
      m.innerHTML = '// ' + bits.join(' · ');
      (title.querySelector('h1.title') || title).insertAdjacentElement('afterend', m);
    }
  }
  const end = document.createElement('div');
  end.className = 'crt-prompt crt-end';
  end.innerHTML = P + ' <span class="crt-cursor" aria-hidden="true"></span>';
  main.appendChild(end);
});
