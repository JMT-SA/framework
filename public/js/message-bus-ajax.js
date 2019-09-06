// A bare-bones implementation of $.ajax that MessageBus will use
// as a fallback if jQuery is not present
//
// Only implements methods & options used by MessageBus
(function (global, undefined) {
  if (!global.MessageBus) {
    throw new Error('MessageBus must be loaded before the ajax adapter');
  }

  let cacheBuster = Math.random() * 10000 | 0;

  global.MessageBus.ajax = function mbAjax(options) {
    const XHRImpl = (global.MessageBus && global.MessageBus.xhrImplementation) || global.XMLHttpRequest;
    const xhr = new XHRImpl();
    xhr.dataType = options.dataType;
    let url = options.url;
    if (!options.cache) {
      url += `${(url.indexOf('?') == -1) ? '?' : '&'}_=${cacheBuster++}`;
    }
    xhr.open('POST', url);
    for (const name in options.headers) {
      xhr.setRequestHeader(name, options.headers[name]);
    }
    // :header => 'X-CSRF-Token'.
    xhr.setRequestHeader('X-CSRF-Token', document.querySelector('meta[name="_csrf"]').content);
    xhr.setRequestHeader('Content-Type', 'application/json');
    if (options.messageBus.chunked) {
      options.messageBus.onProgressListener(xhr);
    }
    xhr.onreadystatechange = function () {
      if (xhr.readyState === 4) {
        const status = xhr.status;
        if (status >= 200 && status < 300 || status === 304) {
          options.success(xhr.responseText);
        } else {
          options.error(xhr, xhr.statusText);
        }
        options.complete();
      }
    };
    // form.append('_csrf', 

    xhr.send(JSON.stringify(options.data));
    return xhr;
  };
}(window));
