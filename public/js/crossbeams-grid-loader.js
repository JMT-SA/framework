// Object to keep track of the grids in a page - so they can be looked up by div id.
/**
 * In-browser store of grids on the page.
 * @namespace
 */
const crossbeamsGridStore = {
  gridStore: {},

  /**
   * Add a grid to the store.
   * @param {string} gridId - the id of the grid div element.
   * @param {object} gridOptions - reference to the grid options object.
   * @returns {void}
   */
  addGrid: function addGrid(gridId, gridOptions) {
    this.gridStore[gridId] = gridOptions;
  },

  /**
   * Retrieve a grid from the store.
   * @param {string} gridId - the id of the grid div element.
   * @returns {agGrid} - reference to the grid.
   */
  getGrid: function getGrid(gridId) {
    return this.gridStore[gridId];
  },

  /**
   * Remove a grid from the store.
   * @param {string} gridId - the id of the grid div element.
   * @returns {void}
   */
  removeGrid: function removeGrid(gridId) {
    this.gridStore[gridId].api.destroy();
    delete this.gridStore[gridId];
  },

  /**
   * List of grid ids in the store.
   * @returns {string} - a list of the grid ids.
   */
  listGridIds: function listGridIds() {
    const lst = [];
    Object.keys(this.gridStore).forEach((gridId) => {
      lst.push(gridId);
    });
    return lst.join(', ');
  },
};

const crossbeamsGridFormatters = {
  testRender: function testRender(params) {
    return `<b>${params.value.toUpperCase()}</b>`;
  },

  nextChar: function nextChar(c) {
    return String.fromCharCode(c.charCodeAt(0) + 1);
  },

  // Is the last item in an array of context menu items a separator?
  lastIsSeparator: (items) => {
    if (!items || items.length < 1) {
      return false;
    }
    if (!items[items.length - 1].value) {
      return false;
    }
    return items[items.length - 1].value === '---';
  },

  // Go through a list of context items and remove any trailing separators.
  removeTrailingSeparatorItems: (items) => {
    let cleanItems = items;
    while (crossbeamsGridFormatters.lastIsSeparator(cleanItems)) {
      cleanItems = cleanItems.slice(0, -1);
    }
    return cleanItems;
  },

  makeContextNode: function makeContextNode(key, prefix, items, item, params) {
    let node = {};
    let urlComponents = [];
    let url;
    let subKey = 'a';
    let subPrefix = '';
    let subnode;
    let titleValue;
    let promptValue;
    const checkBooleans = (checks, boolVal, data) => {
      let ok = false;
      checks.split(',').forEach((field) => {
        if (data[field] === boolVal) {
          ok = true;
        }
      });
      return ok;
    };
    const checkNulls = (checks, nullPresent, data) => {
      let ok = false;
      checks.split(',').forEach((field) => {
        if (nullPresent && data[field] === null) {
          ok = true;
        }
        if (!nullPresent && data[field] !== null) {
          ok = true;
        }
      });
      return ok;
    };
    if (item.title_field) {
      titleValue = params.data[item.title_field];
    } else {
      titleValue = item.title ? item.title : '';
      if (titleValue.indexOf('$:') > -1) {
        titleValue = titleValue.replace(/\$:(.*?)\$/g, match => params.data[match.replace('$:', '').replace('$', '')]);
      }
    }
    promptValue = item.prompt;
    if (promptValue && promptValue.indexOf('$:') > -1) {
      promptValue = promptValue.replace(/\$:(.*?)\$/g, match => params.data[match.replace('$:', '').replace('$', '')]);
    }
    if (item.is_separator) {
      // Add a separator - but only if the previous item is not also a separator.
      if (items.length > 0 && items[items.length - 1].value !== '---') {
        return { key: `${prefix}${key}`, name: item.text, value: '---' };
      }
      return null;
    }
    if (item.hide_if_null && checkNulls(item.hide_if_null, true, params.data)) {
      // No show of item
      return null;
    }
    if (item.hide_if_present && checkNulls(item.hide_if_present, false, params.data)) {
      // No show of item
      return null;
    }
    if (item.hide_if_true && checkBooleans(item.hide_if_true, true, params.data)) {
      // No show of item
      return null;
    }
    if (item.hide_if_false && checkBooleans(item.hide_if_false, false, params.data)) {
      // No show of item
      return null;
    }
    if (item.is_submenu) {
      node = {
        key: `${prefix}${key}`, name: item.text, items: [], is_submenu: true, row_id: null,
      };
      item.items.forEach((subitem) => {
        subKey = crossbeamsGridFormatters.nextChar(subKey);
        subPrefix = `${prefix}${key}_`;
        subnode = crossbeamsGridFormatters.makeContextNode(subKey, subPrefix, node.items, subitem, params);
        if (subnode !== null) {
          node.items.push(subnode);
        }
      });
      node.items = crossbeamsGridFormatters.removeTrailingSeparatorItems(node.items);
      if (node.items.length > 0) {
        return node;
      }
      return null;
    }
    urlComponents = item.url.split('$');
    url = '';
    urlComponents.forEach((cmp, index) => {
      if (index % 2 === 0) {
        url += cmp;
      } else {
        url += params.data[item[cmp]];
      }
    });
    return {
      key: `${prefix}${key}`,
      name: item.text,
      url,
      prompt: promptValue,
      method: item.method,
      title: item.title,
      title_field: titleValue,
      icon: item.icon,
      popup: item.popup,
      loading_window: item.loading_window,
      row_id: params.data.id,
    };
  },

  menuActionsRenderer: function menuActionsRenderer(params) {
    if (!params.data) { return null; }
    let valueObj = params.value;
    if (valueObj === undefined || valueObj === null) {
      valueObj = params.valueGetter();
    }
    if (valueObj.length === 0) { return ''; }

    let items = [];
    let node;
    const prefix = '';
    let key = 'a';
    valueObj.forEach((item) => {
      key = crossbeamsGridFormatters.nextChar(key);
      node = crossbeamsGridFormatters.makeContextNode(key, prefix, items, item, params);
      if (node !== null) {
        items.push(node);
      }
    });
    // If items are hidden, the last item(s) could be separators.
    // Remove them here.
    items = crossbeamsGridFormatters.removeTrailingSeparatorItems(items);
    if (items.length === 0) {
      return '';
    }
    // svg: chevron-right
    return `<button class='grid-context-menu' data-dom-grid-id='${params.context.domGridId}' data-row='${JSON.stringify(items)}'><svg class="cbl-icon blue" width="1792" height="1792" viewBox="0 0 1792 1792" xmlns="http://www.w3.org/2000/svg"><path d="M1363 877l-742 742q-19 19-45 19t-45-19l-166-166q-19-19-19-45t19-45l531-531-531-531q-19-19-19-45t19-45l166-166q19-19 45-19t45 19l742 742q19 19 19 45t-19 45z"/></svg></button>`; // eslint-disable-line max-len
  },

  // Return a number with thousand separator and at least 2 digits after the decimal.
  numberWithCommas2: function numberWithCommas2(params) {
    if (!params.data) { return null; }

    return crossbeamsUtils.formatNumberWithCommas(params.value, 2);
  },

  // Return a number with thousand separator and at least 4 digits after the decimal.
  numberWithCommas4: function numberWithCommas4(params) {
    if (!params.data) { return null; }

    return crossbeamsUtils.formatNumberWithCommas(params.value, 4);
  },

  booleanFormatter: function booleanFormatter(params) {
    if (!params.data) { return null; }

    if (params.value === '' || params.value === null) { return ''; }
    if (params.value === true || params.value === 't' || params.value === 'true' || params.value === 'y' || params.value === 1) {
      return '<span class="ac_icon_check">&nbsp;</span>';
    }
    return '<span class="ac_icon_uncheck">&nbsp;</span>';
  },

  // Remove the time zone portion of a datetime column.
  dateTimeWithoutZoneFormatter: function dateTimeWithoutZoneFormatter(params) {
    if (!params.data) { return null; }
    if (!params.value) { return null; }

    if (params.value === '' || params.value === null) { return ''; }
    return params.value.replace(/ \+\d\d\d\d$/, '');
  },

  // Remove the seconds and time zone portion of a datetime column.
  dateTimeWithoutSecsOrZoneFormatter: function dateTimeWithoutSecsOrZoneFormatter(params) {
    if (!params.data) { return null; }

    if (params.value === '' || params.value === null) { return ''; }
    return params.value.replace(/:\d\d \+\d\d\d\d$/, '');
  },

  // Format a column to display as an icon.
  // The column format is: "icon_name[,colour][,indent level]"
  // - colour defaults to grey
  // - indent level defaults to 0
  iconFormatter: function iconFormatter(params) {
    if (!params.data) { return null; }
    if (params.value === '' || params.value === null) { return ''; }

    const icoCol = params.value.split(',');
    if (!icoCol[1]) icoCol.push('gray'); // default colour
    if (!icoCol[2]) { //                 // default indent from "level" column
      if (params.data.level) {
        icoCol.push(params.data.level - 1);
      } else {
        icoCol.push(0);
      }
    }
    return `<span class="cbl-icon" style="color:${icoCol[1]};margin-left:${icoCol[2] * 0.75}rem">
        <img src="/app_icons/${icoCol[0]}.svg" onload="SVGInject(this)">
      </span>`;
  },

  hrefInlineFormatter: function hrefInlineFormatter(params) {
    return `<a href="/books/${params.value}/edit">edit</a>`;
  },

  // The Tachyon classes required to style a link as a button.
  buttonClassForLinks: function buttonClassForLinks(bgColour) {
    return `link dim br1 ph2 dib white bg-${bgColour || 'green'}`;
  },

  hrefSimpleFormatter: function hrefSimpleFormatter(params) {
    const vals = params.value.split('|');
    return `<a class="${crossbeamsGridFormatters.buttonClassForLinks()}" href="${vals[0]}">${vals[1]}</a>`;
  },

  hrefSimpleFetchFormatter: function hrefSimpleFetchFormatter(params) {
    const vals = params.value.split('|');
    return `<a class="${crossbeamsGridFormatters.buttonClassForLinks()}" data-remote-link="true" href="${vals[0]}">${vals[1]}</a>`;
  },

  // Creates a link that when clicked prompts for a yes/no answer.
  // Column value is in the format "url|linkText|prompt|method".
  // Only url and linkText are required.
  hrefPromptFormatter: function hrefPromptFormatter(params) {
    let url = '';
    let linkText = '';
    let prompt;
    let method;
    [url, linkText, prompt, method] = params.value.split('|');
    prompt = prompt || 'Are you sure?';
    method = (method || 'post').toLowerCase();
    return `<a class="${crossbeamsGridFormatters.buttonClassForLinks()}" href='#' data-prompt="${prompt}" data-method="${method}" data-url="${url}"
    onclick="crossbeamsGridEvents.promptClick(this);">${linkText}</a>`;
  },
};

