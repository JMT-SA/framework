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

  class HttpError extends Error {
    constructor(response) {
      super(`${response.status} for ${response.url}`);
      this.name = 'HttpError';
      this.response = response;
    }
  }

  function loadDialogContent(url) {
    fetch(url, {
      method: 'GET',
      credentials: 'same-origin',
      headers: new Headers({
        'X-Custom-Request-Type': 'Fetch',
      }),
      // body: new FormData(event.target),
    })
    .then(response => response.text())
    .then((data) => {
      const dlgContent = document.getElementById(crossbeamsUtils.activeDialogContent());
      dlgContent.innerHTML = data;
      crossbeamsUtils.makeMultiSelects();
      crossbeamsUtils.makeSearchableSelects();
      const grids = dlgContent.querySelectorAll('[data-grid]');
      grids.forEach((grid) => {
        const gridId = grid.getAttribute('id');
        const gridEvent = new CustomEvent('gridLoad', { detail: gridId });
        document.dispatchEvent(gridEvent);
      });
    }).catch((data) => {
      Jackbox.error('The action was unsuccessful...');
      const htmlText = data.responseText ? data.responseText : '';
      document.getElementById(crossbeamsUtils.activeDialogContent()).innerHTML = htmlText;
    });
  }

  /**
   * When an input is invalid according to HTML5 rules and
   * the submit button has been disabled, we need to re-enable it
   * so the user can re-submit the form once the error has been
   * corrected.
   */
  document.addEventListener('invalid', (e) => {
    window.setTimeout(() => {
      e.target.form.querySelectorAll('[disabled]').forEach(el => revertDisabledButton(el));
    }, 0); // Disable the button with a delay so the form still submits...
  }, true);

  /**
   * Assign a click handler to buttons that need to be disabled.
   */
  document.addEventListener('DOMContentLoaded', () => {
    const logoutLink = document.querySelector('#logout');
    if (logoutLink) {
      logoutLink.addEventListener('click', () => {
        crossbeamsLocalStorage.removeItem('selectedFuncMenu');
      });
    }
    // Initialise any selects to be searchable or multi-selects.
    crossbeamsUtils.makeMultiSelects();
    crossbeamsUtils.makeSearchableSelects();

    document.body.addEventListener('click', (event) => {
      if (event.target.dataset && event.target.dataset.disableWith) {
        preventMultipleSubmits(event.target);
      }
      if (event.target.dataset && event.target.dataset.brieflyDisableWith) {
        preventMultipleSubmitsBriefly(event.target);
      }
      if (event.target.dataset && event.target.dataset.popupDialog) {
        crossbeamsUtils.popupDialog(event.target.text, event.target.href);
        event.stopPropagation();
        event.preventDefault();
      }
      if (event.target.dataset && event.target.dataset.cbHintFor) {
        const id = event.target.dataset.cbHintFor;
        const el = document.querySelector(`[data-cb-hint='${id}']`);
        if (el) {
          crossbeamsUtils.showHtmlInDialog('Hint', el.innerHTML);
        }
      }
      if (event.target.classList.contains('close-dialog')) {
        crossbeamsUtils.closePopupDialog();
        event.stopPropagation();
        event.preventDefault();
      }
    });

    /**
     * Turn a form into a remote (AJAX) form on submit.
     */
    document.body.addEventListener('submit', (event) => {
      if (event.target.dataset && event.target.dataset.remote === 'true') {
        fetch(event.target.action, {
          method: 'POST', // GET?
          credentials: 'same-origin',
          headers: new Headers({
            'X-Custom-Request-Type': 'Fetch',
          }),
          body: new FormData(event.target),
        })
        .then((response) => {
          if (response.status === 200) {
            return response.json();
          }
          throw new HttpError(response);
        })
          .then((data) => {
            let closeDialog = true;
            if (data.redirect) {
              window.location = data.redirect;
            } else if (data.loadNewUrl) {
              closeDialog = false;
              loadDialogContent(data.loadNewUrl); // promise...
            } else if (data.updateGridInPlace) {
              crossbeamsGridEvents.updateGridInPlace(data.updateGridInPlace.id,
                                     data.updateGridInPlace.changes);
            } else if (data.replaceDialog) {
              closeDialog = false;
              const dlgContent = document.getElementById(crossbeamsUtils.activeDialogContent());
              dlgContent.innerHTML = data.replaceDialog.content;
              crossbeamsUtils.makeMultiSelects();
              crossbeamsUtils.makeSearchableSelects();
              const grids = dlgContent.querySelectorAll('[data-grid]');
              grids.forEach((grid) => {
                const gridId = grid.getAttribute('id');
                const gridEvent = new CustomEvent('gridLoad', { detail: gridId });
                document.dispatchEvent(gridEvent);
              });
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
                  if (data.backtrace) {
                    console.log('==Backend Backtrace==');
                    console.info(data.backtrace.join('\n'));
                  }
                } else {
                  Jackbox.error(data.flash.error);
                }
              }
            }
            if (closeDialog && !data.exception) {
              // Do we need to clear grids etc from memory?
              crossbeamsUtils.closePopupDialog();
            }
          }).catch((data) => {
            if (data.response.status === 500) {
              data.response.text().then((body) => {
                document.getElementById(crossbeamsUtils.activeDialogContent()).innerHTML = body;
              });
            }
            Jackbox.error(`An error occurred ${data}`, { time: 20 });
          });
        event.stopPropagation();
        event.preventDefault();
      }
    });
  });
}());

// function testEvt(gridId) {
//   console.log('got grid', gridId, self);
// }
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
