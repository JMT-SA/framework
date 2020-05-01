class HttpError extends Error { // eslint-disable-line no-unused-vars
  constructor(response) {
    super(`${response.status} for ${response.url}`);
    this.name = 'HttpError';
    this.response = response;
  }
}
