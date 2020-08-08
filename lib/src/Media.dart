class Media {

  String _file_name;
  String _url;
  String _type;
  String _thumbnail;

  Media(this._file_name, this._url, [this._type, this._thumbnail]);

  String getFileName() {
    return this._file_name;
  }

  String getUrl() {
    return this._url;
  }

  String getType() {
    return this._type;
  }

  String getThumbnail() {
    return this._thumbnail;
  }

  String description() {
    return '\n' +
      '[Media Object] => ' +
      'File Name: ' + this.getFileName() + '\n' +
      'URL: ' + this.getUrl() + '\n' +
      'Type: ' + this.getType() + '\n' +
      'Thumbnail: ' + this.getThumbnail() + '\n';
  }

}