function logit(...args) {
  console.info(...args);
  const txt = document.getElementById('txtShow');
  if (txt !== null) {
    txt.value += `${Array.from(args).map(a => JSON.stringify(a)).join(' ')}\n`;
  }
}

const txt = document.getElementById('txtShow');
if (txt !== null) {
  txt.value += '---start---\n';
}
const scannableInputs = document.querySelectorAll('[data-scanner]');

let webSocket;

const startScanner = function startScanner() {
  const wsUrl = 'ws://127.0.0.1:2115';

  if (webSocket !== undefined && webSocket.readyState !== WebSocket.CLOSED) { return; }
  webSocket = new WebSocket(wsUrl);

  webSocket.onopen = function onopen() {
    logit('Connected...');
  };

  webSocket.onclose = function onclose() {
    logit('Connection Closed...');
  };

  webSocket.onerror = function onerror() {
    logit('Connection ERROR', event);
  };

  webSocket.onmessage = function onmessage(event) {
    if (event.data.includes('Scans=')) {
      logit('scan', event.data, 'END');
    } else if (event.data.includes('Flashlight=')) {
      logit('flash', event.data, 'END');
    } else {
      if (event.data.includes('[SCAN]')) {
        const scanValue = event.data.split(',')[0].replace('[SCAN]', '');
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
      logit(event.data);
    }
  };
};

// For camera scans from a buton...
// document.addEventListener('click', (event) => {
//   if (event.target.id === 'open') {
//     startScanner(event.target);
//   // } else if (event.target.id === 'type') {
//   //   const s = `Type=${typeList.value}`;
//   //   logit('Sending', s);
//   //   webSocket.send(s);
//   } else if (event.target.id === 'close') {
//     webSocket.close();
//   }
// });

startScanner();

document.addEventListener('DOMContentLoaded', () => {
  const selMenu = document.getElementById('rmd_menu');
  selMenu.addEventListener('change', (event) => {
    // console.log('menu', event.target.value);
    if (event.target.value !== '') {
      window.location = event.target.value;
    }
  });
});
