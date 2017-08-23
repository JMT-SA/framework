const crossbeamsMenuBuilder = (function() {
  'use strict'

  let menuLevels = [];

  const buildMenu = (inMenuLevels) => {
    const topLevel = document.getElementById('functional-area-menu');
    let topMenu = '';
    let selected = null;
    const id = crossbeamsLocalStorage.getItem('selectedFuncMenu');

    if (inMenuLevels === undefined) { return null; };

    menuLevels = inMenuLevels;

    menuLevels.functional_areas.forEach((elem) => {
      topMenu += `<li><a href="#" data-menu-level1="${elem.id}">${elem.name}</a></li>`;
    });
    topLevel.innerHTML = topMenu;

    if (id !== null) {
      selected = topLevel.querySelector(`li > a[data-menu-level1="${id}"]`)
      buildSecondLevelMenu(selected);
    }
  }

  // observe level-1 to build level-2

  const buildThirdLevelMenu = (prog_id) => {
    const pfItems = menuLevels.program_functions[prog_id];
    let pfMenu = '<ul>';
    pfItems.forEach((elem) => { // TODO: handle groups...
      pfMenu += `<li><a href="${elem.url}" data-menu-level3="${elem.id}">${elem.name}</a></li>`;
    });
    pfMenu += '</ul>';

    return pfMenu;
  }

  const buildProgramMenu = (func_id) => {
    const progItems = menuLevels.programs[func_id];
    const progLevel = document.getElementById('programs-menu');
    let progMenu = '';
    let pfMenu = '';

    if (progItems === undefined) {
      progLevel.innerHTML = '';
      return null;
    };

    progItems.forEach((elem) => {
      pfMenu = buildThirdLevelMenu(elem.id);
      if (pfMenu === '') {
        progMenu += `<li><a href="#" data-menu-level2="${elem.id}">${elem.name}</a></li>`;
      } else {
        progMenu += `<li class="-hasSubmenu"><a href="#" data-menu-level2="${elem.id}">${elem.name}</a>${pfMenu}</li>`;
      }
    });
    progLevel.innerHTML = progMenu; // TODO: also build sublevels
  }

  const buildSecondLevelMenu = (firstLevelMenu) => {
      firstLevelMenu.parentNode.classList.add('active');
      buildProgramMenu(firstLevelMenu.dataset.menuLevel1);
  }
  /**
   * Assign a click handler to level-1 menu items.
   */
  document.addEventListener('DOMContentLoaded', () => {
    document.body.addEventListener('click', (event) => {
      if (event.target.dataset.menuLevel1) {
        crossbeamsLocalStorage.setItem('selectedFuncMenu', event.target.dataset.menuLevel1); // TODO?: make this per app?
        event.target.parentNode.parentNode.childNodes.forEach((el) => { el.classList.remove('active'); });
        buildSecondLevelMenu(event.target);
        event.stopPropagation();
        event.preventDefault();
      }
      // if (event.target.dataset.menuLevel3) {
      //   console.log('clicked', event.target.dataset.menuLevel3);
      // }
    });
  });

  return {
    buildMenu,
  };

})();
