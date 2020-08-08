class DownloaderResponse {

  bool _error;
  dynamic _content;

  DownloaderResponse(this._error, this._content);

  bool hasError() {
    return this._error;
  }

  dynamic getContent() {
    return this._content;
  }

}