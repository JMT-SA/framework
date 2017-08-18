/* exported crossbeamsDataMinerParams */

/**
 * Behaviour for parameter entry page of Crossbeams DataMiner reports.
 * @namespace
 */
const crossbeamsDataMinerParams = {

  /**
   * The Choice object, used to store a filled-in parameter:
   * @typedef {Object} Choice
   * @property {string} col - query column name
   * @property {string} op - operator (=,>...)
   * @property {string} opText - operater (is, greater than...)
   * @property {string} val - selected/input value
   * @property {string} valTo - second value for date ranges
   * @property {string} text - selected value as text (e.g. for dropdown this could differ from the value)
   * @property {string} textTo - second value for date ranges as text
   */

  formId: '',
  reportNo: '',
  queryParams: {},
  /**
   * @type {...Choice}
   */
  current_values: [],

  removeQueryParamItem: function removeQueryParamItem(node) {
    const index = crossbeamsUtils.getListIndex(node);
    this.current_values = this.current_values.splice(index, 1);
    node.parentNode.removeChild(node);
  },

  /**
   * Take a query item and format it in HTML for display as an li tag.
   * @param {object} item - the query item to be displayed.
   * @return {string} - HTML li tag.
   */
  queryItemAsText: function queryItemAsText(item) {
    let val = '';
    let valTo = '';
    if (item.op === 'is_null' || item.op === 'not_null') {
      val = '';
      valTo = '';
    } else {
      val = item.text;
      if (item.op === 'between') {
        valTo = ` AND ${item.textTo}`;
      } else {
        valTo = '';
      }
    }
    // return '<li style="list-style-type:none;">
    // <i class="fa fa-minus" style="cursor:pointer;color:red;"
    // onclick="removeQueryParamItem(this.parentNode)">
    // </i> ' + item.caption + ' ' + item.opText + ' ' + item.text;
    return `<li style="list-style-type:none;"><i class="fa fa-minus" style="cursor:pointer;color:red;" onclick="crossbeamsDataMinerParams.removeQueryParamItem(this.parentNode)"></i> ${item.caption} ${item.opText} ${val}${valTo}`;
  },

  /**
   * Format the query parameters as an HTML list.
   * Calls queryItemAsText to render each item.
   * @param {object} paramValues - the currently selected parameter values.
   * @return {string} - HTML li tags.
   */
  querySelectionAsText: function querySelectionAsText(paramValues) {
    if (paramValues.length === 0) {
      return '<li style="list-style-type:none;">None selected</li>';
    }
    // var items = paramValues.map(function (entry) {
    //         return queryItemAsText(entry);
    // });
    const items = [];
    paramValues.forEach((item) => {
      items.push(crossbeamsDataMinerParams.queryItemAsText(item));
    });
    // for (i=0;i<paramValues.length;i++) {
    //     items.push(crossbeamsDataMinerParams.queryItemAsText(paramValues[i]));
    // }
    return items.join('');
  },

  /**
   * Check if a particular query param item is in a list of items.
   * @param {Choice} obj - the query param item.
   * @param {array} list - the list of items.
   * @return {boolean} - true if the object is in the list.
   */
  containsObject: function containsObject(obj, list) {
    let foundMatch = false;
    list.forEach((item) => {
      if (item.col === obj.col && item.op === obj.op && item.val === obj.val &&
        item.valTo === obj.valTo) { // TODO: range of vals etc...
        foundMatch = true;
      }
    });
    return foundMatch;
  },

  /**
   * Replace the param_display DOM node's innerHTML with a list of the query parameters.
   * @return {void}
   */
  displayParamsAsText: function displayParamsAsText() {
    let disp = '<ul>';
    disp += this.querySelectionAsText(this.current_values);
    disp += '</ul>';
    document.getElementById('param_display').innerHTML = disp;
  },

  /**
   * Event handler for change of operator select tag.
   * @param {event} event - the change event.
   * @returns {void}
   */
  operatorParmChange: function operatorParmChange(event) {
    const val1 = document.getElementById('qp_value');
    const val2 = document.getElementById('qp_value_to');
    switch (event.target.value) {
      case 'between':
        val1.style.display = '';
        val2.style.display = '';
        break;
      case 'is_null':
        val1.style.display = 'none';
        val2.style.display = 'none';
        break;
      case 'not_null':
        val1.style.display = 'none';
        val2.style.display = 'none';
        break;
      default:
        val1.style.display = '';
        val2.style.display = 'none';
    }
  },

  /**
   * Translate the user-entered parameters into a Choice object and add it to the list of current parameters. Update the UI.
   * @returns {boolean} - true if the parametr combinations are valid and it could be added to the list.
   */
  addQpFormParam: function addQpFormParam() {
    const choice = {};
    const valElem = document.getElementById('qp_value');
    const valElem2 = document.getElementById('qp_value_to');
    choice.col = document.getElementById('qp_column').value;
    choice.op = document.getElementById('qp_operator').value;
    choice.opText = document.getElementById('qp_operator').options[document.getElementById('qp_operator').selectedIndex].text;
    choice.val = valElem.value;
    choice.valTo = valElem2.value;
    const qp = this.queryParams[choice.col];
    if (qp.control_type === 'list') {
      choice.text = valElem.options[valElem.selectedIndex].text;
      choice.textTo = '';
    } else {
      choice.text = choice.val;
      choice.textTo = choice.valTo;
    }
    choice.caption = qp.caption;
    // if something other than is null or not null, 1st val must be present.
    // If between, both must be present...
    if (choice.op !== 'is_null' && choice.op !== 'not_null') {
      if (choice.val === '') {
        return false;
      }
    }
    if (choice.op === 'between') {
      if (choice.valTo === '') {
        return false;
      }
    }
    if (!crossbeamsDataMinerParams.containsObject(choice, this.current_values)) {
      this.current_values.push(choice);
      crossbeamsDataMinerParams.displayParamsAsText();
    }
    return true;
  },

  /**
   * Listeners for change of parameters and of operators.
   * @param {DOM node} node - a node added to the page.
   * @returns {void}
   */
  checkNode: function checkNode(addedNode) {
    let event = null;
    if (addedNode.nodeType === 1) {
      if (addedNode.matches('#qp_operator')) {
        addedNode.addEventListener('change', crossbeamsDataMinerParams.operatorParmChange);
        event = document.createEvent('HTMLEvents');
        event.initEvent('change', true, false);
        addedNode.dispatchEvent(event);
      }
    }
  },

  // Store current params
  // store limit, offset & current_values
  // key:...url, including report
  // val: {limit: ; offset: ; current_values: }
  // .. on submit form, store
  // .. on load, pass 'back' to init to reload params.
  // Maybe store previous n dm params?
  /**
   * Store the parameters as currently active on the page in local storage.
   * @returns {void}
   */
  storeCurrentParams: function storeCurrentParams() {
    const limit = document.querySelector(`#${this.formId} input[name=limit]`).value;
    const offset = document.querySelector(`#${this.formId} input[name=offset]`).value;
    const stored = { limit, offset, paramValues: this.current_values };

    const key = crossbeamsLocalStorage.genStandardKey(this.reportNo);
    crossbeamsLocalStorage.setItem(key, stored);
  },

  /**
   * Find the last-saved parameters in local storage for this report.
   * If there, apply them to the page.
   * @returns {void}
   */
  loadCurrentParams: function loadCurrentParams() {
    const key = crossbeamsLocalStorage.genStandardKey(this.reportNo);
    let stored = null;
    if (crossbeamsLocalStorage.hasItem(key)) {
      // console.log('LOADING', this.reportNo, key);
      stored = crossbeamsLocalStorage.getItem(key);
      document.querySelector(`#${this.formId} input[name=limit]`).value = stored.limit;
      document.querySelector(`#${this.formId} input[name=offset]`).value = stored.offset;
      this.current_values = stored.paramValues;
      crossbeamsDataMinerParams.displayParamsAsText();
    }
  },

  /**
   * Find the last-saved parameters in local storage for this report.
   * If there, apply them to the page and immediately submit the form.
   * @returns {void}
   */
  runWithCurrentParams: function runWithCurrentParams() {
    const key = crossbeamsLocalStorage.genStandardKey(this.reportNo);
    let stored = null;
    if (crossbeamsLocalStorage.hasItem(key)) {
      stored = crossbeamsLocalStorage.getItem(key);
      document.querySelector(`#${this.formId} input[name=limit]`).value = stored.limit;
      document.querySelector(`#${this.formId} input[name=offset]`).value = stored.offset;
      this.current_values = stored.paramValues;
    }
    crossbeamsUtils.addJSONVarToForm(this.formId, crossbeamsDataMinerParams.current_values);
    document.querySelector(`#${this.formId}`).submit();
  },

  /**
   * Check if there are previously-used parameters for this report.
   * If there are, the button to reload them becomes visible, else it ramains hidden.
   * @returns {void}
   */
  buildReloadButton: function buildReloadButton() {
    const key = crossbeamsLocalStorage.genStandardKey(this.reportNo);
    if (crossbeamsLocalStorage.hasItem(key)) {
      document.querySelector('#reloadParams').style.display = '';
    }
  },

  /**
   * Go through all parameter definitions for this report and
   * if any have default values, apply them.
   * @returns {void}
   */
  applyDefaultValues: function applyDefaultValues(queryParams) {
    // for (qp in queryParams) { if (queryParams[qp].hasOwnProperty('default_value')) {
    // console.log(queryParams[qp]['default_value']); } }
    const choice = {};
    let elem = null;
    Object.keys(queryParams).forEach((qp) => {
      if (queryParams[qp].default_value) {
        // console.log(queryParams[qp]['default_value']);
        elem = queryParams[qp];
        choice.col = elem.column;
        choice.op = '=';
        choice.opText = 'is';
        choice.val = elem.default_value;
        choice.text = elem.default_value;
        choice.valTo = '';
        choice.textTo = '';
        choice.caption = elem.caption;
        this.current_values.push(choice);
      }
    });
    // for (qp in queryParams) {
    //     if (queryParams[qp].default_value) {
    //         // console.log(queryParams[qp]['default_value']);
    //         elem = queryParams[qp];
    //         choice.col = elem.column;
    //         choice.op = "=";
    //         choice.opText = "is";
    //         choice.val = elem.default_value;
    //         choice.text = elem.default_value;
    //         choice.valTo = "";
    //         choice.textTo = "";
    //         choice.caption = elem.caption;
    //         this.current_values.push(choice);
    //     }
    // }
  },

  /**
   * Initialise the crossbeamsDataMinerParams environment for the page.
   * @param {string} inFormId - the id of the form that will run the report.
   * @param {string} inRptId - the id of the report to be run.
   * @param {object} qprm - the query parameter definitions.
   * @returns {void}
   */
  init: function init(inFormId, inRptId, qprm) {
    let observer = null;
    this.formId = inFormId;
    this.reportNo = inRptId;
    this.queryParams = qprm;

    document.getElementById('select_param').addEventListener('change', (event) => {
      const val = event.target.value;
      let qp = null;
      let valInput = null;
      let inputType = null;
      const qpForm = document.getElementById('qp_form');
      if (val === '') {
        qpForm.innerHTML = '';
      } else {
        qp = crossbeamsDataMinerParams.queryParams[val];
        inputType = '';
        switch (qp.data_type) {
          case 'number':
            inputType = 'type="number"';
            break;
          case 'integer':
            inputType = 'type="number" pattern="\\d*"'; // Allow for minus sign?...
            break;
          case 'date':
            inputType = 'type="date"';
            break;
          case 'datetime':
            inputType = 'type="datetime-local"';
            break;

          // no default
        }

        if (qp.control_type === 'list') {
          valInput = `${crossbeamsUtils.makeSelect('qp_value', qp.list_values)}
            <input name="qp_value_to" id="qp_value_to" style="display:none" />`;
        } else if (qp.control_type === 'daterange') {
          valInput = `<input name="qp_value" id="qp_value" value="${
            (qp.default_value === null
              ? ''
                : qp.default_value)}" ${inputType} />
            <input name="qp_value_to" id="qp_value_to" ${inputType} />`;
        } else {
          valInput = `<input name="qp_value" id="qp_value" value="${
          (qp.default_value === null
            ? ''
              : qp.default_value)}" ${inputType} />
            <input name="qp_value_to" id="qp_value_to" style="display:none"${inputType} />`;
        }
        qpForm.innerHTML = `<form id="dForm" action="">
          <input type="hidden" id="qp_column" value="${qp.column}" />
          ${crossbeamsUtils.makeSelect('qp_operator', qp.operator)}
          ${valInput}
          <button type="button" class="pure-button pure-button"
          onclick="crossbeamsDataMinerParams.addQpFormParam()">
          <i class="fa fa-plus"></i></button></form>`;
      }
      // event.stopPropagation();
      // event.preventDefault();
    });

    // Apply default parameter values.
    crossbeamsDataMinerParams.applyDefaultValues(crossbeamsDataMinerParams.queryParams);

    crossbeamsDataMinerParams.displayParamsAsText();

    observer = new MutationObserver((mutations) => {
      mutations.forEach((node) => {
        node.addedNodes.forEach((addedNode) => {
          crossbeamsDataMinerParams.checkNode(addedNode);
        });
      });
      // for (i=0; i < mutations.length; i++){
      //     for (j=0; j < mutations[i].addedNodes.length; j++){
      //         crossbeamsDataMinerParams.checkNode(mutations[i].addedNodes[j]);
      //     }
      // }
    });

    observer.observe(document.documentElement, {
      childList: true,
      subtree: true,
    });
  },
};
