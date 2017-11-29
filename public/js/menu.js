(function() {
  function qsl(selector, context) {
    return (context || document).querySelectorAll(selector);
  }

  function forEach(collection, iterator) {
    Object.keys(collection).forEach((key) => {
      iterator(collection[key]);
    });
  }

  function showMenu(menu) {
    const ul = qsl('ul', menu)[0];

    if (!ul || ul.classList.contains('-visible')) return;

    menu.classList.add('-active');
    ul.classList.add('-animating');
    ul.classList.add('-visible');
    setTimeout(() => {
      ul.classList.remove('-animating');
    }, 25);
  }

  function hideMenu(menu) {
    const ul = qsl('ul', menu)[0];

    if (!ul || !ul.classList.contains('-visible')) return;

    menu.classList.remove('-active');
    ul.classList.add('-animating');
    setTimeout(() => {
      ul.classList.remove('-visible');
      ul.classList.remove('-animating');
    }, 300);
  }

  function hideAllInactiveMenus(menu) {
    forEach(
      qsl('li.-hasSubmenu.-active:not(:hover)', menu.parent),
      (e) => {
        hideMenu(e);
      },
    );
  }

  /** TODO:
   * 1. open submenus on hover. (mouseenter : maybe use datalist instead of class to recognise)
   * 2. Clean up code and move into crossbeamsMenu.
   */

  document.addEventListener('DOMContentLoaded', () => {
    document.body.addEventListener('click', hideAllInactiveMenus);
    document.body.addEventListener('click', (event) => {
      if (event.target.parentNode && event.target.parentNode.classList.contains('-hasSubmenu')) {
        showMenu(event.target.parentNode);
        event.stopPropagation();
        event.preventDefault();
      }
    });
  });
})();
