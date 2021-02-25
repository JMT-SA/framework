const crossbeamsRmdScan = (function crossbeamsRmdScan() { // eslint-disable-line no-unused-vars
  //
  // Variables
  //
  const publicAPIs = { bypassRules: false };

  const txtShow = document.getElementById('txtShow');
  const menu = document.getElementById('rmd_menu');
  const logout = document.getElementById('logout');
  const offlineStatus = document.getElementById('rmd-offline-status');
  const scannableInputs = document.querySelectorAll('[data-scanner]');
  const cameraScan = document.getElementById('cameraScan');
  const cameraLight = document.getElementById('cameraLight');
  let cameraLightState = false;
  let webSocket;

  //
  // Methods
  //

  /**
   * Update the UI when the network connection is lost/regained.
   */
  const updateOnlineStatus = () => {
    if (navigator.onLine) {
      offlineStatus.style.display = 'none';
      if (menu) {
        menu.disabled = false;
      }
      logout.classList.remove('disableClick');
      document.querySelectorAll('[data-rmd-btn]').forEach((node) => {
        node.disabled = false;
      });
      publicAPIs.logit('Online: network connection restored');
    } else {
      offlineStatus.style.display = '';
      if (menu) {
        menu.disabled = true;
      }
      logout.classList.add('disableClick');
      document.querySelectorAll('[data-rmd-btn]').forEach((node) => {
        node.disabled = true;
      });
      publicAPIs.logit('Offline: network connection lost');
    }
  };

  /**
   * Get a lookup value to display on the form
   * next to the field that was scanned.
   * @param {element} the element that has just
   * neen scanned.
   * @returns {void}
   */
  const lookupScanField = (element, scanPack) => {
    const url = `/rmd/utilities/lookup/${scanPack.scanType}/${scanPack.scanField}/${element.value}`;
    const label = document.getElementById(`${element.id}_scan_lookup`);
    const hiddenVal = document.getElementById(`${element.id}_scan_lookup_hidden`);
    if (label === null) return null;

    fetch(url, {
      method: 'GET',
      headers: new Headers({
        'X-Custom-Request-Type': 'Fetch',
      }),
      credentials: 'same-origin',
    }).then((response) => {
      if (response.status === 404) {
        label.innerHTML = '<span class="light-red">404</span>';
        console.log('404', url); // eslint-disable-line no-console
        return {};
      }
      return response.json();
    }).then((data) => {
      if (data.flash) {
        if (data.flash.type && data.flash.type === 'permission') {
          label.innerHTML = '<span class="light-red">Permission error</span>';
        } else {
          label.innerHTML = '<span class="light-red">Error</span>';
        }
        if (data.exception) {
          if (data.backtrace) {
            console.groupCollapsed('EXCEPTION:', data.exception, data.flash.error); // eslint-disable-line no-console
            console.info('==Backend Backtrace=='); // eslint-disable-line no-console
            console.info(data.backtrace.join('\n')); // eslint-disable-line no-console
            console.groupEnd(); // eslint-disable-line no-console
          }
        }
      } else {
        label.innerHTML = data.showField;
        hiddenVal.value = data.showField;
      }
    }).catch((data) => {
      console.info('==ERROR==', data); // eslint-disable-line no-console
    });
    return null;
  };

  /**
   * Event listeners for the RMD page.
   */
  const setupListeners = () => {
    window.addEventListener('online', updateOnlineStatus);
    window.addEventListener('offline', updateOnlineStatus);
    if (menu) {
      menu.addEventListener('change', (event) => {
        if (event.target.value !== '') {
          window.location = event.target.value;
        }
      });
    }
    document.body.addEventListener('click', (event) => {
      // On a touch device, try to prevent the form from
      // being submitted after a scan...
      if (event.sourceCapabilities === null) {
        if (event.target.dataset && event.target.dataset.rmdBtn) {
          event.preventDefault();
          return;
        }
      }
      // On reset button clicked, clear all lookup results
      if (event.target.dataset && event.target.dataset.resetRmdForm) {
        event.target.form.querySelectorAll('[data-lookup-result]').forEach((node) => {
          node.innerHTML = node.dataset.resetValue;
        });
        event.target.form.querySelectorAll('[data-lookup-hidden]').forEach((node) => {
          node.value = node.dataset.resetValue === '&nbsp;' ? '' : node.dataset.resetValue;
        });
      }
      // Clear button clicked - clear the input next to it.
      if (event.target.closest('[data-rmd-clear]')) {
        const scanInput = event.target.closest('[data-rmd-clear]');
        const toClear = scanInput.previousElementSibling;
        const id = toClear.id;
        let lkpInput;
        if (toClear) {
          toClear.value = null;
          toClear.readOnly = false;
          lkpInput = document.getElementById(`${id}_scan_lookup`);
          if (lkpInput) {
            lkpInput.innerHTML = '&nbsp;';
          }
          lkpInput = document.getElementById(`${id}_scan_lookup_hidden`);
          if (lkpInput) {
            lkpInput.value = '';
          }
        }
      }
    });

    if (cameraScan) {
      cameraScan.addEventListener('click', () => {
        webSocket.send('Type=key248_all');
      });
    }

    if (cameraLight) {
      cameraLight.addEventListener('click', () => {
        // webSocket.send('Type=key253_flashlight'); // toggle?
        if (cameraLightState) {
          webSocket.send('Type=key253_flashlight_off');
          cameraLightState = false;
        } else {
          webSocket.send('Type=key253_flashlight_on');
          cameraLightState = true;
        }
      });
    }
  };

  /**
   * Apply scan rules to the scanned value
   * to dig out the actual value and type.
   *
   * @param {string} val - the scanned value.
   * @returns {object} success: boolean, value: the value, scanType: the type, error: string.
   */
  const unpackScanValue = (rawVal) => {
    const val = rawVal.split(/\r\n|\r|\n/)[0]; // remove newlines
    const res = { success: false };
    // If we can scan any barcode, return whatever was scanned:
    if (publicAPIs.bypassRules) {
      res.success = true;
      res.value = val;
      res.scanType = 'any';
      res.scanField = 'any';
      return res;
    }
    const matches = [];
    let rxp;
    publicAPIs.rules.filter(r => publicAPIs.expectedScanTypes.indexOf(r.type) !== -1)
      .forEach((rule) => {
        rxp = RegExp(rule.regex);
        if (rxp.test(val)) {
          matches.push(rule.type);
          res.value = RegExp.lastParen;
          res.scanType = rule.type;
          res.scanField = rule.field;
        }
      });
    if (matches.length !== 1) {
      res.error = matches.length === 0 ? `${val} does not match any scannable rules` : 'Too many rules match';
    } else {
      res.success = true;
    }
    return res;
  };

  /**
   * startScanner - set up the websocket connection and its callbacks.
   */
  const startScanner = () => {
    const wsUrl = 'ws://127.0.0.1:2115';
    // const wsUrl = 'ws://192.168.50.10:2115';
    let connectedState = false;

    if (webSocket !== undefined && webSocket.readyState !== WebSocket.CLOSED) { return; }
    webSocket = new WebSocket(wsUrl);

    webSocket.onopen = function onopen() {
      connectedState = true;
      publicAPIs.logit('Connected...');
    };

    webSocket.onclose = function onclose() {
      connectedState = false;
      publicAPIs.logit('Connection Closed...');
      // delay for a second and try again...
      setTimeout(startScanner, 1000);
    };

    webSocket.onerror = function onerror(event) {
      if (connectedState) { // Ignore websocket errors if we are not connected.
        publicAPIs.logit('Connection ERROR', event);
      }
    };

    webSocket.onmessage = function onmessage(event) {
      if (event.data.includes('[SCAN]')) {
        const scanPack = unpackScanValue(event.data.split(',')[0].replace('[SCAN]', ''));
        if (!scanPack.success) {
          publicAPIs.logit(scanPack.error);
          return;
        }
        let cnt = 0;
        scannableInputs.forEach((e) => {
          if (e.value === '' && cnt === 0 && (publicAPIs.bypassRules || e.dataset.scanRule === scanPack.scanType)) {
            e.value = scanPack.value;
            const evt = new Event('change', {
              bubbles: true,
            });
            e.dispatchEvent(evt);

            e.readOnly = true;
            const field = document.getElementById(`${e.id}_scan_field`);
            if (field) {
              field.value = scanPack.scanField;
            }
            if (e.dataset.lookup) {
              lookupScanField(e, scanPack);
            }
            cnt += 1;
            if (e.dataset.submitForm) {
              e.form.submit();
            }
          }
        });
      }
      console.info('Raw msg:', event.data); // eslint-disable-line no-console
    };
  };

  //
  // PUBLIC Methods
  //

  /**
   * Log to screen and console.
   *
   * @param {Array} args.
   */
  publicAPIs.logit = (...args) => {
    console.info(...args); // eslint-disable-line no-console
    if (txtShow !== null) {
      txtShow.insertAdjacentHTML('beforeend', `${Array.from(args).map(a => (typeof (a) === 'string' ? a : JSON.stringify(a))).join(' ')}<br>`);
    }
  };

  /**
   * show settings in use for this page.
   */
  publicAPIs.showSettings = () => ({
    expectedScanTypes: publicAPIs.expectedScanTypes,
    rules: publicAPIs.rules,
    rulesForThisPage:
      publicAPIs.rules.filter(r => publicAPIs.expectedScanTypes.indexOf(r.type) !== -1),
  });

  /**
   * Init
   * Find the possible scan types in the page.
   * Call setupListeners to set up listeners for the page.
   * Call startScanner to make the websocket connection.
   *
   * @param {object} rules - the rules for identifying scan values.
   * @param {boolean} bypassRules - should the rules be ignored (scan any barcode).
   */
  publicAPIs.init = (rules, bypassRules) => {
    publicAPIs.rules = rules;
    publicAPIs.bypassRules = bypassRules;
    publicAPIs.expectedScanTypes = Array.from(document.querySelectorAll('[data-scan-rule]')).map(a => a.dataset.scanRule);
    publicAPIs.expectedScanTypes =
      publicAPIs.expectedScanTypes.filter((it, i, ar) => ar.indexOf(it) === i);

    setupListeners();

    startScanner();
  };

  //
  // Return the Public APIs
  //
  return publicAPIs;
}());
