module.exports = {
  extends: 'airbnb-base',
  plugins: [
    'import',
  ],
  parserOptions: {
    sourceType: 'script',
    ecmaFeatures: {
      impliedStrict: true,
    },
  },
  rules: {
    'no-param-reassign': ['error', { props: false }],
    'arrow-parens': [2, 'as-needed', { requireForBlockBody: true }],
    'prefer-destructuring': 0,
    'max-len': ['error', { code: 150 }],
  },
  env: {
    browser: true,
    jquery: true,
  },
  globals: {
    _: false,
    swal: false,
    agGrid: false,
    Jackbox: false,
    Choices: false,
    Selectr: false,
    Sortable: false,
    multi: false,
    HttpError: false,
    crossbeamsRmdScan: false,
    crossbeamsDialogLevel1: false,
    crossbeamsDialogLevel2: false,
    crossbeamsGridStore: false,
    crossbeamsUtils: false,
    crossbeamsDataMinerParams: false,
    crossbeamsLocalStorage: false,
    crossbeamsGridEvents: false,
  },
};
