import 'DownloaderResponse.dart';
import 'Media.dart';
import 'package:dio/dio.dart';

class Downloader {

  Dio _http;

  Downloader() {
    this._http = new Dio();
  }

  Future<DownloaderResponse> getMediaList(String url) async {

    if(!this.validUrl(url)) {
      return DownloaderResponse(true, 'Invalid URL');
    }

    Response response;
    try {
      response = await this._http.get(url);
    }
    on DioError catch(e) {
      return new DownloaderResponse(true, "Invalid URL");
    }

    //return this.parseResponse(response.data);

  }

  /*DownloaderResponse parseResponse(String response) {

    RegExp regex = new RegExp('"display_url":"(.*?)"|"video_url":"(.*?)"');
    List<int> thumbnail_indexes = new List();
    if(regex.hasMatch(response)) {
      var matches = regex.allMatches(response);
      List<Media> media = new List();
      for(int i = 0; i < matches.length; i++) {
        Map<String,dynamic> item = this._getItemMap(matches.elementAt(i));
        String url, type, thumbnail;
        if(item.containsKey('display_url')) {
          url = item['display_url'];
          type = 'image';
          thumbnail = url;
        }
        else if(item.containsKey('video_url')) {
          url = item['video_url'];
          type = 'video';
          thumbnail = this._getItemMap(matches.elementAt(i - 1))['display_url'];
          thumbnail_indexes.add(i - 1);
        }
        String file_name = this._getFileName(url);
        if(file_name == null) {
          return new DownloaderResponse(true, 'Couldn\'t get file name and format');
        }
        media.add(new Media(file_name, url, type, thumbnail));
      }
      media = this._filter(media, thumbnail_indexes);
      return new DownloaderResponse(false, media);
    }
    return new DownloaderResponse(true, "Couldn't get media");

  }*/

  /*Map<String, dynamic> _getItemMap(RegExpMatch match) {
    return json.decode('{' + match.group(0).toString() + '}');
  }*/

  /*List<Media> _filter(List<Media> media, List<int> thumbnail_indexes) {

    List<Media> filtered_list = new List();
    for(Media item in media) {
      if(!isListed(filtered_list, item.getFileName())) {
        filtered_list.add(item);
      }
    }

    return filtered_list;

  }*/

  /*bool isListed(List<Media> filtered_list, String file_name) {
    for(Media media in filtered_list) {
      if(media.getFileName() == file_name) {
        return true;
      }
    }
    return false;
  }*/

  /*Future<String> getPath() async {
    PermissionStatus storagePermissionStatus = await Permission.storage.status;

    if(storagePermissionStatus.isPermanentlyDenied) {
      return await getExternalStorageDirectory().then((directory) => directory.path);
    }
    else if(storagePermissionStatus.isGranted) {
      return "/storage/emulated/0/Download";
    }
    else {
      Permission.storage.request();
      return this.getPath();
    }

  }*/

  /*Future<DownloaderResponse> downloadAll(List<Media> media, DownloadController downloadController) async {

    for(Media item in media) {
      DownloaderResponse response = await download(item.getFileName(), item.getUrl(), downloadController);
      if(response.hasError()) {
        return response;
      }
    }

    return new DownloaderResponse(false, "All downloads completed");

  }*/

  /*Future<DownloaderResponse> download(String file_name, String url, DownloadController downloadController) async {
    print("DOWNLOADING " + file_name);
    String path = await this.getPath();
    this._http.download(url, path + '/' + file_name, onReceiveProgress: (received, total) {
      downloadController.setProgress((received / total * 100));
      downloadController.notifyListeners();
    });

    notificationController.show(path + '/' + file_name);

    return new DownloaderResponse(false, "Download completed!");

  }*/

  /*String _getFileName(String url) {
    RegExp regex = new RegExp(r'\/[a-zA-Z0-9_]+\.[a-zA-Z0-9]{3}\?');
    if(regex.hasMatch(url)) {
      String match = regex.stringMatch(url);
      return match.substring(1, match.length - 1);
    }
    return null;
  }*/

  bool validUrl(String url) {

    RegExp regex = RegExp(r'^((http|https):\/\/)?(www.)?instagram.com\/.+$');
    return regex.hasMatch(url);

  }

}