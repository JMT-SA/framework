
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
    this.gridStore.forEach((gridId) => {
      lst.push(gridId);
    });
    // for (gridId in this.gridStore) {
    //   lst.push(gridId);
    // }
    return lst.join(', ');
  },
};

/**
 * Handle various events related to interactions with the grid.
 * @namespace
 */
const crossbeamsGridEvents = {
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
    // for (i = 0, len = visibleCols.length; i < len; i++) {
    //   if (visibleCols[i].colDef.suppressCsvExport &&
    //   visibleCols[i].colDef.suppressCsvExport === true) {
    //   } else {
    //     colKeys.push(visibleCols[i].colId);
    //   }
    // }

    params = {
      fileName,
      columnKeys: colKeys, // Visible, non-suppressed columns.
      // skipHeader: true,
      // skipFooters: true,
      // skipGroups: true,
      // allColumns: true,
      // suppressQuotes: true,
      // onlySelected: true,
      // columnSeparator: ';'
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
        if (testStr.length > 12 && !isNaN(testStr) && !testStr.includes('.')) {
          return `'${testStr}`;
        }
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

  // setFilterChangeEvent: function (gridId) {
  //   var gridOptions;
  //
  //   gridOptions = crossbeamsGridStore.getGrid(gridId);
  //   gridOptions.api.afterFilterChanged();
  //   //.api.rowModel.rootNode.childrenAfterFilter.length
  //
  // }

  /**
   * Show the results of a filter change (no rows of total displayed).
   * FIXME: Not yet working.
   * @param {string} gridId - the DOM id of the grid.
   * @returns {void}
   */
  showFilterChange: function showFilterChange(gridId) {
    let filterLength = 0;
    const gridOptions = crossbeamsGridStore.getGrid(gridId);
    if (gridOptions.api.rowModel.rootNode.childrenAfterFilter) {
      filterLength = gridOptions.api.rowModel.rootNode.childrenAfterFilter.length;
    }
    // console.log('onAfterFilterChanged', filterLength, gridId);
  },

  /**
   * Show a prompt asking the user to confirm an action from a link in a grid.
   * @param {element} target - the link.
   * @returns {void}
   */
  promptClick: function promptClick(target) {
    // const target = event.target;
    const prompt = target.dataset.prompt;
    const url = target.dataset.url;
    const method = target.dataset.method;

    swal({
      title: prompt,
      type: 'warning',
      showCancelButton: true,
    }).then(() => {
      document.body.innerHTML += `<form id="dynForm" action="${url}"
        method="post"><input name="_method" type="hidden" value="${+method}" /></form>`;
      document.getElementById('dynForm').submit();
    });
    // TODO: make call via AJAX & reload grid? Or http to server to figure it out?.....
    // ALSO: disable link automatically while call is being processed...
    event.stopPropagation();
    event.preventDefault();
  },
};

const crossbeamsGridFormatters = {
  testRender: function testRender(params) {
    return `<b>${params.value.toUpperCase()}</b>`;
  },

  nextChar: function nextChar(c) {
    return String.fromCharCode(c.charCodeAt(0) + 1);
  },

  makeContextNode: function makeContextNode(key, prefix, items, item, params) {
    let node = {};
    let urlComponents;
    let url;
    let subKey = 'a';
    let subPrefix = '';
    let subnode;
    if (item.is_separator) {
      if (items.length > 0 && _.last(items).value !== '---') {
        return { key: `${prefix}${key}`, name: item.text, value: '---' };
      }
      return null;
    } else if (item.hide_if_null && params.data[item.hide_if_null] === null) {
      // No show of item
      return null;
    } else if (item.hide_if_present && params.data[item.hide_if_present] !== null) {
      // No show of item
      return null;
    } else if (item.is_submenu) {
      node = { key: `${prefix}${key}`, name: item.text, items: [], is_submenu: true };
      item.items.forEach((subitem) => {
        subKey = crossbeamsGridFormatters.nextChar(subKey);
        subPrefix = `${prefix}${key}_`;
        subnode = crossbeamsGridFormatters.makeContextNode(subKey, subPrefix, node.items, subitem, params);
        if (subnode !== null) {
          node.items.push(subnode);
        }
      });
      node.items = _.dropRightWhile(node.items, ['value', '---']);
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
    return { key: `${prefix}${key}`,
      name: item.text,
      url,
      prompt: item.prompt,
      method: item.method,
      title: item.title,
      title_field: item.title_field ? params.data[item.title_field] : item.title ? item.title : '',
      icon: item.icon,
      popup: item.popup,
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
    items = _.dropRightWhile(items, ['value', '---']);
    return `<button class='grid-context-menu' data-dom-grid-id='${params.context.domGridId}' data-row='${JSON.stringify(items)}'>list</button>`;
  },

  // Return a number with thousand separator and at least 2 digits after the decimal.
  numberWithCommas2: function numberWithCommas2(params) {
    if (!params.data) { return null; }

    let x = params.value;
    let parts = [];
    if (typeof x === 'string') { x = parseFloat(x); }
    if (isNaN(x)) { return ''; }
    x = Math.round((x + 0.00001) * 100) / 100; // Round to 2 digits if longer.
    parts = x.toString().split('.');
    parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',');
    if (parts[1] === undefined || parts[1].length === 0) { parts[1] = '00'; }
    if (parts[1].length === 1) { parts[1] += '0'; }
    return parts.join('.');
  },

  // Return a number with thousand separator and at least 4 digits after the decimal.
  numberWithCommas4: function numberWithCommas4(params) {
    if (!params.data) { return null; }

    let x = params.value;
    let parts = [];
    if (typeof x === 'string') { x = parseFloat(x); }
    if (isNaN(x)) { return ''; }
    x = Math.round((x + 0.0000001) * 10000) / 10000; // Round to 4 digits if longer.
    parts = x.toString().split('.');
    parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',');
    if (parts[1] === undefined || parts[1].length === 0) { parts[1] = '0000'; }
    while (parts[1].length < 4) { parts[1] += '0'; }
    return parts.join('.');
  },

  booleanFormatter: function booleanFormatter(params) {
    if (!params.data) { return null; }

    if (params.value === '' || params.value === null) { return ''; }
    if (params.value === true || params.value === 't' || params.value === 'true' || params.value === 'y' || params.value === 1) {
      return '<span class="ac_icon_check">&nbsp;</span>';
    }
    return '<span class="ac_icon_uncheck">&nbsp;</span>';
  },

  hrefInlineFormatter: function hrefInlineFormatter(params) {
    // var rainPerTenMm = params.value / 10;
    return `<a href="/books/${params.value}/edit">edit</a>`;
  },

  hrefSimpleFormatter: function hrefSimpleFormatter(params) {
    const vals = params.value.split('|');
    return `<a href="${vals[0]}">${vals[1]}</a>`;
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
    return `<a href='#' data-prompt="${prompt}" data-method="${method}" data-url="${url}"
    onclick="crossbeamsGridEvents.promptClick();">${linkText}</a>`;
  },
};

// function to act as a class
function NumericCellEditor() {
}

// gets called once before the renderer is used
NumericCellEditor.prototype.init = (params) => {
  // create the cell
  this.eInput = document.createElement('input');
  this.eInput.value = crossbeamsUtils.isCharNumeric(params.charPress)
    ? params.charPress
    : params.value;

  const that = this;
  this.eInput.addEventListener('keypress', (event) => {
    if (!crossbeamsUtils.isKeyPressedNumeric(event)) {
      that.eInput.focus();
      if (event.preventDefault) event.preventDefault();
    }
  });

  // only start edit if key pressed is a number, not a letter
  const charPressIsNotANumber = params.charPress && ('1234567890'.indexOf(params.charPress) < 0);
  this.cancelBeforeStart = charPressIsNotANumber;
};

// gets called once when grid ready to insert the element
NumericCellEditor.prototype.getGui = () => this.eInput;

// focus and select can be done after the gui is attached
NumericCellEditor.prototype.afterGuiAttached = () => {
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
  return parseInt(this.eInput.value, 10);
};

// any cleanup we need to be done here
NumericCellEditor.prototype.destroy = () => {
  // but this example is simple, no cleanup, we could  even leave this method out as it's optional
};

// if true, then this editor will appear in a popup
  // and we could leave this method out also, false is the default
NumericCellEditor.prototype.isPopup = () => false;

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
  new agGrid.Grid(eDetailGrid, this.level2GridOptions);
};

