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
  // publicAPIs.rules = {};
  // let expectedScanTypes;
  // let rules;

  //
  // Methods
  //

  /**
   * Update the UI when the network connection is lost/regained.
   */
  const updateOnlineStatus = () => {
    if (navigator.onLine) {
      offlineStatus.style.display = 'none';
      menu.disabled = false;
      logout.classList.remove('disableClick');
      document.querySelectorAll('[data-rmd-btn]').forEach((node) => {
        node.disabled = false;
      });
      publicAPIs.logit('Online: network connection restored');
    } else {
      offlineStatus.style.display = '';
      menu.disabled = true;
      logout.classList.add('disableClick');
      document.querySelectorAll('[data-rmd-btn]').forEach((node) => {
        node.disabled = true;
      });
      publicAPIs.logit('Offline: network connection lost');
    }
  };

  const setupListeners = () => {
    window.addEventListener('online', updateOnlineStatus);
    window.addEventListener('offline', updateOnlineStatus);
    menu.addEventListener('change', (event) => {
      if (event.target.value !== '') {
        window.location = event.target.value;
      }
    });
    if (cameraScan) {
      cameraScan.addEventListener('click', () => {
        webSocket.send('Type=key248_all');
      });
    }
  };

  const startScanner = function startScanner() {
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
      if (event.data.includes('Scans=')) {
        publicAPIs.logit('scan', event.data, 'END');
      } else if (event.data.includes('Flashlight=')) {
        publicAPIs.logit('flash', event.data, 'END');
      } else {
        if (event.data.includes('[SCAN]')) {
          const scanValue = event.data.split(',')[0].replace('[SCAN]', '');
          // const scanPack = unpackScanValue(event.data.split(',')[0].replace('[SCAN]', ''));
          // if scanPAck.error, publicAPIs.logit(scanPack.error)
          // else... alloc according to type
          // List of scan targets
          // check each to see if empty & if data-scan-rule matches value,
          // place in available slot - OR show message (locked until button pressed...)
          // scanTarget.value = scanValue;
          let cnt = 0;
          scannableInputs.forEach((e) => {
            if (e.value === '' && cnt === 0) {
              e.value = scanValue;
              cnt += 1;
            }
          });
        }
        publicAPIs.logit(event.data);
      }
    };
  };

  /**
   * A public method
   */
  publicAPIs.logit = (...args) => {
    console.info(...args);
    if (txtShow !== null) {
      txtShow.value += `${Array.from(args).map(a => (typeof (a) === 'string' ? a : JSON.stringify(a))).join(' ')}\n`;
    }
  };

  publicAPIs.showme = () => this.rules;

  /**
   * Another public method
   */
  publicAPIs.init = (options) => {
    // TODO: get expected scan types, set up rules, interpret scans...
    // & decide where scanned value goes.
    console.log(options);
    this.rules = options.rules;
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
