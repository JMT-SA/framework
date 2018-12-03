function logit(...args) {
  console.log(...args);
  const txt = document.getElementById('txtShow');
  txt.value += `${Array.from(args).map(a => JSON.stringify(a)).join(' ')}\n`;
}

const txt = document.getElementById('txtShow');
txt.value += '---start---\n';
const scanTarget = document.getElementById('scanTarget');
const scanResults = document.getElementById('scanResults');
const txtResults = document.getElementById('txtResults');

let webSocket;

const startScanner = function startScanner() {
  const wsUrl = 'ws://127.0.0.1:2115';

  if (webSocket !== undefined && webSocket.readyState !== WebSocket.CLOSED) { return; }
  webSocket = new WebSocket(wsUrl);

  webSocket.onopen = function onopen() {
    logit('Connected...');
    // webSocket.send(`Type=${scanTarget.dataset.scanner}`);
  };

  webSocket.onclose = function onclose() {
    logit('Connection Closed...');
  };

  webSocket.onerror = function onerror(event) {
    logit('Connection ERROR', event);
  };

  // Kbd fills in value (possibly with RETURN) without coming back here...
  webSocket.onmessage = function onmessage(event) {
    // logit('ON msg', event);
    if (event.data.includes('Scans=')) {
      logit('scan', event.data, 'END');
      // scanTarget.value = event.data;
    } else if (event.data.includes('Flashlight=')) {
      logit('flash', event.data, 'END');
      // scanTarget.value = event.data;
    } else {
      if (event.data.includes('[SCAN]')) {
        const scanValue = event.data.split(',')[0].replace('[SCAN]', '');
        scanTarget.value = scanValue;
        // scanResults.add_li;
        const li = document.createElement('li');
        li.textContent = scanValue;
        scanResults.append(li);
        txtResults.value += `${scanValue}\n`;
      }
      logit(event.data);
    }
    // webSocket.close();
  };
};

document.addEventListener('click', (event) => {
  if (event.target.id === 'open') {
    startScanner(event.target);
  // } else if (event.target.id === 'type') {
  //   const s = `Type=${typeList.value}`;
  //   logit('Sending', s);
  //   webSocket.send(s);
  } else if (event.target.id === 'close') {
    webSocket.close();
  }
});

startScanner();
