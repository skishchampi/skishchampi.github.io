document.addEventListener('DOMContentLoaded', function () {
  var btn = document.getElementById('theme-toggle');
  if (!btn) return;

  btn.addEventListener('click', function () {
    // Add transition class so the switch is smooth, but only on click
    document.body.classList.add('theme-transitioning');

    var current = document.documentElement.getAttribute('data-theme');
    var next = current === 'dark' ? 'light' : 'dark';
    document.documentElement.setAttribute('data-theme', next);
    localStorage.setItem('theme', next);

    setTimeout(function () {
      document.body.classList.remove('theme-transitioning');
    }, 300);
  });
});
