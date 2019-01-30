const crossbeamsRmdScan = (function crossbeamsRmdScan() {
  //
  // Variables
  //
  const publicAPIs = {};

  const txtShow = document.getElementById('txtShow');
  const menu = document.getElementById('rmd_menu');
  const logout = document.getElementById('logout');
  const offlineStatus = document.getElementById('rmd-offline-status');
  const scannableInputs = document.querySelectorAll('[data-scanner]');
  const cameraScan = document.getElementById('cameraScan');
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
   * Disable a button and change its caption.
   * @param {element} button the button to disable.
   * @param {string} disabledText the text to use to replace the caption.
   * @returns {void}
   */
  const disableButton = (button, disabledText) => {
    button.dataset.enableWith = button.value;
    button.value = disabledText;
    button.classList.remove('dim');
    button.classList.add('o-50');
  };

  /**
   * Prevent multiple clicks of submit buttons.
   * @returns {void}
   */
  const preventMultipleSubmits = (element) => {
    disableButton(element, element.dataset.disableWith);
    window.setTimeout(() => {
      element.disabled = true;
    }, 0); // Disable the button with a delay so the form still submits...
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
      // Disable a button on click
      if (event.target.dataset && event.target.dataset.disableWith) {
        preventMultipleSubmits(event.target);
      }
    });
    if (cameraScan) {
      cameraScan.addEventListener('click', () => {
        webSocket.send('Type=key248_all');
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
  const unpackScanValue = (val) => {
    const res = { success: false };
    const matches = [];
    let rxp;
    this.rules.filter(r => this.expectedScanTypes.indexOf(r.type) !== -1).forEach((rule) => {
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

    if (webSocket !== undefined && webSocket.readyState !== WebSocket.CLOSED) { return; }
    webSocket = new WebSocket(wsUrl);

    webSocket.onopen = function onopen() {
      publicAPIs.logit('Connected...');
    };

    webSocket.onclose = function onclose() {
      publicAPIs.logit('Connection Closed...');
    };

    webSocket.onerror = function onerror(event) {
      publicAPIs.logit('Connection ERROR', event);
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
          if (e.value === '' && cnt === 0 && e.dataset.scanRule === scanPack.scanType) {
            e.value = scanPack.value;
            const field = document.getElementById(`${e.id}_scan_field`);
            field.value = scanPack.scanField;
            cnt += 1;
          }
        });
      }
      console.info('Raw msg:', event.data);
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
    console.info(...args);
    if (txtShow !== null) {
      txtShow.insertAdjacentHTML('beforeend', `${Array.from(args).map(a => (typeof (a) === 'string' ? a : JSON.stringify(a))).join(' ')}<br>`);
    }
  };

  /**
   * show settings in use for this page.
   */
  publicAPIs.showSettings = () => ({
    expectedScanTypes: this.expectedScanTypes,
    rules: this.rules,
    rulesForThisPage: this.rules.filter(r => this.expectedScanTypes.indexOf(r.type) !== -1),
  });

  /**
   * Init
   * Find the possible scan types in the page.
   * Call setupListeners to set up listeners for the page.
   * Call startScanner to make the websocket connection.
   *
   * @param {object} rules - the rules for identifying scan values.
   */
  publicAPIs.init = (rules) => {
    this.rules = rules;
    this.expectedScanTypes = Array.from(document.querySelectorAll('[data-scan-rule]')).map(a => a.dataset.scanRule);
    this.expectedScanTypes = this.expectedScanTypes.filter((it, i, ar) => ar.indexOf(it) === i);

    setupListeners();

    startScanner();
  };

  //
  // Return the Public APIs
  //
  return publicAPIs;
}());
