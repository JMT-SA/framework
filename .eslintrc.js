module.exports = {
  "extends": "airbnb-base",
  "plugins": [
    "import"
  ],
  "parserOptions": {
    "sourceType": 'script',
    "ecmaFeatures": {
      "impliedStrict": true
    }
  },
  "rules": {
    "no-param-reassign": [ "error", { "props": false } ]
  },
  "env": {
    "browser": true,
    "jquery": true,
  },
  "globals": {
    "_": false,
    "swal": false,
    "agGrid": false,
    "crossbeamsUtils": false,
    "crossbeamsLocalStorage": false
  }
};
