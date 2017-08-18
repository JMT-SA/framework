/* exported crossbeamsLocalStorage */

/**
 * Wrapper around browser storage (auto JSON stringify & parse).
 * Items are accessed using a key. The value is stored as a string,
 * but arrays and objects are stored as stringified JSON and when retrieved
 * are returned as objects/arrays.
 * @example <caption>Store a value</caption>
 * const key = crossbeamsLocalStorage.genStandardKey('v1');
 * crossbeamsLocalStorage.setItem(key, {abc: 1, def: 2});
 * @example <caption>Retrieve a value</caption>
 * if (crossbeamsLocalStorage.hasItem(key)) {
 *   stored = crossbeamsLocalStorage.getItem(key);
 * }
 * @namespace
 */
const crossbeamsLocalStorage = {
  // storageAdaptor: sessionStorage,
  storageAdaptor: localStorage,

  // Thanks Angus! - http://goo.gl/GtvsU
  toType: function toType(obj) {
    return ({}).toString.call(obj).match(/\s([a-z|A-Z]+)/)[1].toLowerCase();
  },

  /**
   * Check if local storage has an item referenced by the given key.
   * @param {string} key - the item's key.
   * @return {boolean} - true if there is an item in storage with this key.
   */
  hasItem: function hasItem(key) {
    return this.storageAdaptor.getItem(key) !== null;
  },

  /**
   * Retrieve an item from local storage.
   * @param {string} key - the item's key.
   * @return {JSON} - the item's value.
   */
  getItem: function getItem(key) {
    let item = this.storageAdaptor.getItem(key);

    try {
      item = JSON.parse(item);
    } catch (e) {
      // Ignore
    }

    return item;
  },

  /**
   * Stores an item in local storage.
   * If the item is an array or object, it is stored as stringified JSON.
   * @param {string} key - the item's key.
   * @param {any} inValue - the value to be stored.
   * @return {void}
   */
  setItem: function setItem(key, inValue) {
    let value = inValue;
    const type = this.toType(value);

    if (/object|array/.test(type)) {
      value = JSON.stringify(value);
    }

    this.storageAdaptor.setItem(key, value);
  },

  /**
   * Remove an item from local storage.
   * @param {string} key - the item's key.
   * @return {void}
   */
  removeItem: function removeItem(key) {
    this.storageAdaptor.removeItem(key);
  },

  /**
   * Create a standardised key using the current page's URL.
   * The URL is used with trailing digits removed.
   * A suffix can optionally by appended to make the key more specific.
   * @param {string} [suffix] - an optional string to be appended to the key
   * @return {string} - the key.
   */
  genStandardKey: function genStandardKey(suffix) {
    const rx = new RegExp('/\\d+$');
    if (suffix === undefined) {
      return window.location.pathname.replace(rx, '');
    }
    return `${window.location.pathname.replace(rx, '')}|${suffix}`;
  },
};
