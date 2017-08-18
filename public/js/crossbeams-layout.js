// for equiv of $ready() -- place this code at end of <body> or use:
// document.addEventListener('DOMContentLoaded', fn, false);
/**
 * Build a crossbeamsLayout page.
 * @namespace {function} crossbeamsLayout
 */
(function crossbeamsLayout() {
  /**
   * Load a page section using a callback url.
   * @param {element} elem - The section element in the DOM.
   * @returns {void}
   */
  function loadSection(elem) {
    const xhr = new XMLHttpRequest();
    const url = elem.dataset.crossbeams_callback_section;
    const contentDiv = elem.querySelectorAll('.content-target')[0];

    xhr.onreadystatechange = () => {
      if (xhr.readyState === 4 && xhr.status === 200) {
        contentDiv.classList.remove('content-loading');
        contentDiv.innerHTML = xhr.responseText;
      }
    };
    xhr.open('GET', url, true); // true for asynchronous
    xhr.send(null);
  }
  const elements = document.querySelectorAll('section');
  elements.forEach((element) => {
    if (element.dataset.crossbeams_callback_section !== undefined) {
      loadSection(element);
    }
  });

  function disableButton(button, disabledText) {
    button.dataset.enableWith = button.value;
    button.value = disabledText;
    button.classList.remove('dim');
    button.classList.add('o-50');
  }

  /**
   * Prevent multiple clicks of submit buttons.
   * @returns {void}
   */
  function preventMultipleSubmits(element) {
    disableButton(element, element.dataset.disableWith);
    window.setTimeout(() => {
      element.disabled = true;
    }, 0); // Disable the button with a delay so the form still submits...
  }

  /**
   * Remove disabled state from a button.
   * @param {element} element the button to re-enable.
   * @returns {void}
   */
  function revertDisabledButton(element) {
    element.disabled = false;
    element.value = element.dataset.enableWith;
    element.classList.add('dim');
    element.classList.remove('o-50');
  }

  /**
   * Prevent multiple clicks of submit buttons.
   * Re-enables the button after a delay of one second.
   * @returns {void}
   */
  function preventMultipleSubmitsBriefly(element) {
    disableButton(element, element.dataset.brieflyDisableWith);
    window.setTimeout(() => {
      element.disabled = true;
      window.setTimeout(() => {
        revertDisabledButton(element);
      }, 1000); // Re-enable the button with a delay.
    }, 0); // Disable the button with a delay so the form still submits...
  }

  /**
   * When an input is invalid according to HTML5 rules and
   * the submit button has been disabled, we need to re-enable it
   * so the user can re-submit the form once the error has been
   * corrected.
   */
  document.addEventListener('invalid', function(e){
    window.setTimeout(() => {
      e.target.form.querySelectorAll('[disabled]').forEach( (el) => revertDisabledButton(el) );
    }, 0); // Disable the button with a delay so the form still submits...
  }, true);

  /**
   * Assign a click handler to buttons that need to be disabled.
   */
  document.addEventListener('DOMContentLoaded', () => {
    document.body.addEventListener('click', (event) => {
      if (event.target.dataset.disableWith) {
        preventMultipleSubmits(event.target);
      }
      if (event.target.dataset.brieflyDisableWith) {
        preventMultipleSubmitsBriefly(event.target);
      }
      if (event.target.classList.contains('close-dialog')) {
         crossbeamsUtils.closeJmtDialog();
      }
    });

    /**
     * Turn a form into a remote (AJAX) form on submit.
     */
    document.body.addEventListener('submit', function(event) {
      if (event.target.dataset.remote === 'true') {
        fetch(event.target.action, {
          method: 'POST', // GET?
          credentials: 'same-origin',
          body: new FormData(event.target),
        }).then(function(response) {
          return response.json();
        }).then(function(data) {
          let closeDialog = true;
          if (data.redirect) {
            window.location = data.redirect;
          } else if (data.updateGridInPlace) {
            const gridId = crossbeamsLocalStorage.getItem('popupOnGrid');
            // TODO: move to own function..
            const gridOptions = crossbeamsGridStore.getGrid(gridId);
            let rowNode = gridOptions.api.getRowNode(data.updateGridInPlace.id);
            for (const k in data.updateGridInPlace.changes) {
                rowNode.setDataValue(k, data.updateGridInPlace.changes[k]);
            };
          } else if (data.replaceDialog) {
            closeDialog = false;
            $('#dialog-modal').html(data.replaceDialog.content);
          } else {
            console.log('Not sure what to do with this:', data);
          }
          // Only if not redirect...
          if (data.flash) {
            if (data.flash.notice) {
              Jackbox.success(data.flash.notice);
            }
            if (data.flash.error) {
              if (data.exception) {
                Jackbox.error(data.flash.error, { time: 20 });
              } else {
                Jackbox.error(data.flash.error);
              }
            }
          }
          if (closeDialog && !data.exception) {
            crossbeamsUtils.closeJmtDialog();
          }
        }).catch(function(data) {
            Jackbox.error(`An error occurred ${data}`, { time: 20 });
        });
      event.stopPropagation();
      event.preventDefault();
      }
    });
  });
}());
// CODE FROM HERE...
// This is an alternative way of loading sections...
// (js can be in head of page)
// ====================================================
// checkNode = function(addedNode) {
//   if (addedNode.nodeType === 1){
//     if (addedNode.matches('section[data-crossbeams_callback_section]')){
//      load_section(addedNode);
//       //SmartUnderline.init(addedNode);
//     }
//   }
// }
// var observer = new MutationObserver(function(mutations){
//   for (var i=0; i < mutations.length; i++){
//     for (var j=0; j < mutations[i].addedNodes.length; j++){
//       checkNode(mutations[i].addedNodes[j]);
//     }
//   }
// });
//
// observer.observe(document.documentElement, {
//   childList: true,
//   subtree: true
// });
// ====================================================
// ...TO HERE.
