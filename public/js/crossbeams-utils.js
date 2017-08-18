/* exported crossbeamsUtils */

/**
 * General utility functions for Crossbeams.
 * @namespace
 */
const crossbeamsUtils = {

  // On success of AJAX call, load results into dialog.
  dialogLoadSuccessHandler: function dialogLoadSuccessHandler(data, textStatus, jqXHR) {
    $('#dialog-modal').html(data);
  },
  // // On failure of AJAX call, show an alert.
  // function errorHandler(jqXHR, textStatus, errorThrown) {
  //   alert("Something went wrong: " + textStatus + ": " + errorThrown);
  // }

  // Popup a JQ UI dialog.
  jmtPopupDialog: function jmtPopupDialog(new_width, new_height, title, text, href) {
    // if (new_width) {$('#dialog-modal').dialog('option', 'width', new_width);}
    // if (new_height) {$('#dialog-modal').dialog('option', 'height', new_height);}
    // $('#dialog-modal').html('');
    // $('#dialog-modal').dialog('option', 'title', title || text);
    // $('#dialog-modal').dialog('open');
    if ($("#dialog-modal").PopupWindow("getState")) $("#dialog-modal").PopupWindow("destroy");
    $('#dialog-modal').PopupWindow({
          title       : title,
          modal       : true,
          statusBar   : false,
          height      : 300,
          width       : 400,
          buttons     : {minimize: false },
          // top         : 100,
          // left        : 300
    });
    $.ajax({
      type: 'get',
      url: href,
      //          dataType: "script",
      success: crossbeamsUtils.dialogLoadSuccessHandler//,
      //error: errorHandler
    });
  },

  closeJmtDialog: function closeJmtDialog() {
    $("#dialog-modal").PopupWindow("close").html('');
  },
  /**
   * Toggle the visibility of en element in the DOM:
   * @param {string} id - the id of the DOM element.
   * @param {elelment} [button] - optional. Button to add the pure-button-active class (Pure.css)
   * @returns {void}
   */
  toggleVisibility: function toggleVisibility(id, button) {
    const e = document.getElementById(id);

    if (e.style.display === 'block') {
      e.style.display = 'none';
      if (button !== undefined) {
        button.classList.remove('pure-button-active');
      }
    } else {
      e.style.display = 'block';
      if (button !== undefined) {
        button.classList.add('pure-button-active');
      }
    }
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
   * @returns {string} - the select tag code.
   */
  makeSelect: function makeSelect(name, arr) {
    // var sel = '<select id="' + name + '" name="' + name + '">';
    let sel = `<select id="${name}" name="${name}">`;
    arr.forEach((item) => {
      if (item.constructor === Array) {
        // sel += '<option value="' + (item[1] || item[0]) + '">' + item[0] + '</option>';
        sel += `<option value="${(item[1] || item[0])}">${item[0]}</option>`;
      } else {
        // sel += '<option value="' + item + '">' + item + '</option>';
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
  makeListSortable: function makeListSortable(prefix) {
    const el = document.getElementById(`${prefix}-sortable-items`);
    const sorted_ids = document.getElementById(`${prefix}-sorted_ids`);
    const sortable = Sortable.create(el, {
      animation: 150,
      handle: ".crossbeams-drag-handle",
      ghostClass: "crossbeams-sortable-ghost",  // Class name for the drop placeholder
      dragClass: "crossbeams-sortable-drag",  // Class name for the dragging item
      onEnd: function (/**Event*/evt) {
        let id_list = [];
        for(child of el.children) { id_list.push(child.id.replace('si_', '')); } // strip si_ part...
        sorted_ids.value = id_list.join(',');
      },
    });
  },

};

