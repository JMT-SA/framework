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
    "Jackbox": false,
    "Selectr": false,
    "Sortable": false,
    "multi": false,
    "crossbeamsRmdScan": false,
    "crossbeamsDialogLevel1": false,
    "crossbeamsDialogLevel2": false,
    "crossbeamsGridStore": false,
    "crossbeamsUtils": false,
    "crossbeamsDataMinerParams": false,
    "crossbeamsLocalStorage": false,
    "crossbeamsGridEvents": false
  }
};
