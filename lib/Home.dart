import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instagram_downloader/src/Globals.dart';
import 'src/Downloader.dart';
import 'src/DownloaderResponse.dart';
import 'src/Media.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  Downloader _downloader = new Downloader();
  TextEditingController _urlController = new TextEditingController();

  List<Media> _media;

  bool _loading;
  String _inputError;

  @override
  void initState() {
    super.initState();
    _media = new List();
    _inputError = "";
    _loading = false;
  }

  Widget _buildTitle() {

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 28,
          color: Colors.black
        ),
        children: [
          TextSpan(text: "Media Downloader for ", style: TextStyle(fontWeight: FontWeight.w300)),
          TextSpan(text: "Instagram", style: TextStyle(fontWeight: FontWeight.bold))
        ]
      )
    );

  }

  Widget _buildInput() {

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.all(
            Radius.circular(25)
          )
        ),
        child: TextField(
          controller: _urlController,
          style: TextStyle(
            color: Colors.grey[700]
          ),
          cursorColor: Colors.grey[700],
          decoration: InputDecoration(
            contentPadding: EdgeInsets.only(left: 16, right: 0),
            floatingLabelBehavior: FloatingLabelBehavior.never,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(50))
            ),
            labelText: 'Paste your link here...',
            suffixIcon: GestureDetector(
              onTap: () async {
                if(_urlController.text.isEmpty) {
                  ClipboardData data = await Clipboard.getData('text/plain');
                  _urlController.text = data.text;
                  if(this._downloader.validUrl(_urlController.text)) {
                    setState(() { _inputError = ""; });
                  }
                  else {
                    setState(() { _inputError = Globals.INVALID_URL_ERROR; });
                  }
                }
                else {
                  _urlController.text = "";
                  setState(() { _inputError = ""; });
                }
              },
              child: Icon(
                _urlController.text == "" ? Icons.content_paste : Icons.close,
                color: Colors.grey[700]
              )
            ),
          ),
          onChanged: (text) {
            if(text == "") {
              setState(() { _inputError = ""; });
            }
            else if(this._downloader.validUrl(text)) {
              setState(() { _inputError = ""; });
            }
            else {
              setState(() { _inputError = Globals.INVALID_URL_ERROR; });
            }
          },
        ),
      ),
    );

  }

  Widget _buildInputErrorAndDownloadButton(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
      child: Row(
        children: <Widget>[
          Expanded(
            child: this._buildInputError(),
          ),
          this._buildInputDownloadButton(context)
        ],
      )
    );

  }

  Widget _buildInputDownloadButton(BuildContext context) {

    bool allowClick = this._urlController.text != "" && this._inputError == "";

    return GestureDetector(
      onTap: allowClick ? () async {
        setState(() { _loading = true; });
        DownloaderResponse response = await this._downloader.getMedia(this._urlController.text);
        setState(() { _loading = false; });
        if(response.hasError()) {
          Scaffold.of(context).hideCurrentSnackBar();
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text(response.getContent()),
            backgroundColor: Colors.red,
          ));
        }
        else {
          setState(() { this._media = response.getContent(); });
        }
      } : null,
      child: Text(
        "DOWNLOAD",
        style: TextStyle(
          color: allowClick ? Colors.blue : Colors.grey[700],
          fontWeight: FontWeight.bold
        ),
      ),
    );

  }

  Widget _buildInputError() {

    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        this._inputError,
        style: TextStyle(
          fontSize: 12,
          color: Colors.red
        ),
      ),
    );

  }

  Widget _buildAppBar(BuildContext context) {

    return AppBar(
      elevation: 1,
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      bottom: PreferredSize(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Builder(
            builder: (context) => Column(
              children: <Widget>[
                this._buildTitle(),
                this._buildInput(),
                this._buildInputErrorAndDownloadButton(context)
              ],
            ),
          ),
        ),
        preferredSize: Size.fromHeight(170),
      ),
    );

  }

  Widget _buildLoading() {

    return Center(
      child: CircularProgressIndicator(),
    );

  }

  Widget _buildGrid(BuildContext context) {

    return Column(
      children: <Widget>[
        Expanded(
          child: this._buildList(context),
        ),
        Row(
          children: <Widget>[
            this._media.length > 1 ? this._buildDownloadAllButton(context) : Container()
          ],
        )
      ],
    );

  }

  Widget _buildDownloadAllButton(BuildContext context) {

    return Expanded(
      child: FlatButton.icon(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Colors.blue,
            width: 1,
            style: BorderStyle.solid
          )
        ),
        icon: Icon(Icons.arrow_downward),
        label: Text("Download All"),
        color: Colors.blue,
        textColor: Colors.white,
        padding: EdgeInsets.all(15),
        splashColor: Colors.blueAccent,
        onPressed: () async {
          setState(() { _loading = true; });
          DownloaderResponse response = await this._downloader.downloadAll(this._media);
          setState(() { _loading = false; });
          Scaffold.of(context).hideCurrentSnackBar();
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text(response.getContent()),
            backgroundColor: response.hasError() ? Colors.red : Colors.blue,
          ));
        },
      ),
    );

  }

  Widget _buildList(BuildContext context) {

    return CustomScrollView(
      primary: false,
      slivers: <Widget>[
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid.count(
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 2,
            children: this._buildItems(context)
          ),
        ),
      ],
    );

  }

  List<Widget> _buildItems(context) {

    List<Widget> items = new List();

    for(Media item in this._media) {
      items.add(GestureDetector(
        onTap: () async {
          setState(() { _loading = true; });
          DownloaderResponse response = await this._downloader.download(item.getFileName(), item.getUrl());
          setState(() { _loading = false; });
          Scaffold.of(context).hideCurrentSnackBar();
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text(response.getContent()),
            backgroundColor: response.hasError() ? Colors.red : Colors.blue,
          ));
        },
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(item.getThumbnail()),
              fit: BoxFit.cover
            )
          ),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(bottomRight: Radius.circular(5)),
                          color: Colors.grey[100]
                        ),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(5, 6, 5, 7),
                          child: Text(
                            item.getType().toUpperCase(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      )
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      this._media.remove(item);
                      setState(() {});
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5)),
                        color: Colors.grey[100]
                      ),
                      child: Icon(
                        Icons.close,
                        size: 29
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ));
    }

    return items;

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: this._buildAppBar(context),
      body: Builder(
        builder: (context) => this._loading ? this._buildLoading() : (this._media.isEmpty ? Container() : this._buildGrid(context)),
      ),
      backgroundColor: Colors.grey[100],
    );

  }

}