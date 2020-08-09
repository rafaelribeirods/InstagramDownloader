import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'DownloaderResponse.dart';
import 'Globals.dart';
import 'Media.dart';
import 'package:dio/dio.dart';
import 'NotificationController.dart';

class Downloader {

  Dio _http;
  NotificationController notificationController = new NotificationController();

  Downloader() {
    this._http = new Dio();
  }

  Future<DownloaderResponse> getMedia(String url) async {

    Response response;
    try {
      response = await this._http.get(url);
    }
    on DioError catch(e) {
      return new DownloaderResponse(true, Globals.INVALID_URL_ERROR);
    }

    DownloaderResponse post = this._getPost(response.data);
    return post;

    //return this._getStories(response.data);

  }

  DownloaderResponse _getPost(String response) {

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
          return new DownloaderResponse(true, Globals.FILE_NAME_PARSE_ERROR);
        }
        media.add(new Media(file_name, url, type, thumbnail));
      }
      media = this._filter(media, thumbnail_indexes);
      return new DownloaderResponse(false, media);
    }
    return new DownloaderResponse(true, Globals.RESPONSE_PARSE_ERROR);

  }

  /*Future<DownloaderResponse> _getStories(String response) async {

    DownloaderResponse user_id_response = this._getUserId(response);
    if(user_id_response.hasError()) {
      return user_id_response;
    }

    String url = "https://www.instagram.com/graphql/query/?query_hash=de8017ee0a7c9c45ec4260733d81ea31&variables=%7B%22reel_ids%22%3A%5B%22" + user_id_response.getContent() + "%22%5D%2C%22tag_names%22%3A%5B%5D%2C%22location_ids%22%3A%5B%5D%2C%22highlight_reel_ids%22%3A%5B%5D%2C%22precomposed_overlay%22%3Afalse%2C%22show_story_viewer_list%22%3Atrue%2C%22story_viewer_fetch_count%22%3A50%2C%22story_viewer_cursor%22%3A%22%22%7D";
    Response stories;
    try {
      stories = await this._http.get(url);
    }
    on DioError catch(e) {
      return new DownloaderResponse(true, Globals.RESPONSE_PARSE_ERROR);
    }

    Map<String, dynamic> response_object = stories.data;
    String status = response_object['status'] ?? null;
    if(status == null || status == 'fail') {
      return new DownloaderResponse(true, Globals.RESPONSE_PARSE_ERROR);
    }

    print("REQUEST: " + url);
    //print("RESPONSE: " + response_object['data']['reels_media'][0].toString());
    print(json.encode(stories.data));

  }*/

  /*DownloaderResponse _getUserId(String response) {

    RegExp regex1 = new RegExp(r'{"StoriesPage":.+}}]}');

    if(!regex1.hasMatch(response) ) {
      return new DownloaderResponse(true, Globals.RESPONSE_PARSE_ERROR);
    }

    String match;
    String user_id;
    Map<String, dynamic> object;
    if(regex1.hasMatch(response)) {
      match = regex1.stringMatch(response);
      object = json.decode(match);
      user_id = object['StoriesPage'][0]['user']['id'] ?? null;
    }

    if(user_id == null) {
      return new DownloaderResponse(true, Globals.RESPONSE_PARSE_ERROR);
    }
    return new DownloaderResponse(false, user_id);
  }*/

  Map<String, dynamic> _getItemMap(RegExpMatch match) {
    return json.decode('{' + match.group(0).toString() + '}');
  }

  String _getFileName(String url) {
    RegExp regex = new RegExp(r'\/[a-zA-Z0-9_]+\.[a-zA-Z0-9]{3}\?');
    if(regex.hasMatch(url)) {
      String match = regex.stringMatch(url);
      return match.substring(1, match.length - 1);
    }
    return null;
  }

  List<Media> _filter(List<Media> media, List<int> thumbnail_indexes) {

    List<Media> filtered_list = new List();
    for(Media item in media) {
      if(!isListed(filtered_list, item.getFileName())) {
        filtered_list.add(item);
      }
    }

    return filtered_list;

  }

  bool isListed(List<Media> filtered_list, String file_name) {
    for(Media media in filtered_list) {
      if(media.getFileName() == file_name) {
        return true;
      }
    }
    return false;
  }

  Future<String> getPath() async {
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

  }

  Future<DownloaderResponse> downloadAll(List<Media> media) async {

    for(Media item in media) {
      DownloaderResponse response = await download(item.getFileName(), item.getUrl());
      if(response.hasError()) {
        return response;
      }
    }

    return new DownloaderResponse(false, "All downloads completed");

  }

  Future<DownloaderResponse> download(String file_name, String url) async {

    String path = await this.getPath();
    this._http.download(url, path + '/' + file_name);

    notificationController.show(path + '/' + file_name);

    return new DownloaderResponse(false, "Download completed!");

  }

  bool validUrl(String url) {

    RegExp regex = RegExp(r'^((http|https):\/\/)?(www.)?instagram.com\/.+$');
    return regex.hasMatch(url);

  }

}