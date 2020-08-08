import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  TextEditingController _urlController = new TextEditingController();

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

    return Container(
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
                  setState(() {});
                }
                else {
                  _urlController.text = "";
                  setState(() {});
                }
              },
              child: Icon(
                _urlController.text == "" ? Icons.content_paste : Icons.close,
                color: Colors.grey[700]
              )
          ),
        ),
        onChanged: (text) {
          setState(() {});
        },
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
              Padding(padding: EdgeInsets.only(top: 16)),
              this._buildInput()
            ],
          ),
        ),
        preferredSize: Size.fromHeight(130),
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