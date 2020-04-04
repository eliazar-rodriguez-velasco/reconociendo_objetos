import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

void main() => runApp(MaterialApp(
  home: MyApp(),
  debugShowCheckedModeBanner: false,
));

class MyApp extends StatefulWidget{
  @override
  _AppState createState()=>_AppState();
}

class _AppState extends State<MyApp>{
  //Variables de control
  List _salidas;
  File _Imagen;
  bool _isLoading = false;

  @override
  void initState(){
    super.initState();
    _isLoading = true;
    loadModel().then((value){
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("objects"),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: _isLoading ? Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ): Container(
        width: MediaQuery.of(context).size.width,//Ajusta el ancho de la pantall
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _Imagen == null ? Container():Image.file(_Imagen),
            SizedBox(
              height: 20,
            ),
            _salidas != null ? Text("${_salidas[0]["label"]}",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
                background: Paint()..color = Colors.white,
              ),
            )
                : Container()

          ],
        ),
      ),

      floatingActionButton: SpeedDial(
        backgroundColor: Colors.black,
        animatedIcon: AnimatedIcons.menu_close,
        children: [
          SpeedDialChild(
              backgroundColor: Colors.black,
              child: Icon(Icons.camera_alt),
              label: "Camera",
              onTap: takePhoto
          ),
          SpeedDialChild(
              backgroundColor: Colors.black,
              child: Icon(Icons.image),
              label: "Gallery",
              onTap: pickImage
          )
        ],
      ),


    );
  }


  takePhoto() async{
    var photo = await ImagePicker.pickImage(source: ImageSource.camera);
    if(photo == null) return null;
    setState(() {
      _isLoading = true;
      _Imagen = photo;
    });

    clasificar(photo);
  }

  pickImage() async{
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if(image == null) return null;
    setState(() {
      _isLoading = true;
      _Imagen = image;
    });

    clasificar(image);
  }

  clasificar(File image) async{
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 5,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _isLoading = false;
      _salidas = output;
    });
  }

//Cargar modelo
  loadModel() async{
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }

  @override
  void dispose(){
    Tflite.close();
    super.dispose();
  }

}