Level2PanelCellRenderer.prototype.getTemplate = function getTemplate(params) {
  const parentRecord = params.node.parent.data;

  const template =
    '<div class="full-width-panel">' +
    '  <div class="full-width-grid" style="height:100%"></div>' +
    '  <div class="full-width-grid-toolbar">' +
    '       <b>Functional area: </b>' + parentRecord.functional_area_name + // TODO: ................
    '       <input class="full-width-search" placeholder="Search..."/>' +
    '       <a href="/security/functional_areas/programs/$:functional_area_id$/new">Add a Program</a>' +
    '  </div>' +
    '</div>';

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
  new agGrid.Grid(eDetailGrid, this.detailGridOptions);
};

Level3PanelCellRenderer.prototype.getTemplate = function getTemplate(params) {
  const parentRecord = params.node.parent.data;

  const template =
    '<div class="full-width-panel"style="background-color: silver">' +
    '  <div class="full-width-grid" style="height:100%"></div>' +
    '  <div class="full-width-grid-toolbar">' +
    '       <b>Program: </b>' + parentRecord.program_name + // TODO: .........................
    '       <input class="full-width-search" placeholder="Search..."/>' +
    '       <button>Add a Program Function</button>' +
    '  </div>' +
    '</div>';

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

(function crossbeamsGridLoader() {
  const translateColDefs = function translateColDefs(columnDefs) {
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
          if (col[attr] === 'crossbeamsGridFormatters.hrefInlineFormatter') {
            newCol[attr] = crossbeamsGridFormatters.hrefInlineFormatter;
          }
          if (col[attr] === 'crossbeamsGridFormatters.hrefSimpleFormatter') {
            newCol[attr] = crossbeamsGridFormatters.hrefSimpleFormatter;
          }
          if (col[attr] === 'crossbeamsGridFormatters.hrefPromptFormatter') {
            newCol[attr] = crossbeamsGridFormatters.hrefPromptFormatter;
          }
        } else if (attr === 'cellEditor') {
          if (col[attr] === 'NumericCellEditor') {
            newCol[attr] = NumericCellEditor;
          } else {
            // Ignore other editor types for now
          }
        } else if (attr === 'valueGetter') {
          // This blankWhenNull valueGetter is written especially to help when grouping on a column that could have a null value.
          // In that case, AG Grid will hide any rows below the null group.
          if (col[attr] === 'blankWhenNull') {
            newCol.valueGetter = function valueGetter(params) {
              const result = params.data ? params.data[params.colDef.field]: "";
              if (result === null || result === undefined) {
                return '';
              }
              return result;
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
  };

  const loadGrid = function loadGrid(grid, gridOptions) {
    const url = grid.getAttribute('data-gridurl');
    const httpRequest = new XMLHttpRequest();
    httpRequest.open('GET', url);

    httpRequest.onreadystatechange = () => {
      let httpResult = null;
      let newColDefs = null;
      if (httpRequest.readyState === 4 && httpRequest.status === 200) {
        httpResult = JSON.parse(httpRequest.responseText);
        // var midLevelColumnDefs, detailColumnDefs;
        if (httpResult.nestedColumnDefs) {
          newColDefs = translateColDefs(httpResult.nestedColumnDefs['1']);
          midLevelColumnDefs = translateColDefs(httpResult.nestedColumnDefs['2']);
          detailColumnDefs = translateColDefs(httpResult.nestedColumnDefs['3']);
        } else {
          newColDefs = translateColDefs(httpResult.columnDefs);
        }
        gridOptions.api.setColumnDefs(newColDefs); // TODO.............. ????
        gridOptions.api.setRowData(httpResult.rowDefs);
      }
    };
    httpRequest.send();
  };

  document.addEventListener('DOMContentLoaded', () => {
    let gridOptions = null;
    let gridId = null;
    let forPrint = false;
    const grids = document.querySelectorAll('[data-grid]');
    grids.forEach((grid) => {
      gridId = grid.getAttribute('id');
      forPrint = grid.dataset.gridPrint;
      // lookup of grid ids? populate here and clear when grid unloaded...
      if (grid.dataset.nestedGrid) {
        gridOptions = {
          context: { domGridId: gridId },
          columnDefs: null,
          rowDefs: null,
          enableColResize: true,
          enableSorting: true,
          enableFilter: true,
          suppressScrollLag: true,
          enableRangeSelection: true,
          enableStatusBar: true,
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
          //columnDefs: null,
          rowDefs: null,
          enableColResize: true,
          enableSorting: true,
          enableFilter: true,
          suppressScrollLag: true,
          enableRangeSelection: true,
          enableStatusBar: true,
          suppressAggFuncInHeader: true,
          // onAfterFilterChanged: function () {
          // console.log('onAfterFilterChanged',
          // this.api.rowModel.rootNode.childrenAfterFilter.length, gridId);}
          // onAfterFilterChanged: crossbeamsGridEvents.showFilterChange(gridId) // TODO: fix...
          // suppressCopyRowsToClipboard: true
          // quickFilterText: 'fred'
        };
      }

      if (forPrint) {
        gridOptions.forPrint = true;
        gridOptions.enableStatusBar = false;
      }

      // Index rows by the id column...
      gridOptions.getRowNodeId = function getRowNodeId(data) { return data.id; };

      new agGrid.Grid(grid, gridOptions);
      crossbeamsGridStore.addGrid(gridId, gridOptions);
      // gridOptions.onAfterFilterChanged = crossbeamsGridEvents.showFilterChange(gridId);
      loadGrid(grid, gridOptions);
    });
  });
}).call();

$(() => {
  const buildSubMenuItems = function buildSubMenuItems(subs, gridId) {
    const itemSet = {};
    if (subs) {
      subs.forEach((sub) => {
        itemSet[sub.key] = sub;
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

  // $.contextMenu({
  //   selector: '.grid-tools-menu',
  //   trigger: 'left',
  // });

  $.contextMenu({
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
            domGridId: gridId,
          };
          if (item.is_submenu) {
            items[item.key].items = buildSubMenuItems(item.items, gridId);
          }
        }
      });

      return {
        callback: (key, options) => {
          const item = getItemFromTree(key, items);
          const caller = () => {
            if (item.method === undefined) {
              if (item.popup) {
                crossbeamsLocalStorage.setItem('popupOnGrid', item.domGridId);
                crossbeamsUtils.jmtPopupDialog(100, 100, item.title_field, '', item.url);
              } else {
                window.location = item.url;
              }
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
