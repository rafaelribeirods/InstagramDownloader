import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'src/Downloader.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  Downloader _downloader = new Downloader();
  TextEditingController _urlController = new TextEditingController();

  final _INVALID_URL_ERROR = 'Invalid URL';

  String _inputError;

  @override
  void initState() {
    super.initState();
    _inputError = "";
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
                    setState(() { _inputError = this._INVALID_URL_ERROR; });
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
              setState(() { _inputError = this._INVALID_URL_ERROR; });
            }
          },
        ),
      ),
    );

  }

  Widget _buildInputErrorAndDownloadButton() {

    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
      child: Row(
        children: <Widget>[
          Expanded(
            child: this._buildInputError(),
          ),
          this._buildInputDownloadButton()
        ],
      )
    );

  }

  Widget _buildInputDownloadButton() {

    bool allowClick = this._urlController.text != "" && this._inputError == "";

    return GestureDetector(
      onTap: allowClick ? () {
        print("Clicou no download do input");
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

  Widget _buildAppBar() {

    return AppBar(
      elevation: 1,
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      bottom: PreferredSize(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              this._buildTitle(),
              this._buildInput(),
              this._buildInputErrorAndDownloadButton()
            ],
          ),
        ),
        preferredSize: Size.fromHeight(170),
      ),
    );

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: this._buildAppBar(),
      backgroundColor: Colors.grey[100],
    );

  }

}