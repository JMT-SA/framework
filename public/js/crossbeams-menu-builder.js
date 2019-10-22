const crossbeamsMenuBuilder = (function crossbeamsMenuBuilder() {
  let menuLevels = {};

  const buildThirdLevelMenu = (progId) => {
    const pfItems = menuLevels.program_functions[progId];
    let pfMenu = '<ul>';
    let group = null;
    pfItems.forEach((elem) => {
      if (group !== null && group !== elem.group_name) {
        pfMenu += '</ul></li>';
      }
      if (group !== elem.group_name && elem.group_name !== null) {
        pfMenu += `<li class="-hasSubmenu -hasLevel3Submenu"><a href="#">${elem.group_name}</a><ul>`;
      }
      group = elem.group_name;
      pfMenu += `<li><a href="${elem.url}" data-menu-parent="${progId}" data-menu-level3="${elem.id}">${elem.name}</a></li>`;
    });
    if (group !== null) {
      pfMenu += '</ul></li>';
    }
    pfMenu += '</ul>';

    return pfMenu;
  };

  const buildProgramMenu = (funcId) => {
    const progItems = menuLevels.programs[funcId];
    const progLevel = document.getElementById('programs-menu');
    const selectedProgId = crossbeamsLocalStorage.getItem('selectedProgMenu');
    let progMenu = '';
    let pfMenu = '';
    let pSel = '';

    if (progItems === undefined) {
      progLevel.innerHTML = '';
      return;
    }

    progItems.forEach((elem) => {
      pfMenu = buildThirdLevelMenu(elem.id);
      pSel = (selectedProgId === elem.id) ? ' menu-prog-selected' : '';
      if (pfMenu === '') {
        progMenu += `<li><a href="#" data-menu-level2="${elem.id}">${elem.name}</a></li>`;
      } else {
        progMenu += `<li class="-hasSubmenu${pSel}"><a href="#" data-menu-level2="${elem.id}">${elem.name}</a>${pfMenu}</li>`;
      }
    });
    progLevel.innerHTML = progMenu;
  };

  const buildSecondLevelMenu = (firstLevelMenu) => {
    firstLevelMenu.parentNode.classList.add('active');
    buildProgramMenu(firstLevelMenu.dataset.menuLevel1);
  };

  const buildMenu = (inMenuLevels) => {
    const topLevel = document.getElementById('functional-area-menu');
    let topMenu = '';
    let selected = null;
    const id = crossbeamsLocalStorage.getItem('selectedFuncMenu');

    if (inMenuLevels === undefined) { return; }

    menuLevels = inMenuLevels;

    menuLevels.functional_areas.forEach((elem) => {
      topMenu += `<li><a href="#" data-menu-level1="${elem.id}">${elem.name}</a></li>`;
    });
    topLevel.innerHTML = topMenu;

    if (id !== null) {
      selected = topLevel.querySelector(`li > a[data-menu-level1="${id}"]`);
      // If user has been switched, the id might refer to a menu item that
      // the new user does not have permission for, so skip this step:
      if (selected) {
        buildSecondLevelMenu(selected);
      }
    }
  };

  /**
   * Search 3rd level menu captions for matches on the term.
   * @param {string} term - the search term to match against menu items..
   * @returns {array} matches - the matching menu items.
   */
  const searchMenu = (term) => {
    if (term === '') { return []; }
    let matches = [];
    const interim = Object.values(menuLevels.program_functions) || [];
    matches = interim.flat().filter(pf => pf.name.toUpperCase().indexOf(term.toUpperCase()) > -1);
    return matches;
  };

  /**
   * Assign a click handler to level-1 menu items.
   */
  document.addEventListener('DOMContentLoaded', () => {
    const searchBox = document.querySelector('#menuSearch');
    const resultsList = document.querySelector('#menuSearchResults');

    searchBox.addEventListener('keyup', (event) => {
      if (event.keyCode === 27) { // ESC
        resultsList.innerHTML = '';
        resultsList.style.display = 'none';
      }
    });

    searchBox.addEventListener('change', () => {
      const results = searchMenu(searchBox.value);
      let listItems = '';
      let progName = '';
      let funcName = '';
      let displayName = '';
      results.forEach((menu) => {
        funcName = menuLevels.functional_areas.find(elem => elem.id === menu.func_id).name;
        progName = menuLevels.programs[menu.func_id].find(elem => elem.id === menu.prog_id).name;
        displayName = menu.group_name ? ` (${menu.group_name}) ` : '';
        listItems += `<li><a href="${menu.url}" data-menu-parent="${menu.prog_id}" data-menu-level3="${menu.id}" data-menu-func="${menu.func_id}"><span class="search-menu-result-ancestor">${funcName}/${progName}${displayName}:</span> ${menu.name}</a></li>`;
      });
      resultsList.innerHTML = listItems;
      resultsList.style.display = 'block';
    });

    document.body.addEventListener('click', (event) => {
      if (event.target === searchBox) {
        resultsList.style.display = 'block';
      } else {
        resultsList.style.display = 'none';
      }

      if (event.target.dataset.menuLevel1) {
        crossbeamsLocalStorage.setItem('selectedFuncMenu', event.target.dataset.menuLevel1); // TODO?: make this per app?
        Array.from(event.target.parentNode.parentNode.children).forEach((el) => { el.classList.remove('active'); });
        buildSecondLevelMenu(event.target);
        event.stopPropagation();
        event.preventDefault();
      }
      if (event.target.dataset.menuLevel3) {
        crossbeamsLocalStorage.setItem('selectedProgMenu', event.target.dataset.menuParent);
        if (event.target.dataset.menuFunc) {
          crossbeamsLocalStorage.setItem('selectedFuncMenu', event.target.dataset.menuFunc);
        }
      }
    });
  });

  return {
    buildMenu,
    searchMenu,
  };
}());
