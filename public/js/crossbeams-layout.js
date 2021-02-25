/**
 * Build a crossbeamsLayout page.
 * @namespace {function} crossbeamsLayout
 */
(function crossbeamsLayout() {
  /**
   * Disable a button and change its caption.
   * @param {element} button the button to disable.
   * @param {string} disabledText the text to use to replace the caption.
   * @returns {void}
   */
  function disableButton(button, disabledText) {
    button.dataset.enableWith = button.value;
    if (button.value) {
      button.value = disabledText;
    } else {
      button.textContent = disabledText;
    }
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
    if (element.value) {
      element.value = element.dataset.enableWith;
    } else {
      element.textContent = element.dataset.enableWith;
    }
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
   * loadDialogContent - fetches the given url and calls setDialogContent
   *                     to replace the dialog's content area.
   *
   * @param {string} url - the url to call.
   * @returns {void}
   */
  function loadDialogContent(url) {
    fetch(url, {
      method: 'GET',
      credentials: 'same-origin',
      headers: new Headers({
        'X-Custom-Request-Type': 'Fetch',
      }),
    })
    .then(response => response.json())
    .then((data) => {
      if (data.redirect) {
        window.location = data.redirect;
      } else {
        crossbeamsUtils.setDialogContent(data.replaceDialog.content);
      }
    }).catch((data) => {
      crossbeamsUtils.fetchErrorHandler(data);
    });
  }

  function fetchRemoteLink(url) {
    fetch(url, {
      method: 'GET',
      credentials: 'same-origin',
      headers: new Headers({
        'X-Custom-Request-Type': 'Fetch',
      }),
    })
    .then(response => response.json())
    .then((data) => {
      if (data.actions) {
        if (!data.exception && !data.keep_dialog_open) {
          crossbeamsUtils.closePopupDialog();
        }
        crossbeamsUtils.processActions(data.actions);
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
  }

  /**
   * When an input is invalid according to HTML5 rules and
   * the submit button has been disabled, we need to re-enable it
   * so the user can re-submit the form once the error has been
   * corrected.
   */
  document.addEventListener('invalid', (e) => {
    window.setTimeout(() => {
      const sel = '[data-disable-with][disabled], [data-briefly-disable-with][disabled]';
      e.target.form.querySelectorAll(sel).forEach(el => revertDisabledButton(el));
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
      }, false);
    }
    // Initialise any selects to be searchable or multi-selects.
    crossbeamsUtils.makeMultiSelects();
    crossbeamsUtils.makeSearchableSelects();
    crossbeamsUtils.applySelectEvents();

    document.body.addEventListener('keydown', (event) => {
      if (event.target.classList.contains('cbl-to-upper') && event.keyCode === 13) {
        event.target.value = event.target.value.toUpperCase();
      }
      if (event.target.classList.contains('cbl-to-lower') && event.keyCode === 13) {
        event.target.value = event.target.value.toLowerCase();
      }
    }, false);

    // KeyUp - check for observers
    document.body.addEventListener('keyup', (event) => {
      if (event.target.dataset && event.target.dataset.observeKeyup) {
        crossbeamsUtils.observeInputChange(event.target, event.target.dataset.observeKeyup);
      }
    }, false);

    // Repeating request: Check if there are any areas in the content that should be modified by polling...
    const pollsters = document.querySelectorAll('[data-poll-message-url]');
    pollsters.forEach((pollable) => {
      const pollUrl = pollable.dataset.pollMessageUrl;
      const pollInterval = pollable.dataset.pollMessageInterval;
      crossbeamsUtils.pollMessage(pollable, pollUrl, pollInterval);
    });

    // InputChange - check for observers
    document.body.addEventListener('change', (event) => {
      if (event.target.dataset && event.target.dataset.observeInputChange) {
        crossbeamsUtils.observeInputChange(event.target, event.target.dataset.observeInputChange);
      }
      // When the date or time portion of a datetime changes, update its hidden value.
      if (event.target.dataset && event.target.dataset.datetime) {
        const id = event.target.id.replace(/(_date|_time)$/, '');
        const valD = document.getElementById(`${id}_date`).value;
        const valT = document.getElementById(`${id}_time`).value;
        document.getElementById(id).value = `${valD}T${valT}`;
      }
    }, false);

    // Blur (lose focus) - check for observers
    document.body.addEventListener('blur', (event) => {
      if (event.target.dataset && event.target.dataset.observeLoseFocus) {
        crossbeamsUtils.observeInputChange(event.target, event.target.dataset.observeLoseFocus);
      }
    }, true);

    // Display report parameters if applicable.
    document.querySelectorAll('[data-report-param-display]').forEach((el) => {
      const key = el.dataset.reportParamDisplay;
      el.innerHTML = crossbeamsDataMinerParams.loadSelectedParams(key);
    });

    document.body.addEventListener('click', (event) => {
      // Disable a button on click
      if (event.target.dataset && event.target.dataset.disableWith) {
        preventMultipleSubmits(event.target);
      }
      // Briefly disable a button
      if (event.target.dataset && event.target.dataset.brieflyDisableWith) {
        preventMultipleSubmitsBriefly(event.target);
      }
      // Call a URL to remove an item from a List
      if (event.target.closest('[data-remove-item]')) {
        const elem = event.target.closest('li');
        const ol = elem.parentNode;
        const url = ol.dataset.removeItemUrl.replace(/\$:(.*?)\$/g, elem.dataset.itemId);
        event.stopPropagation();
        event.preventDefault();
        fetchRemoteLink(url);
      }
      if (event.target.closest('[data-expand-collapse]')) {
        const elem = event.target.closest('[data-expand-collapse]');
        const open = elem.dataset.expandCollapse === 'open';
        event.stopPropagation();
        event.preventDefault();
        crossbeamsUtils.openOrCloseFolds(elem, open);
      }
      // Open the href in a new window and show a loading animation.
      if (event.target.dataset && event.target.dataset.loadingWindow) {
        event.stopPropagation();
        event.preventDefault();
        crossbeamsUtils.loadingWindow(event.target.href);
      }
      // Perform a lookup function in a dialog.
      if (event.target.dataset && event.target.dataset.lookupName) {
        event.stopPropagation();
        event.preventDefault();
        crossbeamsUtils.showLookupGrid(event.target);
      }
      // Prompt for confirmation
      if (event.target.dataset && event.target.dataset.prompt) {
        event.stopPropagation();
        event.preventDefault();
        crossbeamsUtils.confirm({
          prompt: event.target.dataset.prompt,
          okFunc: () => {
            // console.log('to call HREF', event.target.href); // TODO: is this a fetch/std call?
            // SHOULD actually be a POST, not a GET?
            window.location = event.target.href;
          },
        });
      }
      // Open modal dialog
      if (event.target.dataset && event.target.dataset.popupDialog) {
        if (event.target.dataset.gridId) {
          crossbeamsUtils.recordGridIdForPopup(event.target.dataset.gridId);
        }
        crossbeamsUtils.popupDialog(event.target.text, event.target.href);
        event.stopPropagation();
        event.preventDefault();
      }
      // Replace modal dialog
      if (event.target.dataset && event.target.dataset.replaceDialog) {
        loadDialogContent(event.target.href);
        event.stopPropagation();
        event.preventDefault();
      }
      // Help link - open in new window and set to 2/3 the size of the current window.
      if (event.target.dataset && event.target.dataset.helpLink) {
        const height = parseInt(window.outerHeight * 0.6, 10);
        const width = parseInt(window.outerWidth * 0.6, 10);
        const newWindow = window.open(event.target.href, event.target.target, `resizable,scrollbars,status,height=${height},width=${width}`);
        newWindow.focus();
        event.stopPropagation();
        event.preventDefault();
      }
      // Remote fetch link
      if (event.target.dataset && event.target.dataset.remoteLink) {
        fetchRemoteLink(event.target.href);
        event.stopPropagation();
        event.preventDefault();
      }
      // Show hint dialog
      if (event.target.closest('[data-cb-hint-for]')) {
        const id = event.target.closest('[data-cb-hint-for]').dataset.cbHintFor;
        const el = document.querySelector(`[data-cb-hint='${id}']`);
        if (el) {
          crossbeamsUtils.showHtmlInDialog('Hint', el.innerHTML);
        }
      }
      // Copy to clipboard
      if (event.target.dataset && event.target.dataset.clipboard && event.target.dataset.clipboard === 'copy') {
        const input = document.getElementById(event.target.id.replace('_clip_i', '').replace('_clip', ''));
        input.select();
        try {
          document.execCommand('copy');
          crossbeamsUtils.showInformation('Copied to clipboard');
          window.getSelection().removeAllRanges();
          input.blur();
        } catch (e) {
          crossbeamsUtils.showWarning('Cannot copy, hit Ctrl+C to copy the selected text');
        }
      }
      // Close a modal dialog
      if (event.target.classList.contains('close-dialog')) {
        crossbeamsUtils.closePopupDialog();
        event.stopPropagation();
        event.preventDefault();
      }
    }, false);

    /**
     * Form submit:
     * - Submit the form as a GET request in a "loading" page.
     * - Turn a form into a remote (AJAX) form on submit.
     */
    document.body.addEventListener('submit', (event) => {
      if (event.target.dataset && event.target.dataset.convertToLoading) {
        const searchParams = new URLSearchParams(new FormData(event.target));
        const url = `${event.target.action}?${searchParams.toString()}`;

        crossbeamsUtils.loadingWindow(url);

        event.stopPropagation();
        event.preventDefault();
      } else if (event.target.dataset && event.target.dataset.remote === 'true') {
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
            } else if (data.reloadPreviousDialog) {
              crossbeamsUtils.closePopupDialog();
              closeDialog = false;
              loadDialogContent(data.reloadPreviousDialog);
            } else if (data.loadNewUrl) {
              closeDialog = false;
              loadDialogContent(data.loadNewUrl); // promise...
            } else if (data.updateGridInPlace) {
              data.updateGridInPlace.forEach((gridRow) => {
                crossbeamsGridEvents.updateGridInPlace(gridRow.id, gridRow.changes);
              });
            } else if (data.addRowToGrid) {
              crossbeamsGridEvents.addRowToGrid(data.addRowToGrid.changes);
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
              crossbeamsUtils.applySelectEvents();
              const grids = dlgContent.querySelectorAll('[data-grid]');
              grids.forEach((grid) => {
                const gridId = grid.getAttribute('id');
                const gridEvent = new CustomEvent('gridLoad', { detail: gridId });
                document.dispatchEvent(gridEvent);
              });
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
            if (closeDialog && !data.exception) {
              // Do we need to clear grids etc from memory?
              crossbeamsUtils.closePopupDialog();
            }
          }).catch((data) => {
            crossbeamsUtils.fetchErrorHandler(data);
          });
        event.stopPropagation();
        event.preventDefault();
      }
    }, false);
  }, false);
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