/**
 * Handle various events related to interactions with the grid.
 * @namespace
 */
const crossbeamsGridEvents = {
  /**
   * Expand a grid to full screen.
   * @param {string} gridId - the DOM id of the grid.
   * @returns {void}
   */
  toFullScreen: function toFullScreen(gridId) {
    const grid = document.getElementById(gridId);
    (grid.requestFullscreen
     || grid.webkitRequestFullscreen
     || grid.mozRequestFullScreen
     || grid.msRequestFullscreen || (() => {})).call(grid);
  },

  /**
   * Change the values of certain columns of a row of a grid.
   * @param {integer} id - the id of the grid's row.
   * @param {object} changes - the changes to be applied to the grid's row.
   * @returns {void}
   */
  updateGridInPlace: function updateGridInPlace(id, changes) {
    const thisGridId = crossbeamsUtils.baseGridIdForPopup();
    const gridOptions = crossbeamsGridStore.getGrid(thisGridId);
    if (gridOptions === undefined) {
      crossbeamsUtils.showWarning('Unable to update the grid - please reload the page to see changes.');
      return;
    }
    const rowNode = gridOptions.api.getRowNode(id);
    if (rowNode === undefined) {
      crossbeamsUtils.showError(`Could not find a grid with id "${id}".`);
      console.log('No grid with id:', id); // eslint-disable-line no-console
      return;
    }

    Object.keys(changes).forEach((k) => {
      if (rowNode.data[k] === undefined) {
        crossbeamsUtils.showWarning(`Unable to update the grid properly - "${k}" is not one of the grid's columns.`);
      } else {
        rowNode.setDataValue(k, changes[k]);
      }
    });
  },

  /**
   * Add a row to the end of a grid.
   * @param {object} row - the row to be aded to the grid.
   * @returns {void}
   */
  addRowToGrid: function addRowToGrid(row) {
    const thisGridId = crossbeamsUtils.baseGridIdForPopup();
    const gridOptions = crossbeamsGridStore.getGrid(thisGridId);
    if (gridOptions) {
      const missing = Object.keys(row).filter(a => gridOptions.columnApi.getColumn(a) === null && a !== 'created_at' && a !== 'updated_at');
      if (missing.length > 0) {
        crossbeamsUtils.showWarning(`Unable to add row to the grid - columns not defined in the grid: ${missing.join(', ')}.`);
      } else {
        missing.forEach((col) => {
          delete row[col];
        });
        const nodes = gridOptions.api.applyTransaction({ add: [row] });
        gridOptions.api.ensureNodeVisible(nodes.add[0]);
      }
    } else {
      crossbeamsUtils.showWarning('Unable to update the grid - please reload the page to see changes.');
    }
  },

  /**
   * Remove a row from a grid.
   * @param {integer} id - the id of the grid's row.
   * @returns {void}
   */
  removeGridRowInPlace: function removeGridRowInPlace(id) {
    const thisGridId = crossbeamsUtils.currentGridIdForPopup();
    const gridOptions = crossbeamsGridStore.getGrid(thisGridId);
    const rowNode = gridOptions.api.getRowNode(id);
    gridOptions.api.applyTransaction({ remove: [rowNode] });
  },

  /**
   * Save row ids from a multiselect grid.
   * @param {string} gridId - the DOM id of the grid.
   * @param {string} url - the URL to receive the fetch request.
   * @returns {void}
   */
  saveSelectedRows: function saveSelectedRows(gridId, url, canBeCleared, saveMethod) {
    const gridOptions = crossbeamsGridStore.getGrid(gridId);
    const ids = gridOptions.api.getSelectedRows().map(m => m.id);
    let msg;
    if (!canBeCleared && ids.length === 0) {
      crossbeamsUtils.alert({ prompt: 'You have not selected any items to submit!', type: 'error' });
    } else {
      if (ids.length === 0) {
        msg = 'Are you sure you want to submit an empty selection?';
      } else {
        msg = `Are you sure you want to submit this selection?(${ids.length.toString()} items)`;
      }

      // Save via a standard HTTP call.
      const saveStd = () => {
        const form = document.createElement('form');
        const element1 = document.createElement('input');
        const csrf = document.createElement('input');
        form.style.position = 'absolute';
        form.style.left = '-1000px';
        form.method = 'POST';
        form.action = url;
        element1.value = ids.join(',');
        element1.name = 'selection[list]';
        csrf.value = document.querySelector('meta[name="_csrf"]').content;
        csrf.name = '_csrf';
        form.appendChild(element1);
        form.appendChild(csrf);
        document.body.appendChild(form);
        form.submit();
      };

      const saveLoading = () => {
        crossbeamsUtils.loadingWindow(`${url}?selection[list]=${ids.join(',')}`);
      };

      // Save via a remote fetch call that renders in a dialog.
      const saveToPopup = () => {
        crossbeamsUtils.recordGridIdForPopup(gridId);
        crossbeamsUtils.popupDialog('', `${url}?selection[list]=${ids.join(',')}`);
      };

      // Save via a remote fetch call.
      const saveRemote = () => {
        const form = new FormData();
        form.append('selection[list]', ids.join(','));
        form.append('_csrf', document.querySelector('meta[name="_csrf"]').content);
        fetch(url, {
          method: 'POST',
          credentials: 'same-origin',
          headers: new Headers({
            'X-Custom-Request-Type': 'Fetch',
          }),
          body: form,
        }).then((response) => {
          if (response.status === 404) {
            crossbeamsUtils.showError('The requested resource was not found');
            return {};
          }
          return response.json();
        }).then((data) => {
          let closeDialog = true;
          if (data.redirect) {
            window.location = data.redirect;
          } else if (data.updateGridInPlace) {
            data.updateGridInPlace.forEach((gridRow) => {
              this.updateGridInPlace(gridRow.id, gridRow.changes);
            });
          } else if (data.addRowToGrid) {
            this.addRowToGrid(data.addRowToGrid.changes, data.addRowToGrid.atStart);
          } else if (data.actions) {
            if (data.keep_dialog_open) {
              closeDialog = false;
            }
            crossbeamsUtils.processActions(data.actions);
          } else if (data.replaceDialog) {
            closeDialog = false;
            const dlgContent = document.getElementById(crossbeamsUtils.activeDialogContent());
            dlgContent.innerHTML = data.replaceDialog.content;
            crossbeamsUtils.makeMultiSelects();
            crossbeamsUtils.makeSearchableSelects();
            const grids = dlgContent.querySelectorAll('[data-grid]');
            grids.forEach((grid) => {
              const newGridId = grid.getAttribute('id');
              const gridEvent = new CustomEvent('gridLoad', { detail: newGridId });
              document.dispatchEvent(gridEvent);
            });
            const sortable = Array.from(dlgContent.getElementsByTagName('input')).filter(a => a.dataset && a.dataset.sortablePrefix);
            sortable.forEach(elem => crossbeamsUtils.makeListSortable(elem.dataset.sortablePrefix,
              elem.dataset.sortableGroup));
          } else {
            console.log('Not sure what to do with this:', data); // eslint-disable-line no-console
          }
          if (closeDialog) {
            crossbeamsUtils.closePopupDialog();
          }
          // Only if not redirect...
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
      };

      let saveFunc;
      if (saveMethod === 'http') {
        saveFunc = saveStd;
      } else if (saveMethod === 'remote') {
        saveFunc = saveRemote;
      } else if (saveMethod === 'dialog') {
        saveFunc = saveToPopup;
      } else if (saveMethod === 'loading') {
        saveFunc = saveLoading;
      }

      crossbeamsUtils.confirm({
        prompt: msg,
        okFunc: saveFunc,
      });
    }
  },

  /**
   * Display the number of rows in the grid. Adjust on filter.
   * @param {string} gridId - the DOM id of the grid.
   * @param {integer} filterLength - the number of filtered rows.
   * @param {integer} rows - the total number of rows.
   * @returns {void}
   */
  displayRowCounts: function displayRowCounts(gridId, filterLength, rows) {
    const display = document.getElementById(`${gridId}_rowcount`);
    if (filterLength === rows) {
      display.textContent = `(${rows} row${rows > 1 ? 's' : ''})`;
    } else {
      display.textContent = `(${filterLength} of ${rows} row${rows > 1 ? 's' : ''})`;
    }
  },

  cellValueChanged: function cellValueChanged(gridId, event) {
    const url = event.context.fieldUpdateUrl.replace(/\$:id\$/, event.data.id);
    const errChanges = {};
    const form = new FormData();

    errChanges[event.colDef.field] = event.oldValue;
    crossbeamsUtils.recordGridIdForPopup(gridId);

    if (event.context.keyColumn) {
      form.append('key_name', event.context.keyColumn);
      form.append('key_val', event.data[event.context.keyColumn]);
    }
    form.append('column_name', event.colDef.field);
    form.append('column_value', event.newValue);
    form.append('old_value', event.oldValue);
    form.append('_csrf', document.querySelector('meta[name="_csrf"]').content);
    fetch(url, {
      method: 'POST',
      credentials: 'same-origin',
      headers: new Headers({
        'X-Custom-Request-Type': 'Fetch',
      }),
      body: form,
    }).then((response) => {
      if (response.status === 404) {
        crossbeamsGridEvents.updateGridInPlace(event.data.id, errChanges);
        crossbeamsUtils.showError('The requested resource was not found');
        return {};
      }
      return response.json();
    })
      .then((data) => {
        if (data.redirect) {
          window.location = data.redirect;
        } else if (data.undoEdit) {
          crossbeamsGridEvents.updateGridInPlace(event.data.id, errChanges);
        } else if (data.actions) {
          crossbeamsUtils.processActions(data.actions);
        } else {
          console.log('Not sure what to do with this:', data); // eslint-disable-line no-console
        }
        // Only if not redirect...
        if (data.flash) {
          if (data.flash.notice) {
            crossbeamsUtils.showSuccess(data.flash.notice);
          }
          if (data.flash.info) {
            crossbeamsUtils.showInformation(data.flash.info);
          }
          if (data.flash.warning) {
            crossbeamsUtils.showWarning(data.flash.warning);
          }
          if (data.flash.error) {
            crossbeamsGridEvents.updateGridInPlace(event.data.id, errChanges);
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
        // revert value
        crossbeamsGridEvents.updateGridInPlace(event.data.id, errChanges);
        crossbeamsUtils.fetchErrorHandler(data);
      });
  },

  /**
   * Add line item tags to an unordered list element - one for each column name in the grid.
   * @param {string} gridId - the DOM id of the grid.
   * @param {array} colDefs - the column definitions for the grid.
   * @param {bool} showJump - should the list be shown. (Hide if there is no horizontal scroll bar)
   * @returns {void}
   */
  makeColumnScrollList: function makeColumnScrollList(gridId, colDefs, showJump) {
    const frame = document.getElementById(`${gridId}-frame`);
    if (showJump) {
      frame.querySelector('.crossbeams-column-jump').hidden = false;
    } else {
      frame.querySelector('.crossbeams-column-jump').hidden = true;
      return;
    }

    const ul = document.getElementById(`${gridId}-scrollcol`);
    let li;
    colDefs.sort((a, b) => a.headerName.localeCompare(b.headerName)).forEach((col) => {
      if (col.field !== undefined && !col.hide) {
        li = document.createElement('li');
        li.dataset.colName = col.field;
        li.innerHTML = col.headerName;
        ul.appendChild(li);
      }
    });

    ul.addEventListener('click', (event) => {
      const gridOptions = crossbeamsGridStore.getGrid(event.target.parentNode.dataset.gridId);
      let rIdx;
      const rowNode = gridOptions.api.getSelectedNodes()[0];
      if (rowNode === undefined) {
        rIdx = gridOptions.api.getFirstDisplayedRow();
      } else {
        rIdx = rowNode.rowIndex;
      }
      gridOptions.api.ensureColumnVisible(event.target.dataset.colName);
      gridOptions.api.setFocusedCell(rIdx, event.target.dataset.colName); // ??? no effect
    });
  },

  /**
   * If this grid has a bookmark, make the bookmark button available to jump to the row.
   * @param {string} gridId - the DOM id of the grid.
   * @returns {void}
   */
  makeRowBookmark: function makeRowBookmark(gridId, updateId = false) {
    const frame = document.getElementById(`${gridId}-frame`);
    const btn = frame.querySelector('.crossbeams-row-bookmark');

    if (btn === null) {
      return;
    }
    const rowId = crossbeamsUtils.currentGridRowBookmark();
    if (rowId === null) {
      btn.hidden = true;
      return;
    }
    btn.hidden = false;
    btn.dataset.bookmarkRowId = rowId;

    const bkmkClick = function bkmkClick() {
      const gridOptions = crossbeamsGridStore.getGrid(gridId);
      const node = gridOptions.api.getRowNode(btn.dataset.bookmarkRowId);
      if (node === undefined) {
        btn.hidden = true;
      } else {
        gridOptions.api.ensureNodeVisible(node, 'middle');
        node.setSelected(true);
        // If this is a tree, the bookmarked row might be collapsed.
        let currNode = node;
        while (currNode.parent) {
          if (!currNode.parent.expanded) {
            currNode.parent.setExpanded(true);
          }
          currNode = currNode.parent;
        }
      }
    };

    if (updateId) {
      btn.removeEventListener('click', bkmkClick);
    }

    btn.addEventListener('click', bkmkClick);
  },

  /**
   * Export a grid to a csv file.
   * @param {string} gridId - the DOM id of the grid.
   * @param {string} fileName - the name to be given to the exported file.
   * @returns {void}
   */
  csvExport: function csvExport(gridId, fileName) {
    const colKeys = [];
    let params = {};

    // Get visible columns that do not explicitly have 'suppressCsvExport' set.
    const gridOptions = crossbeamsGridStore.getGrid(gridId);
    const visibleCols = gridOptions.columnApi.getAllDisplayedColumns();

    visibleCols.forEach((col) => {
      if (!col.colDef.suppressCsvExport || col.colDef.suppressCsvExport === false) {
        colKeys.push(col.colId);
      }
    });

    params = {
      fileName,
      columnKeys: colKeys, // Visible, non-suppressed columns.
    };

    // Ensure long numbers are exported as strings.
    params.processCellCallback = (parms) => {
      let testStr = '';
      // If HTML entities are a problem...
      // parms.value.replace(/&amp;/g, "&")
      // .replace(/\\&quot;/g, "\"")
      // .replace(/&quot;/g, "\"")
      // .replace(/&gt;/g, ">").replace(/&#x2F;/g, "/").replace(/&lt;/g, "<");

      if (parms.value) {
        testStr = `${parms.value}`;
        if (testStr.length > 12 && !Number.isNaN(Number(testStr)) && !testStr.includes('.')) {
          return `'${testStr}`;
        }
      }
      if (parms.column.colDef.valueFormatter) {
        return (parms.column.colDef.valueFormatter({ data: parms.node.data, value: parms.value }));
      }
      return parms.value;
    };

    gridOptions.api.exportDataAsCsv(params);
  },

  /**
   * Show/hide the grid's tool panel.
   * @param {string} gridId - the DOM id of the grid.
   * @returns {void}
   */
  toggleToolPanel: function toggleToolPanel(gridId) {
    const gridOptions = crossbeamsGridStore.getGrid(gridId);
    const isShowing = gridOptions.api.isToolPanelShowing();
    gridOptions.api.showToolPanel(!isShowing);
  },

  /**
   * Show a printable version of the grid.
   * @param {string} gridId - the DOM id of the grid.
   * @param {string} gridUrl - the url to populate the grid.
   * @returns {void}
   */
  printAGrid: function printAGrid(gridId, gridUrl) {
    const dispSetting = 'toolbar=yes,location=no,directories=yes,menubar=yes,';
    // dispSetting += 'scrollbars=yes,width=650, height=600, left=100, top=25';
    window.open(`/print_grid?grid_url=${encodeURIComponent(gridUrl)}`, 'printGrid', dispSetting);
  },

  /**
   * Filter a grid using a quick search across all columns in all rows.
   * @param {event} event - a keypress event.
   * @returns {void}
   */
  quickSearch: function quickSearch(event) {
    const gridOptions = crossbeamsGridStore.getGrid(event.target.dataset.gridId);
    // clear on Esc
    if (event.which === 27) {
      event.target.value = '';
    }
    gridOptions.api.setQuickFilter(event.target.value);
  },

  /**
   * Select the previous row in the grid while viewing in a popup form
   * @param {string} gridId - the id of the grid div element.
   * @returns {void}
   */
  prevRow: function prevRow(gridId) {
    const gridOptions = crossbeamsGridStore.getGrid(gridId);
    const selectedNodes = gridOptions.api.getSelectedNodes();
    let selectedNode;
    if (selectedNodes && selectedNodes.length > 0) {
      selectedNode = selectedNodes[0];
    } else {
      selectedNode = gridOptions.api.getDisplayedRowAtIndex(gridOptions.api.getFirstDisplayedRow());
    }
    let found = false;
    let lastNode = null;
    gridOptions.api.forEachNodeAfterFilterAndSort((node, index) => {
      if (!node.group) {
        lastNode = node;
      }
      if (!found && index === selectedNode.rowIndex - 1) {
        if (!node.group) {
          lastNode = node;
        }
        if (lastNode !== null) {
          found = true;
          lastNode.setSelected(true);
          crossbeamsUtils.closePopupDialog();
          crossbeamsGridEvents.viewSelectedRow(gridId);
          gridOptions.api.ensureNodeVisible(lastNode, 'top');
        }
      }
    });
  },

  /**
   * Select the next row in the grid while viewing in a popup form
   * @param {string} gridId - the id of the grid div element.
   * @returns {void}
   */
  nextRow: function nextRow(gridId) {
    const gridOptions = crossbeamsGridStore.getGrid(gridId);
    const selectedNodes = gridOptions.api.getSelectedNodes();
    let selectedNode;
    if (selectedNodes && selectedNodes.length > 0) {
      selectedNode = selectedNodes[0];
    } else {
      selectedNode = gridOptions.api.getDisplayedRowAtIndex(gridOptions.api.getFirstDisplayedRow());
    }
    let found = false;
    gridOptions.api.forEachNodeAfterFilterAndSort((node, index) => {
      if (!found && index > selectedNode.rowIndex) {
        if (!node.group) {
          found = true;
          node.setSelected(true);
          crossbeamsUtils.closePopupDialog();
          crossbeamsGridEvents.viewSelectedRow(gridId);
          gridOptions.api.ensureNodeVisible(node, 'bottom');
        }
      }
    });
  },

  /**
   * Sort the display of a row's columns while viewing in a popup form
   * @param {string} gridId - the id of the grid div element.
   * @returns {void}
   */
  setSortForRowView: function setSortForRowView(gridId, checkbox) {
    crossbeamsLocalStorage.setItem('viewGridRowSorted', checkbox.checked);
    crossbeamsUtils.closePopupDialog();
    crossbeamsGridEvents.viewSelectedRow(gridId);
  },

  /**
   * Display the contents of the currently-selected row in a popup form.
   * @param {string} gridId - the id of the grid div element.
   * @returns {void}
   */
  viewSelectedRow: function viewSelectedRow(gridId) {
    const gridOptions = crossbeamsGridStore.getGrid(gridId);
    let rowNode = gridOptions.api.getSelectedNodes()[0];
    let cnt = 0;
    if (rowNode === undefined) {
      rowNode = gridOptions.api.getDisplayedRowAtIndex(gridOptions.api.getFirstDisplayedRow());
      if (rowNode.group) {
        crossbeamsUtils.alert({ prompt: 'Select a detail row first', type: 'info' });
        return null;
      }
    }
    let rows = 0;
    gridOptions.api.forEachNodeAfterFilter((n) => { if (!n.group) { rows += 1; } });
    const hidePrev = rowNode.rowIndex === 0 ? ' disabled' : '';
    const hideNext = rowNode.rowIndex === rows - 1 ? ' disabled' : '';

    const holdKeys = gridOptions.columnApi.getAllDisplayedColumns().filter(c => c.colDef.headerName !== '' && c.colDef.headerName !== 'Group');
    let useKeys;
    const sorted = crossbeamsLocalStorage.getItem('viewGridRowSorted');
    if (sorted) {
      useKeys = holdKeys.sort((a, b) => {
        const nameA = a.colDef.headerName.toUpperCase();
        const nameB = b.colDef.headerName.toUpperCase();
        if (nameA < nameB) {
          return -1;
        }
        if (nameA > nameB) {
          return 1;
        }

        return 0;
      }).map(c => c.colDef.field);
    } else {
      useKeys = holdKeys.map(c => c.colDef.field);
    }

    const content = `<div>
      <button class="f6 link dim br2 ph3 pv2 dib white bg-dark-blue" onclick="crossbeamsGridEvents.prevRow('${gridId}')"${hidePrev}>
        <svg class="cbl-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M7.05 9.293L6.343 10 12 15.657l1.414-1.414L9.172 10l4.242-4.243L12 4.343z"/></svg> Prev
      </button>
      <button class="f6 link dim br2 ph3 pv2 dib white bg-dark-blue" onclick="crossbeamsGridEvents.nextRow('${gridId}')"${hideNext}>
        Next <svg class="cbl-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M12.95 10.707l.707-.707L8 4.343 6.586 5.757 10.828 10l-4.242 4.243L8 15.657l4.95-4.95z"/></svg>
      </button>
      <label><input type="checkbox" onchange="crossbeamsGridEvents.setSortForRowView('${gridId}', this)" ${sorted ? 'checked="y"' : ''}> Sort column names</label>
      </div>
      <div style="overflow-y:auto;top:40px;bottom:10px;left:10px;right:10px;min-height:200px;max-height:400px;">
      <table class="thinbordertable grid-row-view" style="margin:0 0.5em">
      <thead>
      <tr><th>Column</th><th style="min-width:15em">Value</th></tr>
      </thead>
      <tbody>
      ${useKeys.filter(l => gridOptions.api.getColumnDef(l) !== null).map(k => `
        <tr class="hover-row ${(() => { cnt += 1; return cnt % 2 === 0 ? 'roweven' : 'rowodd'; })()}"><td>
          ${gridOptions.api.getColumnDef(k) && gridOptions.api.getColumnDef(k).headerName}
          </td><td class="selected-grid-row-display ${gridOptions.api.getColumnDef(k) && gridOptions.api.getColumnDef(k).cellClass ? gridOptions.api.getColumnDef(k).cellClass : ''}">
          ${((data) => {
            const colDef = gridOptions.api.getColumnDef(k);
            if (colDef === null || data === null) {
              return '';
            } else if (data === true) {
              return '<span class="ac_icon_check">&nbsp;</span>';
            } else if (data === false) {
              return '<span class="ac_icon_uncheck">&nbsp;</span>';
            }
            if (colDef.valueFormatter) {
              if (colDef.valueFormatter.name === 'numberWithCommas2') {
                return crossbeamsUtils.formatNumberWithCommas(data, 2);
              }
              if (colDef.valueFormatter.name === 'numberWithCommas4') {
                return crossbeamsUtils.formatNumberWithCommas(data, 4);
              }
              if (colDef.valueFormatter.name === 'dateTimeWithoutZoneFormatter') {
                return crossbeamsGridFormatters.dateTimeWithoutZoneFormatter({ data: 'some', value: data });
              }
              if (colDef.valueFormatter.name === 'dateTimeWithoutSecsOrZoneFormatter') {
                return crossbeamsGridFormatters.dateTimeWithoutSecsOrZoneFormatter({ data: 'some', value: data });
              }
            }
            return data;
          })(rowNode.data[k])}
        </td></tr>`).join('')}
      </tbody>
      </table>
      </div>`;
    crossbeamsUtils.showHtmlInDialog('Selected Row', content);
    return null;
  },

  /**
   * Show a prompt asking the user to confirm an action from a link in a grid.
   * @param {element} target - the link.
   * @returns {void}
   */
  promptClick: function promptClick(target) {
    const prompt = target.dataset.prompt;
    const title = target.textContent && target.textContent;
    const url = target.dataset.url;
    const method = target.dataset.method;
    const caller = () => {
      document.body.innerHTML += `<form id="dynForm" action="${url}"
        method="post"><input name="_csrf" type="hidden" value="${document.querySelector('meta[name="_csrf"]').content}" />
        <input name="_method" type="hidden" value="${+method}" /></form>`;
      document.getElementById('dynForm').submit();
    };

    crossbeamsUtils.confirm({
      prompt,
      okFunc: caller,
      title,
    });
    // TODO: make call via AJAX & reload grid? Or http to server to figure it out?.....
    // ALSO: disable link automatically while call is being processed...
    target.stopPropagation();
    target.preventDefault();
  },
};

// ------------------------------
// || SEARCHABLE SELECT EDITOR ||
// ------------------------------

// function to act as a class
function SearchableSelectCellEditor() {}

// SearchableSelectCellEditor.prototype.build = function build() {
this.build = function build() {
  this.eList.innerHTML = '';
  this.filtered_params.forEach((param) => {
    const li = document.createElement('li');
    li.textContent = param;
    if (param === this.selected) {
      li.classList.add('selected');
    }
    this.eList.appendChild(li);
  });
};

// gets called once before the renderer is used
SearchableSelectCellEditor.prototype.init = (params) => {
  this.selected = params.value;
  this.container = document.createElement('div');
  this.container.setAttribute('class', 'ag-editor-popup');
  this.params = params;
  this.filtered_params = params.values;
  this.eInput = document.createElement('input');
  this.eInput.placeholder = 'Filter options';
  this.container.appendChild(this.eInput);
  this.eList = document.createElement('ul');
  this.container.appendChild(this.eList);
  this.build();

  const that = this;
  this.eList.addEventListener('click', (e) => {
    that.eList.querySelectorAll('.selected').forEach(item => item.classList.remove('selected'));
    that.selected = e.target.textContent;
    e.target.classList.add('selected'); // remove all others...
    that.params.stopEditing();
  });

  this.eInput.addEventListener('keyup', () => {
    const searchTerm = that.eInput.value.toUpperCase();
    if (searchTerm === '') {
      that.filtered_params = that.params.values;
    } else {
      that.filtered_params = that.params.values.filter(item => item && item.toUpperCase().includes(searchTerm));
    }
    that.build();
  });
};

// gets called once when grid ready to insert the element
SearchableSelectCellEditor.prototype.getGui = () => this.container;

// focus and select can be done after the gui is attached
SearchableSelectCellEditor.prototype.afterGuiAttached = () => this.eInput.focus();

// returns the new value after editing
SearchableSelectCellEditor.prototype.getValue = () => this.selected;

// if true, then this editor will appear in a popup
SearchableSelectCellEditor.prototype.isPopup = () => true;

// // ----------------------------------------
// // || SEARCHABLE SELECT EDITOR - Choices ||
// // ----------------------------------------
//
// // function to act as a class
// function SearchableSelectCellEditor() {}
//
// // gets called once before the renderer is used
// SearchableSelectCellEditor.prototype.init = (params) => {
//   this.eInput = document.createElement('select');
//   params.values.forEach((item) => {
//     const option = document.createElement('option');
//     option.value = item;
//     option.text = item;
//     if (params.value && params.value === item) {
//       option.selected = true;
//     }
//     this.eInput.appendChild(option);
//   });
// };
//
// // gets called once when grid ready to insert the element
// SearchableSelectCellEditor.prototype.getGui = () => this.eInput;
//
// // focus and select can be done after the gui is attached
// SearchableSelectCellEditor.prototype.afterGuiAttached = () => {
//   this.eChoice = new Choices(this.eInput, {
//     searchEnabled: true,
//     searchResultLimit: 100,
//     removeItemButton: true,
//     itemSelectText: '',
//     classNames: {
//       containerOuter: 'choices cbl-input',
//       containerInner: 'choices__inner_cbl',
//       highlightedState: 'is-highlighted_cbl',
//     },
//     shouldSort: true,
//     searchFields: ['label'],
//     fuseOptions: {
//       include: 'score',
//       threshold: 0.25,
//     },
//   });
//   this.eChoice.showDropdown();
// };
//
// // returns the new value after editing
// SearchableSelectCellEditor.prototype.getValue = () => this.eChoice.getValue(true);
//
// // any cleanup we need to be done here
// SearchableSelectCellEditor.prototype.destroy = () => {
//   this.eChoice.destroy();
// };
//
// // if true, then this editor will appear in a popup
// SearchableSelectCellEditor.prototype.isPopup = () => true;

// -------------------------
// || NUMERIC CELL EDITOR ||
// -------------------------

// function to act as a class
function NumericCellEditor() {
}

// gets called once before the renderer is used
NumericCellEditor.prototype.init = (params) => {
  this.dataType = params.dataType || 'numeric';
  this.nonKeyInit = params.charPress === null;
  // create the cell
  this.eInput = document.createElement('input');
  this.eInput.value = crossbeamsUtils.isCharNumeric(params.charPress)
    ? params.charPress
    : params.value;

  const that = this;
  this.eInput.addEventListener('keypress', (event) => {
    if (this.dataType === 'integer') {
      if (!crossbeamsUtils.isKeyPressedNumeric(event)) {
        that.eInput.focus();
        if (event.preventDefault) event.preventDefault();
      }
    } else {
      const charCode = crossbeamsUtils.getCharCodeFromEvent(event);
      const charStr = String.fromCharCode(charCode);
      if (!crossbeamsUtils.isKeyPressedNumeric(event) && charStr !== '.') {
        that.eInput.focus();
        if (event.preventDefault) event.preventDefault();
      }
    }
  });

  // only start edit if key pressed is a number, not a letter
  const charSet = this.dataType === 'integer' ? '1234567890' : '1234567890.';
  const charPressIsNotANumber = params.charPress && (charSet.indexOf(params.charPress) < 0);
  this.cancelBeforeStart = charPressIsNotANumber;
};

// gets called once when grid ready to insert the element
NumericCellEditor.prototype.getGui = () => this.eInput;

// focus and select can be done after the gui is attached
NumericCellEditor.prototype.afterGuiAttached = () => {
  if (this.nonKeyInit) this.eInput.select();
  this.eInput.focus();
};

// returns the new value after editing
NumericCellEditor.prototype.isCancelBeforeStart = () => this.cancelBeforeStart;

// example - will reject the number if it contains the value 007
// - not very practical, but demonstrates the method.
NumericCellEditor.prototype.isCancelAfterEnd = () => {
  // var value = this.getValue();
  // return value.indexOf('007') >= 0;
};

// returns the new value after editing
NumericCellEditor.prototype.getValue = () => {
  if (this.eInput.value === '') {
    return '';
  }
  if (this.dataType === 'integer') {
    return parseInt(this.eInput.value, 10);
  }
  return parseFloat(this.eInput.value, 10);
};

// any cleanup we need to be done here
NumericCellEditor.prototype.destroy = () => {
  // but this example is simple, no cleanup, we could  even leave this method out as it's optional
};

// if true, then this editor will appear in a popup
// and we could leave this method out also, false is the default
NumericCellEditor.prototype.isPopup = () => true;

// -------------------------------------------------------------------
let midLevelColumnDefs;
let detailColumnDefs;
// -------------------------------------------------------------------

function Level3PanelCellRenderer() {}
function Level2PanelCellRenderer() {}

Level2PanelCellRenderer.prototype.init = function init(params) {
  // trick to convert string of html into dom object
  const eTemp = document.createElement('div');
  eTemp.innerHTML = this.getTemplate(params);
  this.eGui = eTemp.firstElementChild;

  this.setupLevel2Grid(params.data);
  this.consumeMouseWheelOnDetailGrid();
  this.addSeachFeature();
  // this.addButtonListeners();
};

Level2PanelCellRenderer.prototype.setupLevel2Grid = function setupLevel2Grid(l2Data) {
  this.level2GridOptions = {
    enableSorting: true,
    // enableFilter: true,
    enableColResize: true,
    rowData: l2Data,
    columnDefs: midLevelColumnDefs, // TODO: ..............................
    suppressMenuFilterPanel: true,
    isFullWidthCell: function isFullWidthCell(rowNode) {
      return rowNode.level === 1;
    },
    // onGridReady: function (params) {
    //   setTimeout( function () { params.api.sizeColumnsToFit(); }, 0);
    // },
    // see ag-Grid docs cellRenderer for details on how to build cellRenderers
    fullWidthCellRenderer: Level3PanelCellRenderer, // ONLY IF THERE IS A third....
    getRowHeight: function getRowHeight(params) {
      const rowIsDetailRow = params.node.level === 1;
      // return 100 when detail row, otherwise return 25
      return rowIsDetailRow ? 200 : 25;
    },
    getNodeChildDetails: function getNodeChildDetails(record) {
      if (record.level3) {
        return {
          group: true,
          // the key is used by the default group cellRenderer
          key: record.program_name, // TODO: .........................
          // provide ag-Grid with the children of this group
          children: [record.level3],
          // for demo, expand the third row by default
          // expanded: record.account === 177005
        };
      }
      return null;
    },
  };

  const eDetailGrid = this.eGui.querySelector('.full-width-grid');
  new agGrid.Grid(eDetailGrid, this.level2GridOptions); // eslint-disable-line no-new
};

Level2PanelCellRenderer.prototype.getTemplate = function getTemplate(params) {
  const parentRecord = params.node.parent.data;

  const template = `<div class="full-width-panel">
       <div class="full-width-grid" style="height:100%"></div>
       <div class="full-width-grid-toolbar">
            <b>Functional area: </b>${parentRecord.functional_area_name}
            <input class="full-width-search" placeholder="Search..."/>
            <a href="/security/functional_areas/programs/$:functional_area_id$/new">Add a Program</a>
       </div>
     </div>`;

  return template;
};

Level2PanelCellRenderer.prototype.getGui = function getGui() {
  return this.eGui;
};

Level2PanelCellRenderer.prototype.destroy = function destroy() {
  this.level2GridOptions.api.destroy();
};

Level2PanelCellRenderer.prototype.addSeachFeature = function addSeachFeature() {
  const tfSearch = this.eGui.querySelector('.full-width-search');
  const gridApi = this.level2GridOptions.api;

  const searchListener = function searchListener() {
    const filterText = tfSearch.value;
    gridApi.setQuickFilter(filterText);
  };

  tfSearch.addEventListener('input', searchListener);
};

// Level2PanelCellRenderer.prototype.addButtonListeners = function () {
//   var eButtons = this.eGui.querySelectorAll('.full-width-grid-toolbar button');
//
//   for (var i = 0;  i<eButtons.length; i++) {
//     eButtons[i].addEventListener('click', function () {
//       window.alert('Sample button pressed!!');
//     });
//   }
// };

// if we don't do this, then the mouse wheel will be picked up by the main
// grid and scroll the main grid and not this component. this ensures that
// the wheel move is only picked up by the text field
Level2PanelCellRenderer.prototype.consumeMouseWheelOnDetailGrid = function consumeMouseWheelOnDetailGrid() {
  const eDetailGrid = this.eGui.querySelector('.full-width-grid');

  const mouseWheelListener = function mouseWheelListener(event) {
    event.stopPropagation();
  };

  // event is 'mousewheel' for IE9, Chrome, Safari, Opera
  eDetailGrid.addEventListener('mousewheel', mouseWheelListener);
  // event is 'DOMMouseScroll' Firefox
  eDetailGrid.addEventListener('DOMMouseScroll', mouseWheelListener);
};

Level3PanelCellRenderer.prototype.init = function init(params) {
  // trick to convert string of html into dom object
  const eTemp = document.createElement('div');
  eTemp.innerHTML = this.getTemplate(params);
  this.eGui = eTemp.firstElementChild;

  this.setupDetailGrid(params.data);
  this.consumeMouseWheelOnDetailGrid();
  this.addSeachFeature();
  // this.addButtonListeners();
};

Level3PanelCellRenderer.prototype.setupDetailGrid = function setupDetailGrid(l3Data) {
  this.detailGridOptions = {
    enableSorting: true,
    enableFilter: true,
    enableColResize: true,
    rowData: l3Data,
    columnDefs: detailColumnDefs, // .... TODO: ...............
    // onGridReady: function (params) {
    //   setTimeout( function () { params.api.sizeColumnsToFit(); }, 0);
    // }
  };

  const eDetailGrid = this.eGui.querySelector('.full-width-grid');
  new agGrid.Grid(eDetailGrid, this.detailGridOptions); // eslint-disable-line no-new
};

Level3PanelCellRenderer.prototype.getTemplate = function getTemplate(params) {
  const parentRecord = params.node.parent.data;

  const template = `<div class="full-width-panel"style="background-color: silver">
       <div class="full-width-grid" style="height:100%"></div>
       <div class="full-width-grid-toolbar">
            <b>Program: </b>s${parentRecord.program_name}
            <input class="full-width-search" placeholder="Search..."/>
            <button>Add a Program Function</button>
       </div>
     </div>`;

  return template;
};

Level3PanelCellRenderer.prototype.getGui = function getGui() {
  return this.eGui;
};

Level3PanelCellRenderer.prototype.destroy = function destroy() {
  this.detailGridOptions.api.destroy();
};

Level3PanelCellRenderer.prototype.addSeachFeature = function addSeachFeature() {
  const tfSearch = this.eGui.querySelector('.full-width-search');
  const gridApi = this.detailGridOptions.api;

  const searchListener = function searchListener() {
    const filterText = tfSearch.value;
    gridApi.setQuickFilter(filterText);
  };

  tfSearch.addEventListener('input', searchListener);
};

// Level3PanelCellRenderer.prototype.addButtonListeners = function () {
//   var eButtons = this.eGui.querySelectorAll('.full-width-grid-toolbar button');
//
//   for (var i = 0;  i<eButtons.length; i++) {
//     eButtons[i].addEventListener('click', function () {
//       window.alert('Sample button pressed!!');
//     });
//   }
// };

// if we don't do this, then the mouse wheel will be picked up by the main
// grid and scroll the main grid and not this component. this ensures that
// the wheel move is only picked up by the text field
Level3PanelCellRenderer.prototype.consumeMouseWheelOnDetailGrid = function consumeMouseWheelOnDetailGrid() {
  const eDetailGrid = this.eGui.querySelector('.full-width-grid');

  const mouseWheelListener = function mouseWheelListener(event) {
    event.stopPropagation();
  };

  // event is 'mousewheel' for IE9, Chrome, Safari, Opera
  eDetailGrid.addEventListener('mousewheel', mouseWheelListener);
  // event is 'DOMMouseScroll' Firefox
  eDetailGrid.addEventListener('DOMMouseScroll', mouseWheelListener);
};

const crossbeamsGridStaticLoader = {
  translateColDefs: (columnDefs) => {
    const newColDefs = [];
    let newCol = {};
    columnDefs.forEach((col) => {
      newCol = {};
      Object.keys(col).forEach((attr) => {
        if (attr === 'cellRenderer') {
          newCol[attr] = col[attr]; // Default behaviour is to copy it over.
          if (col[attr] === 'crossbeamsGridFormatters.testRender') {
            newCol[attr] = crossbeamsGridFormatters.testRender;
          }
          if (col[attr] === 'crossbeamsGridFormatters.menuActionsRenderer') {
            newCol[attr] = crossbeamsGridFormatters.menuActionsRenderer;
          }
          if (col[attr] === 'crossbeamsGridFormatters.numberWithCommas2') {
            newCol[attr] = crossbeamsGridFormatters.numberWithCommas2;
          }
          if (col[attr] === 'crossbeamsGridFormatters.numberWithCommas4') {
            newCol[attr] = crossbeamsGridFormatters.numberWithCommas4;
          }
          if (col[attr] === 'crossbeamsGridFormatters.booleanFormatter') {
            newCol[attr] = crossbeamsGridFormatters.booleanFormatter;
          }
          if (col[attr] === 'crossbeamsGridFormatters.iconFormatter') {
            newCol[attr] = crossbeamsGridFormatters.iconFormatter;
          }
          if (col[attr] === 'crossbeamsGridFormatters.hrefInlineFormatter') {
            newCol[attr] = crossbeamsGridFormatters.hrefInlineFormatter;
          }
          if (col[attr] === 'crossbeamsGridFormatters.hrefSimpleFormatter') {
            newCol[attr] = crossbeamsGridFormatters.hrefSimpleFormatter;
          }
          if (col[attr] === 'crossbeamsGridFormatters.hrefSimpleFetchFormatter') {
            newCol[attr] = crossbeamsGridFormatters.hrefSimpleFetchFormatter;
          }
          if (col[attr] === 'crossbeamsGridFormatters.hrefPromptFormatter') {
            newCol[attr] = crossbeamsGridFormatters.hrefPromptFormatter;
          }
        } else if (attr === 'valueFormatter') {
          if (col[attr] === 'crossbeamsGridFormatters.numberWithCommas2') {
            newCol[attr] = crossbeamsGridFormatters.numberWithCommas2;
          }
          if (col[attr] === 'crossbeamsGridFormatters.numberWithCommas4') {
            newCol[attr] = crossbeamsGridFormatters.numberWithCommas4;
          }
          if (col[attr] === 'crossbeamsGridFormatters.dateTimeWithoutZoneFormatter') {
            newCol[attr] = crossbeamsGridFormatters.dateTimeWithoutZoneFormatter;
          }
          if (col[attr] === 'crossbeamsGridFormatters.dateTimeWithoutSecsOrZoneFormatter') {
            newCol[attr] = crossbeamsGridFormatters.dateTimeWithoutSecsOrZoneFormatter;
          }
        } else if (attr === 'cellEditor') {
          if (['numericCellEditor',
            'agPopupTextCellEditor',
            'agPopupSelectCellEditor',
            'agRichSelectCellEditor',
            'searchableSelectCellEditor',
            'agLargeTextCellEditor'].indexOf(col[attr]) > -1) {
            newCol[attr] = col[attr];
          } else {
            crossbeamsUtils.alert({ prompt: `${col[attr]} is not a recognised cellEditor`, type: 'error' });
          }
        } else if (attr === 'cellEditorParams') {
          if (col[attr].selectWidth) {
            newCol.cellEditorParams = {
              values: col[attr].values,
              cellRenderer: function cellRenderer(params) {
                return `<div style="display:inline-block;width:${col[attr].selectWidth}px;" title="${params.value || ''}">${params.value || ''}</div>`; // eslint-disable-line max-len
              },
            };
          } else {
            newCol[attr] = col[attr];
          }
        } else if (attr === 'cellEditorType') {
          if (['integer'].indexOf(col[attr]) > -1) {
            newCol.cellEditorParams = { dataType: col[attr] };
          } else {
            crossbeamsUtils.alert({ prompt: `${col[attr]} is not a recognised cellEditorType`, type: 'error' });
          }
        } else if (attr === 'valueGetter') {
          // This blankWhenNull valueGetter is written especially to help when
          // grouping on a column that could have a null value.
          // In that case, AG Grid will hide any rows below the null group.
          if (col[attr] === 'blankWhenNull') {
            newCol.valueGetter = function valueGetter(params) {
              const result = params.data ? params.data[params.colDef.field] : '';
              if (result === null || result === undefined) {
                return '';
              }
              return result;
            };
          } else if (col[attr].startsWith('[{')) {
            // Parse the action menu string:
            newCol.valueGetter = function valueGetter() {
              return JSON.parse(col[attr]);
            };
          } else {
            newCol[attr] = col[attr];
          }
        } else {
          newCol[attr] = col[attr];
        }
      });
      newColDefs.push(newCol);
    });
    return newColDefs;
  },

  applyGeneralGridUi: (gridOptions, colDefs, fieldUpdateUrl, extraContext) => {
    let rows = 0;
    gridOptions.api.forEachLeafNode(() => { rows += 1; });
    if (fieldUpdateUrl) {
      gridOptions.context.fieldUpdateUrl = fieldUpdateUrl;
    }
    if (extraContext) {
      Object.assign(gridOptions.context, extraContext);
    }
    crossbeamsGridEvents.displayRowCounts(gridOptions.context.domGridId, rows, rows);
    // If the grid has no horizontal scrollbar, hide the scroll to column dropdown.
    const grdEl = document.getElementById(gridOptions.context.domGridId);
    const vport = grdEl.querySelector('.ag-body-horizontal-scroll-viewport');
    crossbeamsGridEvents.makeColumnScrollList(gridOptions.context.domGridId,
      colDefs,
      vport.scrollWidth > vport.offsetWidth);
    crossbeamsGridEvents.makeRowBookmark(gridOptions.context.domGridId);
  },

  /**
   * Statically load a grid with column and row values.
   */
  loadGrid: (gridId, colDefs, rowDefs) => {
    const gridOptions = crossbeamsGridStore.getGrid(gridId);
    // find grid
    const newColDefs = crossbeamsGridStaticLoader.translateColDefs(colDefs);
    gridOptions.api.setColumnDefs(newColDefs);
    gridOptions.api.setRowData(rowDefs);
    crossbeamsGridStaticLoader.applyGeneralGridUi(gridOptions, newColDefs);
  },
};

(function crossbeamsGridLoader() {
  /**
   * Dynamically load a grid.
   */
  const loadGrid = function loadGrid(grid, gridOptions) {
    const url = grid.getAttribute('data-gridurl');
    if (url === '') return; // this grid must be loaded statically

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
        let newColDefs = null;
        if (data.exception) {
          crossbeamsUtils.alert({ prompt: data.flash.error, type: 'error' });
          if (data.backtrace) {
            console.groupCollapsed('EXCEPTION:', data.exception, data.flash.error); // eslint-disable-line no-console
            console.info('==Backend Backtrace=='); // eslint-disable-line no-console
            console.info(data.backtrace.join('\n')); // eslint-disable-line no-console
            console.groupEnd(); // eslint-disable-line no-console
          }
          return null;
        }

        if (data.nestedColumnDefs) {
          newColDefs = crossbeamsGridStaticLoader.translateColDefs(data.nestedColumnDefs['1']);
          midLevelColumnDefs = crossbeamsGridStaticLoader.translateColDefs(data.nestedColumnDefs['2']);
          detailColumnDefs = crossbeamsGridStaticLoader.translateColDefs(data.nestedColumnDefs['3']);
        } else {
          newColDefs = crossbeamsGridStaticLoader.translateColDefs(data.columnDefs);
        }
        gridOptions.api.setColumnDefs(newColDefs);
        gridOptions.api.setRowData(data.rowDefs);
        if (!gridOptions.forPrint) {
          crossbeamsGridStaticLoader.applyGeneralGridUi(gridOptions,
            newColDefs,
            data.fieldUpdateUrl,
            data.extraContext);

          if (data.multiselect_ids) {
            gridOptions.api.forEachNode((node) => {
              if (node.data && data.multiselect_ids.includes(node.data.id)) {
                node.setSelected(true);
              }
            });
          }
        }
        return null;
      }).catch((data) => {
        crossbeamsUtils.fetchErrorHandler(data);
      });
  };

  const listenForGrid = function listenForGrid() {
    const grids = document.querySelectorAll('[data-grid]');
    let gridId = null;
    let event = null;
    grids.forEach((grid) => {
      gridId = grid.getAttribute('id');
      event = new CustomEvent('gridLoad', { detail: gridId });
      document.dispatchEvent(event);
    });
  };

  const makeGrid = function makeGrid(event) {
    const gridId = event.detail;
    let gridOptions = null;
    let forPrint = false;
    let multisel = false;
    let tree = false;
    let treeConfig = {};
    const grid = document.getElementById(gridId);

    const frame = document.getElementById(`${gridId}-frame`);
    const sideBar = {
      toolPanels: [
        {
          id: 'columns',
          labelDefault: 'Columns',
          labelKey: 'columns',
          iconKey: 'columns',
          toolPanel: 'agColumnsToolPanel',
        },
      ],
    };

    if ((parseInt(frame.style.height, 10) || '100') > 10) {
      sideBar.toolPanels.push({
        id: 'filters',
        labelDefault: 'Filters',
        labelKey: 'filters',
        iconKey: 'filter',
        toolPanel: 'agFiltersToolPanel',
      });
    }

    forPrint = grid.dataset.gridPrint;
    multisel = grid.dataset.gridMulti;
    tree = grid.dataset.gridTree !== undefined;
    if (tree) {
      treeConfig = JSON.parse(grid.dataset.gridTree);
    }
    // lookup of grid ids? populate here and clear when grid unloaded...
    if (grid.dataset.nestedGrid) {
      gridOptions = {
        context: { domGridId: gridId },
        columnDefs: null,
        rowData: null,
        defaultColDef: {
          resizable: true,
          sortable: true,
          filter: true,
        },
        enableCharts: true,
        enableRangeSelection: true,
        // enableStatusBar: true,
        sideBar,
        suppressAggFuncInHeader: true,
        isFullWidthCell: function isFullWidthCell(rowNode) {
          return rowNode.level === 1;
        },
        onGridReady: function onGridReady(params) {
          params.api.sizeColumnsToFit();
        },
        // see ag-Grid docs cellRenderer for details on how to build cellRenderers
        fullWidthCellRenderer: Level2PanelCellRenderer,
        getRowHeight: function getRowHeight(params) {
          const rowIsDetailRow = params.node.level === 1;
          // return 100 when detail row, otherwise return 25
          return rowIsDetailRow ? 400 : 25;
        },
        getNodeChildDetails: function getNodeChildDetails(record) {
          if (record.level2) {
            return {
              group: true,
              // the key is used by the default group cellRenderer
              key: record.functional_area_name, // ......................TODO: level1 expand_col...
              // provide ag-Grid with the children of this group
              children: [record.level2],
              // for demo, expand the third row by default
              // expanded: record.account === 177005
            };
          }
          return null;
        },
      };
    } else {
      gridOptions = {
        context: { domGridId: gridId },
        rowData: null,
        defaultColDef: {
          resizable: true,
          sortable: true,
          filter: true,
        },
        allowDragFromColumnsToolPanel: true,
        rowSelection: 'single',
        popupParent: document.body,
        enableCharts: true,
        enableRangeSelection: true,
        // singleClickEdit: true,
        statusBar: {
          statusPanels: [
            // { statusPanel: 'agTotalRowCountComponent', align: 'left' },
            // { statusPanel: 'agFilteredRowCountComponent' }, - these two include group rows.
            // { statusPanel: 'agSelectedRowCountComponent' },
            { statusPanel: 'agAggregationComponent' },
          ],
        },
        sideBar,
        suppressAggFuncInHeader: true,
        getRowClass(params) {
          if (params.data) {
            if (params.data.colour_rule) {
              switch (params.data.colour_rule) {
                case 'error':
                  return 'red';
                case 'warning':
                  return 'orange';
                case 'inactive':
                  return 'gray i';
                case 'ready':
                  return 'blue';
                case 'ok':
                  return 'green';
                case 'inprogress':
                  return 'purple';
                default:
                  return params.data.colour_rule;
              }
            }
            if (typeof params.data.active !== 'undefined' && !params.data.active) {
              return 'gray i';
            }
          }
          return null;
        },
        // getRowStyle(params) {
        //   if (params.data) {
        //     if (params.data.colour_rule) {
        //       switch (params.data.colour_rule) {
        //         case 'error':
        //           return { color: 'red' };
        //         case 'warning':
        //           return { color: 'orange' };
        //         case 'inactive':
        //           return { color: 'gray;font-style:italic' };
        //         case 'ready':
        //           return { color: 'blue' };
        //         case 'ok':
        //           return { color: 'green' };
        //         case 'inprogress':
        //           return { color: 'purple' };
        //         default:
        //           return { color: params.data.colour_rule };
        //       }
        //     }
        //     if (typeof params.data.active !== 'undefined' && !params.data.active) {
        //       return { color: 'gray;font-style:italic' };
        //     }
        //   }
        //   return null;
        // },
        onFilterChanged() {
          if (!forPrint) {
            let filterLength = 0;
            let rows = 0;
            this.api.forEachLeafNode(() => { rows += 1; });
            this.api.forEachNodeAfterFilter((n) => { if (!n.group) { filterLength += 1; } });
            crossbeamsGridEvents.displayRowCounts(gridId, filterLength, rows);
          }
        },
        components: {
          numericCellEditor: NumericCellEditor,
          searchableSelectCellEditor: SearchableSelectCellEditor,
          // moodEditor: MoodEditor
        },
        onCellEditingStarted(evt) {
          // Differentiate between User-initiated inline editing and API change of cell value.
          evt.context.cellEdit = true;
        },
        onCellValueChanged(evt) {
          if (evt.context.cellEdit) {
            // Reset the "user-initiated edit" flag
            evt.context.cellEdit = false;
          } else {
            return;
          }
          if (String(evt.oldValue) === String(evt.newValue) || (evt.oldValue === null && evt.newValue === '')) {
            // console.log('NOCHANGE!');
          } else {
            // console.log('Old value: ', evt.oldValue, 'New value: ', evt.newValue);
            crossbeamsGridEvents.cellValueChanged(gridId, evt);
          }
        },
        // suppressCopyRowsToClipboard: true
      };
    }

    if (forPrint) {
      gridOptions.forPrint = true;
      // gridOptions.enableStatusBar = false;
    }

    if (tree) {
      gridOptions.treeData = true;
      gridOptions.groupDefaultExpanded = treeConfig.groupDefaultExpanded || 0;
      gridOptions.getDataPath = data => data[treeConfig.treeColumn];
      gridOptions.autoGroupColumnDef = {
        headerName: treeConfig.treeCaption || 'Hierarchy',
        width: 300,
        pinned: 'left',
        cellRendererParams: {
          suppressCount: treeConfig.suppressNodeCounts || false,
        },
      };
    }

    if (multisel) {
      gridOptions.rowSelection = 'multiple';
      gridOptions.rowDeselection = true;
      gridOptions.suppressRowClickSelection = true;
      gridOptions.groupSelectsChildren = true;
      gridOptions.groupSelectsFiltered = true;
    }

    // Index rows by the id column...
    if (grid.dataset.gridurl !== '') {
      gridOptions.getRowNodeId = function getRowNodeId(data) { return data.id; };
    }

    new agGrid.Grid(grid, gridOptions); // eslint-disable-line no-new
    crossbeamsGridStore.addGrid(gridId, gridOptions);
    loadGrid(grid, gridOptions);
  };

  // reloadGrid(id)
  // get options from id, reload url (delete grid and call loadGrid again)

  document.addEventListener('DOMContentLoaded', () => {
    listenForGrid();
  });

  document.addEventListener('gridLoad', (gridId) => {
    makeGrid(gridId);
  });

  return {
    listenForGrid,
  };
}).call();

document.addEventListener('DOMContentLoaded', () => {
  const buildSubMenuItems = function buildSubMenuItems(subs, gridId) {
    const itemSet = {};
    if (subs) {
      subs.forEach((sub) => {
        if (sub.value && sub.value === '---') {
          itemSet[sub.key] = '---';
        } else {
          itemSet[sub.key] = sub;
        }
        itemSet[sub.key].domGridId = gridId;
      });
    }
    return itemSet;
  };

  const getItemFromTree = function getItemFromTree(key, items) {
    const keyList = key.split('_');
    const currKey = keyList.shift();
    let node = items[currKey];
    let subKey = currKey;
    while (keyList.length > 0) {
      subKey = `${currKey}_${keyList.shift()}`;
      node = node.items[subKey];
    }
    return node;
  };

  jQuery.contextMenu({
    selector: '.grid-context-menu',
    trigger: 'left',
    build: ($trigger, e) => {
      // this callback is executed every time the menu is to be shown
      // its results are destroyed every time the menu is hidden
      // e is the original contextmenu event, containing e.pageX and e.pageY (amongst other data)
      // var url_components;
      // var url;
      const row = e.target.dataset.row;
      const gridId = e.target.dataset.domGridId;
      const items = {};
      JSON.parse(row).forEach((item) => {
        if (item.value && item.value === '---') {
          items[item.key] = '---';
        } else {
          items[item.key] = {
            name: item.value ? item.value : item.name,
            url: item.url,
            prompt: item.prompt,
            method: item.method,
            title: item.title,
            title_field: item.title_field,
            icon: item.icon,
            is_separator: item.is_separator,
            is_submenu: item.is_submenu,
            popup: item.popup,
            loading_window: item.loading_window,
            row_id: item.row_id,
            domGridId: gridId,
          };
          if (item.is_submenu) {
            items[item.key].items = buildSubMenuItems(item.items, gridId);
          }
        }
      });

      return {
        // callback: (key, options) => {
        callback: (key) => {
          const item = getItemFromTree(key, items);
          const caller = () => {
            let form = null;
            // Store current grid row as a bookmark.
            if (document.querySelector(`#${item.domGridId}-frame .crossbeams-row-bookmark`)) {
              crossbeamsUtils.recordGridRowBookmark(item.row_id);
              crossbeamsGridEvents.makeRowBookmark(item.domGridId, true);
            }
            if (item.method === undefined) {
              if (item.popup) {
                crossbeamsUtils.recordGridIdForPopup(item.domGridId);
                crossbeamsUtils.popupDialog(item.title_field, item.url);
              } else if (item.loading_window) {
                crossbeamsUtils.loadingWindow(item.url);
              } else {
                window.location = item.url;
              }
            // TODO: This section needs a rethink. It works, but:
            // - not intuitive to use .popup here
            // - this is probably ONLY for deletes. Any other?
            //   [It can only be a url with id - there is no form data to post...
            // - should ALL deletes from grids be done through fetches? Probably.
            } else if (item.popup) {
              crossbeamsUtils.recordGridIdForPopup(item.domGridId);
              form = new FormData();
              form.append('_method', item.method);
              form.append('_csrf', document.querySelector('meta[name="_csrf"]').content);
              fetch(item.url, {
                method: 'POST',
                credentials: 'same-origin',
                headers: new Headers({
                  'X-Custom-Request-Type': 'Fetch',
                }),
                body: form,
                // }).then(response => response.json())
              }).then((response) => {
                if (response.status === 404) {
                  crossbeamsUtils.showError('The requested resource was not found');
                  return {};
                }
                return response.json();
              })
                .then((data) => {
                  if (data.redirect) {
                    window.location = data.redirect;
                  } else if (data.removeGridRowInPlace) {
                    crossbeamsGridEvents.removeGridRowInPlace(data.removeGridRowInPlace.id);
                  } else if (data.updateGridInPlace) {
                    data.updateGridInPlace.forEach((gridRow) => {
                      crossbeamsGridEvents.updateGridInPlace(gridRow.id, gridRow.changes);
                    });
                  } else if (data.addRowToGrid) {
                    crossbeamsGridEvents.addRowToGrid(data.addRowToGrid.changes, data.addRowToGrid.atStart);
                  } else if (data.actions) {
                    crossbeamsUtils.processActions(data.actions);
                  } else {
                    console.log('Not sure what to do with this:', data); // eslint-disable-line no-console
                  }
                  // Only if not redirect...
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
            } else {
              document.body.innerHTML += `<form id="dynForm" action="${item.url}" method="post">
                <input name="_method" type="hidden" value="${item.method}" />
                <input name="_csrf" type="hidden" value="${document.querySelector('meta[name="_csrf"]').content}" /></form>`;
              document.getElementById('dynForm').submit(); // TODO: csrf...
            }
          };
          if (item.prompt !== undefined) {
            crossbeamsUtils.confirm({
              prompt: item.prompt,
              okFunc: caller,
              title: item.title,
              title_field: item.title_field,
            });
          } else {
            caller();
          }
        },
        items,
      };
    },
  });
});
