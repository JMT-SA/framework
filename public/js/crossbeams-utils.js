/* exported crossbeamsUtils */

/**
 * General utility functions for Crossbeams.
 * @namespace
 */
const crossbeamsUtils = {

  currentDialogLevel: function currentDialogLevel() {
    if (crossbeamsDialogLevel2.shown) {
      return 2;
    }
    if (crossbeamsDialogLevel1.shown) {
      return 1;
    }
    return 0;
  },

  nextDialogError: function nextDialogError() {
    switch (this.currentDialogLevel()) {
      case 2:
        return 'dialog-error-level2';
      case 1:
        return 'dialog-error-level2';
      default:
        return 'dialog-error-level1';
    }
  },

  nextDialogContent: function nextDialogContent() {
    switch (this.currentDialogLevel()) {
      case 2:
        return 'dialog-content-level2';
      case 1:
        return 'dialog-content-level2';
      default:
        return 'dialog-content-level1';
    }
  },

  nextDialogTitle: function nextDialogTitle() {
    switch (this.currentDialogLevel()) {
      case 2:
        return 'dialogTitleLevel2';
      case 1:
        return 'dialogTitleLevel2';
      default:
        return 'dialogTitleLevel1';
    }
  },

  nextDialog: function nextDialog() {
    switch (this.currentDialogLevel()) {
      case 2:
        return crossbeamsDialogLevel2;
      case 1:
        return crossbeamsDialogLevel2;
      default:
        return crossbeamsDialogLevel1;
    }
  },

  activeDialogError: function activeDialogError() {
    switch (this.currentDialogLevel()) {
      case 2:
        return 'dialog-error-level2';
      case 1:
        return 'dialog-error-level1';
      default:
        return 'dialog-error-level1';
    }
  },

  activeDialogContent: function activeDialogContent() {
    switch (this.currentDialogLevel()) {
      case 2:
        return 'dialog-content-level2';
      case 1:
        return 'dialog-content-level1';
      default:
        return 'dialog-content-level1';
    }
  },

  activeDialogTitle: function activeDialogTitle() {
    switch (this.currentDialogLevel()) {
      case 2:
        return 'dialogTitleLevel2';
      case 1:
        return 'dialogTitleLevel1';
      default:
        return 'dialogTitleLevel1';
    }
  },

  activeDialog: function activeDialog() {
    switch (this.currentDialogLevel()) {
      case 2:
        return crossbeamsDialogLevel2;
      case 1:
        return crossbeamsDialogLevel1;
      default:
        return crossbeamsDialogLevel1;
    }
  },

  recordGridIdForPopup: function recordGridIdForPopup(gridId) {
    let key = '';
    switch (this.currentDialogLevel()) {
      case 2:
        key = 'level2PopupOnGrid';
        break;
      case 1:
        key = 'level1PopupOnGrid';
        break;
      default:
        key = 'level0PopupOnGrid';
    }
    crossbeamsLocalStorage.setItem(key, gridId);
  },

  currentGridIdForPopup: function currentGridIdForPopup() {
    let key = '';
    switch (this.currentDialogLevel()) {
      case 2:
        key = 'level2PopupOnGrid';
        break;
      case 1:
        key = 'level1PopupOnGrid';
        break;
      default:
        key = 'level0PopupOnGrid';
    }
    return crossbeamsLocalStorage.getItem(key);
  },

  baseGridIdForPopup: function baseGridIdForPopup() {
    let key = '';
    switch (this.currentDialogLevel()) {
      case 2:
        key = 'level1PopupOnGrid';
        break;
      case 1:
        key = 'level0PopupOnGrid';
        break;
      default:
        key = 'level0PopupOnGrid';
    }
    return crossbeamsLocalStorage.getItem(key);
  },

  /**
   * Display an ERROR notice on the page.
   * @param {string} text - the message to display.
   * @param {null/integer} - the time to keep the message on the screen.
   */
  showError: function showError(text, delay) {
    if (delay) {
      Jackbox.error(text, { time: delay });
    } else {
      Jackbox.error(text, { time: 20 });
    }
  },
  /**
   * Display a WARNING notice on the page.
   * @param {string} text - the message to display.
   * @param {null/integer} - the time to keep the message on the screen.
   */
  showWarning: function showWarning(text, delay) {
    if (delay) {
      Jackbox.warning(text, { time: delay });
    } else {
      Jackbox.warning(text);
    }
  },
  /**
   * Display a SUCCESS notice on the page.
   * @param {string} text - the message to display.
   * @param {null/integer} - the time to keep the message on the screen.
   */
  showSuccess: function showSuccess(text, delay) {
    if (delay) {
      Jackbox.success(text, { time: delay });
    } else {
      Jackbox.success(text);
    }
  },
  /**
   * Display an INFORMATION notice on the page.
   * @param {string} text - the message to display.
   * @param {null/integer} - the time to keep the message on the screen.
   */
  showInformation: function showInformation(text, delay) {
    if (delay) {
      Jackbox.information(text, { time: delay });
    } else {
      Jackbox.information(text);
    }
  },

  /**
   * Save a grid's current row id for bookmarking.
   * Up to 20 grids row ids are cached.
   * @param {string/integer} rowId - the value of the `id` column of the current row.
   * @return {void}
   */
  recordGridRowBookmark: function recordGridRowBookmark(rowId) {
    const key = 'gridBookmarks';
    // Match the url with queryparams but without host & port
    const url = window.location.href.replace(window.location.origin, '');
    let urlSet = [];
    if (crossbeamsLocalStorage.hasItem(key)) {
      urlSet = crossbeamsLocalStorage.getItem(key);
      if (urlSet.length > 20) {
        urlSet.shift();
      }
      urlSet = urlSet.filter(item => item.url !== url);
    }
    urlSet.push({ url, rowId });
    crossbeamsLocalStorage.setItem(key, urlSet);
  },

  /**
   * Get the bookmark for a grid.
   * @return {string/integer} rowId - the value of the `id` column of the bookmarked row.
   */
  currentGridRowBookmark: function currentGridRowBookmark() {
    const key = 'gridBookmarks';
    // Store the url with queryparams but without host & port
    const url = window.location.href.replace(window.location.origin, '');
    const urlSet = crossbeamsLocalStorage.getItem(key);

    if (urlSet === null) {
      return null;
    }
    const result = urlSet.find(elem => elem.url === url);
    if (result === undefined) {
      return null;
    }
    return result.rowId;
  },

  /**
   * Replace the content of the active dialog window.
   * @param {string} data - the new content.
   * @returns {void}
   */
  setDialogContent: function setDialogContent(data) {
    const dlg = document.getElementById(this.activeDialogContent());
    dlg.innerHTML = data;
    crossbeamsUtils.makeMultiSelects();
    crossbeamsUtils.makeSearchableSelects();
    crossbeamsUtils.applySelectEvents();
    const grids = dlg.querySelectorAll('[data-grid]');
    grids.forEach((grid) => {
      const gridId = grid.getAttribute('id');
      const gridEvent = new CustomEvent('gridLoad', { detail: gridId });
      document.dispatchEvent(gridEvent);
    });
    const sortable = Array.from(dlg.getElementsByTagName('input')).filter(a => a.dataset && a.dataset.sortablePrefix);
    sortable.forEach(elem => crossbeamsUtils.makeListSortable(elem.dataset.sortablePrefix,
                                                              elem.dataset.sortableGroup));

    // Repeating request: Check if there are any areas in the content that should be modified by polling...
    const pollsters = dlg.querySelectorAll('[data-poll-message-url]');
    pollsters.forEach((pollable) => {
      const pollUrl = pollable.dataset.pollMessageUrl;
      const pollInterval = pollable.dataset.pollMessageInterval;
      crossbeamsUtils.pollMessage(pollable, pollUrl, pollInterval);
    });
  },

  /**
   * Show a popup dialog window and make an AJAX call to populate the dialog.
   * @param {string} title - the title to show in the dialog.
   * @param {string} href - the url to call to load the dialog main content.
   * @returns {void}
   */
  popupDialog: function popupDialog(title, href) {
    document.getElementById(this.nextDialogTitle()).innerHTML = title;
    document.getElementById(this.nextDialogContent()).innerHTML = '';
    // document.getElementById(this.nextDialogError()).style.display = 'none';
    fetch(href, {
      method: 'GET',
      headers: new Headers({
        'X-Custom-Request-Type': 'Fetch',
      }),
      credentials: 'same-origin',
    }).then((response) => {
      if (response.status === 404) {
        // const err = document.getElementById(this.activeDialogError());
        // err.innerHTML = '<strong>404</strong><br>The requested URL could not be found.';
        // err.style.display = 'block';
        document.getElementById(this.activeDialogTitle()).innerHTML = '<span class="light-red">404</span>';
        crossbeamsUtils.setDialogContent('The requested URL could not be found.');
        console.log('404', href); // eslint-disable-line no-console
        return {};
      }
      return response.json();
    }).then((data) => {
      if (data.flash) {
        let noteStyle = 'error';
        if (data.flash.type && data.flash.type === 'permission') {
          noteStyle = 'warning';
          document.getElementById(this.activeDialogTitle()).innerHTML = '<span class="light-red">Permission error</span>';
        } else {
          document.getElementById(this.activeDialogTitle()).innerHTML = '<span class="light-red">Error</span>';
        }
        if (data.replaceDialog) {
          crossbeamsUtils.setDialogContent(data.replaceDialog.content);
          if (data.flash.type && data.flash.type === 'permission') {
            crossbeamsUtils.showWarning(data.flash.error, 20);
          } else {
            crossbeamsUtils.showError(data.flash.error);
          }
        } else if (data.actions) {
          crossbeamsUtils.processActions(data.actions);
        } else {
          crossbeamsUtils.setDialogContent(`<div class="mt3"><div class="crossbeams-${noteStyle}-note"><p>${data.flash.error}</p></div></div>`);
        }
        if (data.exception) {
          if (data.backtrace) {
            console.groupCollapsed('EXCEPTION:', data.exception, data.flash.error); // eslint-disable-line no-console
            console.info('==Backend Backtrace=='); // eslint-disable-line no-console
            console.info(data.backtrace.join('\n')); // eslint-disable-line no-console
            console.groupEnd(); // eslint-disable-line no-console
          }
        }
      } else if (data.actions) {
        crossbeamsUtils.processActions(data.actions);
      } else if (data.replaceDialog) {
        crossbeamsUtils.setDialogContent(data.replaceDialog.content);
      }
    }).catch((data) => {
      crossbeamsUtils.fetchErrorHandler(data);
      // const htmlText = data.responseText ? data.responseText : '';
      // document.getElementById(this.activeDialogContent()).innerHTML = htmlText;
    });
    this.nextDialog().show();
  },

  /**
   * Close the popup dialog window.
   * @returns {void}
   */
  closePopupDialog: function closePopupDialog() {
    this.activeDialog().hide();
  },

  /**
   * Show a popup dialog window with the provided title and text.
   * @param {string} title - the title to show in the dialog.
   * @param {string} text - the text to serve as the main body of the dialog.
   * @returns {void}
   */
  showHtmlInDialog: function showHtmlInDialog(title, text) {
    document.getElementById(this.nextDialogTitle()).innerHTML = title;
    document.getElementById(this.nextDialogContent()).innerHTML = text;
    this.nextDialog().show();
  },

  /**
   * Load a URL in a new browser window with a "Loading" animation.
   * @param {string} url - the URL to load.
   * @returns {void}
   */
  loadingWindow: function loadingWindow(url) {
    crossbeamsLocalStorage.setItem('load_in_new_window', url);
    const windowReturn = window.open('/loading_window', '_blank', 'titlebar=no,location=no,status');
    if (windowReturn === null) {
      crossbeamsUtils.alert({
        prompt: 'Perhaps the browser is blocking popup windows and you just need to change the setting.',
        title: 'The window did not seem to load',
        type: 'warning',
      });
    }
  },
  /**
   * On button click, unpack rules from the button element and use a fetch
   * request to show a grid in a dialog where the user can choose a row.
   *
   * @param {node} element - a button element.
   * @returns {void}
   */
  showLookupGrid: function showLookupGrid(element) {
    const lkpName = element.dataset.lookupName;
    const lkpKey = element.dataset.lookupKey;
    const paramKeys = JSON.parse(element.dataset.paramKeys);
    const paramValues = JSON.parse(element.dataset.paramValues);
    // console.log(lkpName, lkpKey, paramKeys, paramValues);
    const queryParam = {};
    paramKeys.forEach((key) => {
      let val = paramValues[key];
      if (val === undefined) {
        const e = document.getElementById(key);
        val = e.value;
      }
      queryParam[key] = val;
    });
    // Could be no params...
    const url = `/lookups/${lkpName}/${lkpKey}?${crossbeamsUtils.buildQueryString(queryParam)}`;
    // console.log('URL:', url);
    crossbeamsUtils.popupDialog(element.textContent, url);
  },

  /**
   * Take selected options from a multiselect and return them in a sequence
   * that matches an array of selected ids.
   *
   * @param {node} sel - a select DOM node;
   * @param {array} sortedIds - a list of ids in a particular sequence.
   * @returns {array} out - the sorted options.
   */
  getSelectedIdsInStep: function getSelectedIdsInStep(sel, sortedIds) {
    const usedIds = [];
    const out = [];
    const selAr = Array.from(sel.selectedOptions);
    sortedIds.forEach((id) => {
      const found = selAr.find(a => a.value === id);
      if (found) {
        out.push(found);
        usedIds.push(id);
      }
    });
    Array.from(sel.selectedOptions).forEach((opt) => {
      if (usedIds.indexOf(opt.value) === -1) {
        out.push(opt);
      }
    });
    return out;
  },

  /**
   * Applies the multi skin to multiselect dropdowns.
   * @returns {void}
   */
  makeMultiSelects: function makeMultiSelects() {
    const sels = document.querySelectorAll('[data-multi]');
    sels.forEach((sel) => {
      multi(sel, {
        non_selected_header: 'Options',
        selected_header: 'Selected',
      }); // multi select with two panes...

      // observeChange behaviour - call specified urls on change of selection.
      if (sel.dataset && sel.dataset.observeChange) {
        sel.addEventListener('change', () => {
          const s = sel.dataset.observeChange;
          const j = JSON.parse(s);
          const option = Array.from(sel.selectedOptions).map(opt => opt.value).join(',');
          const urls = j.map(el => this.buildObserveChangeUrl(el, option));

          urls.forEach(url => this.fetchDropdownChanges(url));
        });
      }

      // observeSelected behaviour - get rules from select element and
      // add selected options to a sortable element.
      if (sel.dataset && sel.dataset.observeSelected) {
        sel.addEventListener('change', () => {
          const s = sel.dataset.observeSelected;
          const j = JSON.parse(s);
          const targets = j.map(el => el.sortable);

          targets.forEach((id) => {
            const list = document.getElementById(id);
            const sortedIds = document.getElementById(id.replace('-sortable-items', '-sorted_ids'));
            let items = '';
            const itemIds = [];
            crossbeamsUtils.getSelectedIdsInStep(sel, sortedIds.value.split(',')).forEach((opt) => {
              items += `<li id="si_${opt.value}" class="crossbeams-draggable"><span class="crossbeams-drag-handle">&nbsp;&nbsp;&nbsp;&nbsp;</span>${opt.text}</li>`;
              itemIds.push(opt.value);
            });
            list.innerHTML = items;
            sortedIds.value = itemIds.join(',');
          });
        });
      }
    });
  },

  /**
   * Replace the options of a Selectr dropdown.
   * @param {object} action - the action object returned from the backend.
   * @returns {void}
   */
  replaceSelectrOptions: function replaceSelectrOptions(action) {
    const elem = document.getElementById(action.replace_options.id);
    if (elem === null) {
      this.alert({
        prompt: `There is no DOM element with id: "${action.replace_options.id}"`,
        title: 'Dropdown-change: id missmatch',
        type: 'error',
      });
      return;
    }
    const select = elem.selectr;
    let nVal = '';
    let nText = '';
    const newItems = [];
    action.replace_options.options.forEach((item) => {
      if (item.constructor === Array) {
        nVal = (item[1] || item[0]);
        nText = String(item[0]);
      } else {
        nVal = item;
        nText = String(item);
      }
      newItems.push({
        value: nVal,
        label: nText,
      });
    });

    if (select) {
      select.removeActiveItems();
      select.setChoices(newItems, 'value', 'label', true); // seems to remove sortable...
    } else {
      while (elem.options.length) elem.remove(0);
      newItems.forEach((item) => {
        const option = document.createElement('option');
        option.value = item.value;
        option.text = item.label;
        elem.appendChild(option);
      });
    }
  },

  /**
   * Replace the options of a Multi select.
   * @param {object} action - the action object returned from the backend.
   * @returns {void}
   */
  replaceMultiOptions: function replaceMultiOptions(action) {
    const elem = document.getElementById(action.replace_multi_options.id);
    if (elem === null) {
      this.alert({
        prompt: `There is no DOM element with id: "${action.replace_multi_options.id}"`,
        title: 'Replace multi options: id missmatch',
        type: 'error',
      });
      return;
    }
    let nVal = '';
    let nText = '';
    while (elem.options.length) elem.remove(0);
    action.replace_multi_options.options.forEach((item) => {
      if (item.constructor === Array) {
        nVal = (item[1] || item[0]);
        nText = item[0];
      } else {
        nVal = item;
        nText = item;
      }
      const option = document.createElement('option');
      option.value = nVal;
      option.text = nText;
      elem.appendChild(option);
    });
    elem.dispatchEvent(new Event('change'));
  },
  /**
   * Replace the value of an Input element.
   * @param {object} action - the action object returned from the backend.
   * @returns {void}
   */
  replaceInputValue: function replaceInputValue(action) {
    const elem = document.getElementById(action.replace_input_value.id);
    if (elem === null) {
      this.alert({
        prompt: `There is no DOM element with id: "${action.replace_input_value.id}"`,
        title: 'Replace input: id missmatch',
        type: 'error',
      });
      return;
    }
    elem.value = action.replace_input_value.value;
  },
  /**
   * Change the selected option of a Select element.
   * @param {object} action - the action object returned from the backend.
   * @returns {void}
   */
  changeSelectValue: function changeSelectValue(action) {
    const elem = document.getElementById(action.change_select_value.id);
    if (elem === null) {
      this.alert({
        prompt: `There is no DOM element with id: "${action.change_select_value.id}"`,
        title: 'Change select: id missmatch',
        type: 'error',
      });
      return;
    }
    if (elem.selectr) {
      if (String(elem.value) !== String(action.change_select_value.value)) {
        elem.selectr.setChoiceByValue(String(action.change_select_value.value));
      }
    } else {
      elem.value = action.change_select_value.value;
    }
  },
  /**
   * Replace the url (href) of a DOM element.
   * @param {object} action - the action object returned from the backend.
   * @returns {void}
   */
  replaceURL: function replaceURL(action) {
    const elem = document.getElementById(action.replace_url.id);
    if (elem === null) {
      this.alert({
        prompt: `There is no DOM element with id: "${action.replace_url.id}"`,
        title: 'Replace url: id missmatch',
        type: 'error',
      });
      return;
    }
    if (!elem.hasAttribute('href')) {
      this.alert({
        prompt: `This DOM element with id: "${action.replace_url.id}" has no HREF attribute`,
        title: 'Replace url: incorrect DOM element',
        type: 'error',
      });
      return;
    }
    elem.href = action.replace_url.value;
  },
  /**
   * Replace the contents of a DOM element.
   * @param {object} action - the action object returned from the backend.
   * @returns {void}
   */
  replaceInnerHtml: function replaceInnerHtml(action) {
    const elem = document.getElementById(action.replace_inner_html.id);
    if (elem === null) {
      this.alert({
        prompt: `There is no DOM element with id: "${action.replace_inner_html.id}"`,
        title: 'Replace inner html: id missmatch',
        type: 'error',
      });
      return;
    }
    elem.innerHTML = action.replace_inner_html.value;
  },
  /**
   * Set an input element to required or not.
   * @param {object} action - the action object returned from the backend.
   * @returns {void}
   */
  setRequired: function setRequired(action) {
    const elem = document.getElementById(action.set_required.id);
    if (elem === null) {
      this.alert({
        prompt: `There is no DOM element with id: "${action.set_required.id}"`,
        title: 'Set Required element: id missmatch',
        type: 'error',
      });
      return;
    }
    if (action.set_required.required) {
      elem.required = true;
    } else {
      elem.required = false;
    }
  },
  /**
   * Set the checked attribute of an input checkbox element.
   * @param {object} action - the action object returned from the backend.
   * @returns {void}
   */
  setChecked: function setChecked(action) {
    const elem = document.getElementById(action.set_checked.id);
    if (elem === null) {
      this.alert({
        prompt: `There is no DOM element with id: "${action.set_checked.id}"`,
        title: 'Set Checked element: id missmatch',
        type: 'error',
      });
      return;
    }
    if (action.set_checked.checked) {
      elem.checked = true;
    } else {
      elem.checked = false;
    }
  },
  /**
   * Make an input element readonly or make it editable.
   * @param {object} action - the action object returned from the backend.
   * @returns {void}
   */
  setReadonlyInput: function setReadonlyInput(action) {
    const elem = document.getElementById(action.set_readonly.id);
    if (elem === null) {
      this.alert({
        prompt: `There is no DOM element with id: "${action.set_readonly.id}"`,
        title: 'Set Readonly element: id missmatch',
        type: 'error',
      });
      return;
    }
    if (action.set_readonly.readonly) {
      elem.readOnly = true;
    } else {
      elem.readOnly = false;
    }
  },
  /**
   * Hide a DOM element.
   * @param {object} action - the action object returned from the backend.
   * @returns {void}
   */
  hideElement: function hideElement(action) {
    const elem = document.getElementById(action.hide_element.id);
    if (elem === null) {
      this.alert({
        prompt: `There is no DOM element with id: "${action.hide_element.id}"`,
        title: 'Hide element: id missmatch',
        type: 'error',
      });
      return;
    }
    if (action.hide_element.reclaim_space) {
      elem.hidden = true;
    } else {
      elem.style.visibility = 'hidden';
    }
  },
  /**
   * Show a DOM element.
   * @param {object} action - the action object returned from the backend.
   * @returns {void}
   */
  showElement: function showElement(action) {
    const elem = document.getElementById(action.show_element.id);
    if (elem === null) {
      this.alert({
        prompt: `There is no DOM element with id: "${action.show_element.id}"`,
        title: 'Show element: id missmatch',
        type: 'error',
      });
      return;
    }
    if (action.show_element.reclaim_space) {
      elem.hidden = false;
    } else {
      elem.style.visibility = 'visible';
    }
  },
  /**
   * Replace the items of a List element.
   * @param {object} action - the action object returned from the backend.
   * @returns {void}
   */
  replaceListItems: function replaceListItems(action) {
    const elem = document.getElementById(action.replace_list_items.id);
    if (elem === null) {
      this.alert({
        prompt: `There is no DOM element with id: "${action.replace_list_items.id}"`,
        title: 'List items-change: id missmatch',
        type: 'error',
      });
      return;
    }
    elem.innerHTML = '';
    if (elem.dataset && elem.dataset.removeItemUrl) {
      action.replace_list_items.items.forEach((item) => {
        if (item.constructor !== Array) {
          this.alert({
            prompt: `The list of items for replacing element ${action.replace_list_items.id} must be a 2D array : [text, id]`,
            title: 'List items-change: invalid items list',
            type: 'error',
          });
          return;
        }
        const li = document.createElement('li');
        li.id = item[1];
        const id = document.createAttribute('data-item-id');
        id.value = item[1];
        li.setAttributeNode(id);
        const iconStr = `<svg class="cbl-icon red pointer" data-remove-item="${item[1]}" title="remove item" width="1792" height="1792" viewBox="0 0 1792 1792" xmlns="http://www.w3.org/2000/svg"><path d="M1600 736v192q0 40-28 68t-68 28h-1216q-40 0-68-28t-28-68v-192q0-40 28-68t68-28h1216q40 0 68 28t28 68z"></path></svg>`;
        li.append(document.createTextNode(item[0]));
        li.innerHTML = `${iconStr} ${item[0]}`;
        elem.appendChild(li);
      });
    } else {
      action.replace_list_items.items.forEach((item) => {
        const li = document.createElement('li');
        li.append(document.createTextNode(item));
        elem.appendChild(li);
      });
    }
  },
  /**
   * Clear all validation error messages and styling for a form.
   * @param {object} action - the action object returned from the backend.
   * @returns {void}
   */
  clearFormValidation: function clearFormValidation(action) {
    const form = document.getElementById(action.clear_form_validation.form_id);
    if (form === null) {
      this.alert({
        prompt: `There is no DOM form element with id: "${action.clear_form_validation.id}"`,
        title: 'Clear form validation: id missmatch',
        type: 'error',
      });
      return;
    }
    form.querySelectorAll('div.crossbeams-form-base-error').forEach((node) => {
      node.remove();
    });
    form.querySelectorAll('span.crossbeams-form-error').forEach((node) => {
      node.remove();
    });
    form.querySelectorAll('div.crossbeams-div-error').forEach((node) => {
      node.classList.remove('crossbeams-div-error', 'bg-washed-red');
    });
  },

  addGridRow: function addGridRow(action) {
    crossbeamsGridEvents.addRowToGrid(action.addRowToGrid.changes);
  },

  updateGridRow: function updateGridRow(action) {
    action.updateGridInPlace.forEach((gridRow) => {
      crossbeamsGridEvents.updateGridInPlace(gridRow.id, gridRow.changes);
    });
  },

  deleteGridRow: function deleteGridRow(action) {
    crossbeamsGridEvents.removeGridRowInPlace(action.removeGridRowInPlace.id);
  },

  /**
   * Goes through a set of actions and processes them.
   * @param {array} actions - the actions to be executed.
   * @returns {void}
   */
  processActions: function processActions(actions) {
    actions.forEach((action) => {
      if (action.replace_options) {
        crossbeamsUtils.replaceSelectrOptions(action);
      }
      if (action.replace_multi_options) {
        crossbeamsUtils.replaceMultiOptions(action);
      }
      if (action.replace_input_value) {
        crossbeamsUtils.replaceInputValue(action);
      }
      if (action.change_select_value) {
        crossbeamsUtils.changeSelectValue(action);
      }
      if (action.replace_url) {
        crossbeamsUtils.replaceURL(action);
      }
      if (action.replace_inner_html) {
        crossbeamsUtils.replaceInnerHtml(action);
      }
      if (action.replace_list_items) {
        crossbeamsUtils.replaceListItems(action);
      }
      if (action.set_readonly) {
        crossbeamsUtils.setReadonlyInput(action);
      }
      if (action.set_required) {
        crossbeamsUtils.setRequired(action);
      }
      if (action.set_checked) {
        crossbeamsUtils.setChecked(action);
      }
      if (action.hide_element) {
        crossbeamsUtils.hideElement(action);
      }
      if (action.show_element) {
        crossbeamsUtils.showElement(action);
      }
      if (action.clear_form_validation) {
        crossbeamsUtils.clearFormValidation(action);
      }
      if (action.addRowToGrid) {
        crossbeamsUtils.addGridRow(action);
      }
      if (action.updateGridInPlace) {
        crossbeamsUtils.updateGridRow(action);
      }
      if (action.removeGridRowInPlace) {
        crossbeamsUtils.deleteGridRow(action);
      }
      if (action.replace_dialog) {
        crossbeamsUtils.setDialogContent(action.replace_dialog.content);
      }
    });
  },

  /**
   * Calls all urls for observeChange behaviour and applies changes to the DOM as required..
   * @param {string} url - the url to be called.
   * @returns {void}
   */
  fetchDropdownChanges: function fetchDropdownChanges(url) {
    fetch(url, {
      method: 'GET',
      credentials: 'same-origin',
      headers: new Headers({
        'X-Custom-Request-Type': 'Fetch',
      }),
    })
    .then((response) => {
      if (response.status === 200) {
        return response.json();
      }
      throw new HttpError(response);
    })
    .then((data) => {
      if (data.actions) {
        this.processActions(data.actions);
      }
      if (data.flash) {
        if (data.flash.notice) {
          crossbeamsUtils.showSuccess(data.flash.notice);
        }
        if (data.flash.error) {
          if (data.exception) {
            crossbeamsUtils.showError(data.flash.error);
            if (data.backtrace) {
              console.groupCollapsed('EXCEPTION:', data.exception, data.flash.error); // eslint-disable-line no-console
              console.info('==Backend Backtrace=='); // eslint-disable-line no-console
              console.info(data.backtrace.join('\n')); // eslint-disable-line no-console
              console.groupEnd(); // eslint-disable-line no-console
            }
          } else {
            crossbeamsUtils.showError(data.flash.error);
          }
        }
      }
    }).catch((data) => {
      crossbeamsUtils.fetchErrorHandler(data);
    });
  },

  /**
   * observeChange behaviour - call specified urls on change of an
   * input's value - either through keyup or blur events.
   * @param {element} elem - the input element that changed.
   * @param {string} rules - the input element dataset rule.
   * @returns {void}
   */
  observeInputChange: function observeInputChange(elem, rules) {
    const j = JSON.parse(rules);
    let changedValue = elem.value;
    if (elem.type && elem.type === 'checkbox') {
      changedValue = elem.checked ? 't' : 'f';
    }
    const urls = j.map(el => this.buildObserveChangeUrl(el, changedValue));

    urls.forEach(url => this.fetchDropdownChanges(url));
  },

  /**
   * Build a query string from an object of data
   * (c) 2018 Chris Ferdinandi, MIT License, https://gomakethings.com
   * @param  {Object} data The data to turn into a query string
   * @return {String}      The query string
   */
  buildQueryString: function buildQueryString(data) {
    if (typeof (data) === 'string') return data;
    const query = [];
    Object.keys(data).forEach((key) => {
      query.push(`${encodeURIComponent(key)}=${encodeURIComponent(data[key])}`);
    });
    return query.join('&');
  },
  /**
   * Creates a url for observeChange behaviour.
   *
   * @param {element} select - Select that has changed.
   * @param {string} option - the option of the DOM select that has become selected.
   * @returns {string} the url.
   */
  buildObserveChangeUrl: function buildObserveChangeUrl(element, option) {
    let optVal;
    if (option === null || option === undefined) {
      optVal = '';
    } else {
      optVal = typeof option === 'string' || typeof option === 'number' ? option : option.value;
    }
    const queryParam = { changed_value: optVal };
    element.param_keys.forEach((key) => {
      let val = element.param_values[key];
      if (val === undefined) {
        const e = document.getElementById(key);
        val = e.value;
      }
      queryParam[key] = val;
    });
    return `${element.url}?${crossbeamsUtils.buildQueryString(queryParam)}`;
  },

  /**
   * Changes select tags into Selectr elements.
   * @returns {void}
   */
  makeSearchableSelects: function makeSearchableSelects() {
    const sels = document.querySelectorAll('.searchable-select');
    let holdSel;
    let cls = 'cbl-input';
    let isRequired;
    let clearable;
    let autoHide;
    let sortItems;
    let searchableOpt;
    sels.forEach((sel) => {
      if (sel.selectr) {
        // Choices has already been applied...
      } else {
        isRequired = sel.required;
        searchableOpt = sel.dataset.noSearch !== 'Y';
        clearable = sel.dataset.clearable === 'true';
        autoHide = sel.dataset.autoHideSearch === 'Y';
        sortItems = sel.dataset.sortItems === 'Y';
        // Do not show a search box if there are 10 or less items.
        // (This prevents unnecessary keyboard activation on mobile devices)
        if (searchableOpt && autoHide && sel.options.length < 11) {
          searchableOpt = false;
        }
        cls = 'cbl-input';
        if (isRequired) {
          sel.required = false;
          cls = 'cbl-input-required';
        }

        holdSel = new Choices(sel, {
          searchEnabled: searchableOpt,
          searchResultLimit: 100,
          removeItemButton: clearable,
          itemSelectText: '',
          classNames: {
            containerOuter: `choices ${cls}`,
            containerInner: 'choices__inner_cbl',
            highlightedState: 'is-highlighted_cbl',
          },
          shouldSort: sortItems,
          searchFields: ['label'],
          fuseOptions: {
            include: 'score',
            threshold: 0.25,
          },
        });
        if (sel.diabled) {
          holdSel.disable();
        }

        // changeValues behaviour - check if another element should be
        // enabled/disabled based on the current selected value.
        if (sel.dataset && sel.dataset.changeValues) {
          sel.addEventListener('change', (event) => {
            sel.dataset.changeValues.split(',').forEach((el) => {
              const target = document.getElementById(el);
              if (target && (target.dataset && target.dataset.enableOnValues)) {
                const vals = target.dataset.enableOnValues;
                if (vals.includes(event.detail.value)) {
                  target.disabled = false;
                } else {
                  target.disabled = true;
                }
                if (target.selectr) {
                  if (target.disabled) {
                    target.selectr.disable();
                  } else {
                    target.selectr.enable();
                  }
                }
              }
            });
          });
        }

        // observeChange behaviour - get rules from select element and
        // call the supplied url(s).
        if (sel.dataset && sel.dataset.observeChange) {
          sel.addEventListener('change', (event) => {
            const s = sel.dataset.observeChange;
            const j = JSON.parse(s);
            const urls = j.map(el => this.buildObserveChangeUrl(el, event.detail.value));

            urls.forEach(url => this.fetchDropdownChanges(url));
          });
        }

        sel.selectr = holdSel;
      }
    });
  },

  /**
   * Find select elements on the page and add change events.
   * @returns {void}
   */
  applySelectEvents: function applySelectEvents() {
    const sels = document.querySelectorAll('select:not(.searchable-multi):not(.searchable-select)');
    sels.forEach((sel) => {
      // changeValues behaviour - check if another element should be
      // enabled/disabled based on the current selected value.
      if (sel.dataset && sel.dataset.changeValues) {
        sel.addEventListener('change', (event) => {
          sel.dataset.changeValues.split(',').forEach((el) => {
            const target = document.getElementById(el);
            if (target && (target.dataset && target.dataset.enableOnValues)) {
              const vals = target.dataset.enableOnValues;
              if (vals.includes(event.target.value)) {
                target.disabled = false;
              } else {
                target.disabled = true;
              }
              if (target.selectr) {
                if (target.disabled) {
                  target.selectr.disable();
                } else {
                  target.selectr.enable();
                }
              }
            }
          });
        });
      }

      // observeChange behaviour - get rules from select element and
      // call the supplied url(s).
      if (sel.dataset && sel.dataset.observeChange) {
        sel.addEventListener('change', (event) => {
          const s = sel.dataset.observeChange;
          const j = JSON.parse(s);
          const urls = j.map(el => this.buildObserveChangeUrl(el, event.target.value));

          urls.forEach(url => this.fetchDropdownChanges(url));
        });
      }
    });
  },

  /**
   * Toggle the visibility of en element in the DOM:
   * @param {string} id - the id of the DOM element.
   * @returns {void}
   */
  toggleVisibility: function toggleVisibility(id) {
    const e = document.getElementById(id);
    e.hidden = !e.hidden;
  },

  /**
   * Open or close all FoldUps (<details> tags) in a form.
   * @param {element} elem - the DOM element.
   * @param {boolean} open - open or close the foldups.
   * @returns {boolean}
   */
  openOrCloseFolds: function openOrCloseFolds(elem, open) {
    const form = elem.closest('form');
    if (form === undefined) {
      return null;
    }
    const folds = form.querySelectorAll('details');
    folds.forEach((f) => { f.open = open; });
    return open;
  },

  /**
   * alert() Shows a SweetAlert2 info alert dialog.
   * @param {string} prompt - the prompt text.
   * @param {string} [title] - optional title for the dialog.
   * @returns {void}
   */
  alert: function alert({ prompt, title, html, type = 'info' }) {
    swal({
      title: title === undefined ? '' : title,
      text: prompt,
      html,
      type,
    }).catch(swal.noop);
  },

  /**
   * confirm() Shows a SweetAlert2 warning dialog asking the user to confirm or cancel.
   * @param {string} prompt - the prompt text.
   * @param {string} [title] - optional title for the dialog.
   * @param {function} okFunc - the function to call when the user presses OK.
   * @param {function} [cancelFunc] - optional function to call if the user presses cancel.
   * @returns {void}
   */
  confirm: function confirm({ prompt, title, okFunc, cancelFunc }) {
    // console.log(title);
    swal({
      title: title === undefined ? '' : title,
      text: prompt,
      type: 'warning',
      showCancelButton: true }).then(okFunc, cancelFunc).catch(swal.noop);
  },

  /**
   * Take a value and return it formatted with thousands separators
   * and a set number of decimals.
   * @param {string, number} value - the value to format.
   * @param {integet} precision - the number of decimals to show.
   * @returns {string, null} - the formatted value or null if the value cannot be formatted.
   */
  formatNumberWithCommas: function formatNumberWithCommas(value, precision) {
    if (!value) { return null; }

    let x = value;
    if (typeof x === 'string') { x = parseFloat(x); }
    if (isNaN(x)) { return null; }
    return x.toLocaleString('en-US', { minimumFractionDigits: precision });
  },

  /**
   * Return the character code of an event.
   * @param {event} evt - the event.
   * @returns {string} - the keyCode.
   */
  getCharCodeFromEvent: function getCharCodeFromEvent(evt) {
    const event = evt || window.event;
    return (event.which === 'undefined')
      ? event.keyCode
      : event.which;
  },

  /**
   * Is a character numeric?
   * @param {string} charStr - the character string.
   * @returns {boolean} - true if the string is numeric, false otherwise.
   */
  isCharNumeric: function isCharNumeric(charStr) {
    return !!(/\d/.test(charStr));
  },

  /**
   * Check if the user pressed a numeric key.
   * @param {event} event - the event.
   * @returns {boolean} - true if the key represents a number.
   */
  isKeyPressedNumeric: function isKeyPressedNumeric(event) {
    const charCode = this.getCharCodeFromEvent(event);
    const charStr = String.fromCharCode(charCode);
    return this.isCharNumeric(charStr);
  },

  /**
   * Make a select tag using an array for the options.
   * The Array can be an Array of Arrays too.
   * For a 1-dimensional array the option text and value are the same.
   * For a 2-dimensional array the option text is the 1st element and the value is the second.
   * @param {string} name - the name of the select tag.
   * @param {array} arr - the array of option values.
   * @param {string} [attrs] - optional - a string to include class/style etc in the tag.
   * @returns {string} - the select tag code.
   */
  makeSelect: function makeSelect(name, arr, attrs) {
    let sel = `<select id="${name}" name="${name}" ${attrs || ''}>`;
    arr.forEach((item) => {
      if (item.constructor === Array) {
        sel += `<option value="${(item[1] || item[0])}">${item[0]}</option>`;
      } else {
        sel += `<option value="${item}">${item}</option>`;
      }
    });
    sel += '</select>';
    return sel;
  },

  /**
   * Adds a parameter named "json_var" to a form
   * containing a stringified version of the passed object.
   * @param {string} formId - the id of the form to be modified.
   * @param {object} jsonVar - the object to be added to the form as a string.
   * @returns {void}
   */
  addJSONVarToForm: function addJSONVarToForm(formId, jsonVar) {
    const form = document.getElementById(formId);
    const element1 = document.createElement('input');
    element1.type = 'hidden';
    element1.value = JSON.stringify(jsonVar);
    element1.name = 'json_var';
    form.appendChild(element1);
  },

  /**
   * Return the index of an LI node in a UL/OL list.
   * @param {element} node - the li node.
   * @returns {integer} - the index of the selected node.
   */
  getListIndex: function getListIndex(node) {
    const childs = node.parentNode.children; // childNodes;
    let i = 0;
    let index;
    Array.from(childs).forEach((child) => {
      i += 1;
      if (node === child) {
        index = i;
      }
    });
    return index;
  },

  /**
   * Make a list sortable.
   * @param {string} prefix - the prefix part of the id of the ol or ul tag.
   * @returns {void}
   */
  makeListSortable: function makeListSortable(prefix, groupName) {
    const el = document.getElementById(`${prefix}-sortable-items`);
    const sortedIds = document.getElementById(`${prefix}-sorted_ids`);
    Sortable.create(el, {
      group: groupName || null,
      animation: 150,
      handle: '.crossbeams-drag-handle',
      ghostClass: 'crossbeams-sortable-ghost',  // Class name for the drop placeholder
      dragClass: 'crossbeams-sortable-drag',  // Class name for the dragging item
      onSort: () => {
        const idList = [];
        Array.from(el.children).forEach((child) => { idList.push(child.id.replace('si_', '')); });// strip si_ part...
        sortedIds.value = idList.join(',');
      },
    });
  },

  /**
   * Change a busy step of a progress step control to a visited, current step.
   * @param {string} id - the id of the li component representing the step.
   * @returns {void}
   */
  finaliseProgressStep: function finaliseProgressStep(id) {
    const el = document.getElementById(id);
    el.classList.remove('busy');
    el.classList.add('visited');
    el.classList.add('current');
  },

  /**
   * Handle errors thrown in `fetch` responses.
   * @param {object} data - the data returned by the fetch call.
   * @returns {void}
   */
  fetchErrorHandler: function fetchErrorHandler(data) {
    console.log(data); // eslint-disable-line no-console
    if (data.response && data.response.status === 500) {
      data.response.json().then((body) => {
        if (body.flash.error) {
          if (body.exception) {
            if (body.backtrace) {
              console.groupCollapsed('EXCEPTION:', body.exception, body.flash.error); // eslint-disable-line no-console
              console.info('==Backend Backtrace=='); // eslint-disable-line no-console
              console.info(body.backtrace.join('\n')); // eslint-disable-line no-console
              console.groupEnd(); // eslint-disable-line no-console
            }
          } else {
            crossbeamsUtils.showError(body.flash.error);
          }
        } else {
          // FIXME: Is this always applicable for all errors?
          document.getElementById(crossbeamsUtils.activeDialogContent()).innerHTML = body;
        }
      });
    }
    crossbeamsUtils.showError(`An error occurred ${data}`);
  },

  /**
   * Keep polling a url.
   * @param {DOM} element - the element to be updated.
   * @param {string} url - the url to be fetched.
   * @param {integer} interval - the amount of time in milliseconds between repeats of the fetch.
   * @returns {void}
   */
  pollMessage: function pollMessage(element, url, interval) {
    fetch(url, {
      method: 'GET',
      credentials: 'same-origin',
      headers: new Headers({
        'X-Custom-Request-Type': 'Fetch',
      }),
    })
    .then((response) => {
      if (response.status === 200) {
        return response.json();
      }
      throw new HttpError(response);
    })
      .then((data) => {
        if (data.redirect) {
          window.location = data.redirect;
        } else if (data.updateMessage) {
          if (data.updateMessage.finaliseProgressStep) {
            crossbeamsUtils.finaliseProgressStep(data.updateMessage.finaliseProgressStep);
          }
          if (data.updateMessage.content) {
            element.innerHTML = data.updateMessage.content;
          }
          if (data.updateMessage.continuePolling) {
            setTimeout(pollMessage, interval, element, url, interval);
          }
        } else {
          console.log('Not sure what to do with this:', data); // eslint-disable-line no-console
        }
        if (data.flash) {
          if (data.flash.notice) {
            crossbeamsUtils.showSuccess(data.flash.notice);
          }
          if (data.flash.error) {
            if (data.exception) {
              crossbeamsUtils.showError(data.flash.error);
              if (data.backtrace) {
                console.groupCollapsed('EXCEPTION:', data.exception, data.flash.error); // eslint-disable-line no-console
                console.info('==Backend Backtrace=='); // eslint-disable-line no-console
                console.info(data.backtrace.join('\n')); // eslint-disable-line no-console
                console.groupEnd(); // eslint-disable-line no-console
              }
            } else {
              crossbeamsUtils.showError(data.flash.error);
            }
          }
        }
      }).catch((data) => {
        crossbeamsUtils.fetchErrorHandler(data);
      });
  },

  /**
   * Load the contents of a callback section from the results of a fetch.
   * @param {string} section - A query string to use in finding callback sections.
   * @param {string} url - the url to be fetched.
   * @returns {void}
   */
  loadCallBackSection: function loadCallBackSection(section, url) {
    const contentDiv = document.querySelector(section);

    fetch(url, {
      method: 'GET',
      credentials: 'same-origin',
      headers: new Headers({
        'X-Custom-Request-Type': 'Fetch',
      }),
    })
    .then((response) => {
      if (response.status === 200) {
        return response.json();
      }
      throw new HttpError(response);
    })
    .then((data) => {
      if (data.redirect) {
        window.location = data.redirect;
      } else if (data.content) {
        contentDiv.classList.remove('content-loading');
        contentDiv.innerHTML = data.content;

        // check if there are any areas in the content that should be modified by polling...
        const pollsters = contentDiv.querySelectorAll('[data-poll-message-url]');
        pollsters.forEach((pollable) => {
          const pollUrl = pollable.dataset.pollMessageUrl;
          const pollInterval = pollable.dataset.pollMessageInterval;
          this.pollMessage(pollable, pollUrl, pollInterval);
        });

        crossbeamsUtils.makeMultiSelects();
        crossbeamsUtils.makeSearchableSelects();
        crossbeamsUtils.applySelectEvents();
        const grids = contentDiv.querySelectorAll('[data-grid]');
        grids.forEach((grid) => {
          const gridId = grid.getAttribute('id');
          const gridEvent = new CustomEvent('gridLoad', { detail: gridId });
          document.dispatchEvent(gridEvent);
        });
        const sortable = Array.from(contentDiv.getElementsByTagName('input')).filter(a => a.dataset && a.dataset.sortablePrefix);
        sortable.forEach((elem) => {
          crossbeamsUtils.makeListSortable(elem.dataset.sortablePrefix, elem.dataset.sortableGroup);
        });
      }
      if (data.flash) {
        if (data.flash.notice) {
          crossbeamsUtils.showSuccess(data.flash.notice);
        }
        if (data.flash.error) {
          if (data.exception) {
            crossbeamsUtils.showError(data.flash.error);
            if (data.backtrace) {
              console.groupCollapsed('EXCEPTION:', data.exception, data.flash.error); // eslint-disable-line no-console
              console.info('==Backend Backtrace=='); // eslint-disable-line no-console
              console.info(data.backtrace.join('\n')); // eslint-disable-line no-console
              console.groupEnd(); // eslint-disable-line no-console
            }
          } else {
            crossbeamsUtils.showError(data.flash.error);
          }
        }
      }
    }).catch((data) => {
      crossbeamsUtils.fetchErrorHandler(data);
    });
  },

};
