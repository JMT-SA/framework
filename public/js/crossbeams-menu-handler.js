(function crossbeamsMenuHandler() {
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

  document.addEventListener('DOMContentLoaded', () => {
    document.body.addEventListener('click', hideAllInactiveMenus);
    document.body.addEventListener('click', (event) => {
      if (event.target.parentNode && event.target.parentNode.classList.contains('-hasSubmenu')) {
        showMenu(event.target.parentNode);
        event.stopPropagation();
        event.preventDefault();
      }
    });

    /**
     * Show level 3 submenus on hover of the parent menu item.
     */
    forEach(
      qsl('#programs-menu'),
      (e) => {
        e.addEventListener('mouseover', (event) => {
          if (event.target.parentNode && event.target.parentNode.classList.contains('-hasLevel3Submenu')) {
            hideAllInactiveMenus(event.target);
            showMenu(event.target.parentNode);
          }
        });
      },
    );
  });
}());
