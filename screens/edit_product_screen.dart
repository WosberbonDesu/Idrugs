import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  //const EditProductScreen({Key? key}) : super(key: key);

  static const routeName = "/edit-product";


  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {

  //var urlPattern = r"(https?|ftp)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?";
  //var result = new RegExp(urlPattern, caseSensitive: false).firstMatch('https://www.google.com');

  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedProduct = Product(
      id: null,
      title: "",
      description: "",
      price: 0,
      imageUrl: ""
  );

  var _initValues = {
    "title": "",
    "description": "",
    "price": "",
    "imageUrl": "",
  };
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    _imageUrlFocusNode.addListener(_updateImageUrl);
    _imageUrlController.addListener(() {
      setState(() {

      });
    });
    super.initState();
  }


  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    if(_isInit){
      final productId = ModalRoute.of(context)!.settings.arguments;
      if(productId != null){
        _editedProduct = Provider.of<Products>(context,listen: false)
            .findById(productId as String);

        _initValues = {
          "title": _editedProduct.title as String,
          "description": _editedProduct.description as String,
          "price": _editedProduct.title!.toString(),
          //"imageUrl": _editedProduct.imageUrl!,
          "imageUrl": "",
        };
        _imageUrlController.text = _editedProduct.imageUrl!;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }


  @override
  void dispose() {
    // TODO: implement dispose

    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlFocusNode.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }


  void _updateImageUrl(){
    if(!_imageUrlFocusNode.hasFocus){
      if((!_imageUrlController.text.startsWith("http") &&
              !_imageUrlController.text.startsWith("https"))
          || (!_imageUrlController.text.endsWith(".png") &&
              !_imageUrlController.text.endsWith(".jpg") &&
              !_imageUrlController.text.endsWith("80") &&
              !_imageUrlController.text.endsWith(".jpeg"))){
        return ;
      }
      setState(() {

      });
    }
  }


  Future<void> _saveForm() async{
    final isValid = _form.currentState!.validate();
    if(!isValid){
      return;
    }
    _form.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    if(_editedProduct.id != null){
      await Provider.of<Products>(context, listen: false).updateProduct(_editedProduct.id!,_editedProduct);

    }else{
      try{
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      }catch(error){
        await showDialog<Null>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text("An error occured"),
            content: Text("Something went wrong!"),
            actions: [
              TextButton(onPressed: (){
                Navigator.of(ctx).pop();
              },
                  child: Text("Okay"))
            ],
          ),
        );
      } //finally{
        //setState(() {
          //_isLoading = false;
       // });
        //Navigator.of(context).pop();

      //}
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();

    //Navigator.of(context).pop();
    //print(_editedProduct.title);
    //print(_editedProduct.description);
    //print(_editedProduct.price);
    //print(_editedProduct.imageUrl);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade800,
      appBar: AppBar(
        title: Text(
          "Edit Product"
        ),
        actions: <Widget>[
          IconButton(
              onPressed: _saveForm,
              icon: Icon(Icons.save_outlined))
        ],
      ),
      body: _isLoading ? Center(
        child: CircularProgressIndicator(color: Colors.redAccent,),
      ) : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _form,
          child: ListView(
            children: <Widget>[
              TextFormField(
                initialValue: _initValues["title"],
                validator: (value){
                  if(value!.isEmpty){
                    return "Please provide a value.";
                  }
                  return null;
                },
                onSaved: (value) {
                  _editedProduct = Product(
                      title: value,
                      price: _editedProduct.price,
                      description: _editedProduct.description,
                      imageUrl: _editedProduct.imageUrl,
                      id: _editedProduct.id,
                      isFavorite: _editedProduct.isFavorite
                  );
                },
                onFieldSubmitted: (_){
                  FocusScope.of(context).requestFocus(_priceFocusNode);
                },
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(
                            color: Colors.white
                        )
                    ),
                  labelStyle: TextStyle(color:  Colors.white,),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(
                      color: Colors.white
                    )
                  ),
                  labelText: "Title",
                  fillColor: Colors.white,
                  focusColor: Colors.white,
                  hoverColor: Colors.white
                ),
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: 10,),
              TextFormField(
                initialValue: _initValues["price"],
                validator: (value){
                  if(value!.isEmpty){
                    return "Fiyati gir amin oglu";
                  }
                  if(double.tryParse(value) == null){
                    return "Please enter a valid num";
                  }
                  if(double.parse(value) <= 0){
                    return "Please enter num greater than 0";
                  }
                  return null;
                },
                onSaved: (value) {
                  _editedProduct = Product(
                      title: _editedProduct.title,
                      price: double.parse(value!),
                      description: _editedProduct.description,
                      imageUrl: _editedProduct.imageUrl,
                      id: _editedProduct.id,
                      isFavorite: _editedProduct.isFavorite,
                  );
                },
                onFieldSubmitted: (_){
                  FocusScope.of(context).requestFocus(_descriptionFocusNode);
                },
                keyboardType: TextInputType.number,
                focusNode: _priceFocusNode,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(
                      color: Colors.white
                    )
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                    labelStyle: TextStyle(color:  Colors.white),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(
                            color: Colors.white
                        )
                    ),
                    labelText: "Price",
                    fillColor: Colors.white,
                    focusColor: Colors.white,
                    hoverColor: Colors.white,

                ),
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: 10,),
              TextFormField(
                initialValue: _initValues["description"],
                validator: (marko){
                  if(marko!.isEmpty){
                    return "Please enter a description";
                  }
                  if(marko.length < 10){
                    return "Should be at least 10 characters long.";
                  }
                  return null;
                },
                onSaved: (value) {
                  _editedProduct = Product(
                      title: _editedProduct.title,
                      price: _editedProduct.price,
                      description: value,
                      imageUrl: _editedProduct.imageUrl,
                      id: _editedProduct.id,
                      isFavorite: _editedProduct.isFavorite,
                  );
                },
                focusNode: _descriptionFocusNode,
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(
                            color: Colors.white
                        )
                    ),
                    labelStyle: TextStyle(color:  Colors.white,),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(
                            color: Colors.white
                        )
                    ),
                    labelText: "Description",
                    fillColor: Colors.white,
                    focusColor: Colors.white,
                    hoverColor: Colors.white
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    width: 100,
                    height: 100,
                    margin: EdgeInsets.only(top: 8,right: 10),
                    decoration: BoxDecoration(
                      border: Border.all(width: 1,color: Colors.white),
                    ),
                    child: _imageUrlController.text.isEmpty ? Text("Enter a Url to show image",
                    style: TextStyle(color: Colors.white),)
                    : FittedBox(child: Image.network(_imageUrlController.text),fit: BoxFit.cover,),
                  ),
                  Expanded(
                    child: TextFormField(
                      //initialValue: _initValues["imageUrl"], controller ile aynı anda kullanamazsın
                      validator: (value){
                        if(value!.isEmpty){
                          return "Please enter an image url";
                        }
                        if(!value.startsWith("http") && !value.startsWith("https")){
                          return "Please enter a valid URL";
                        }
                        if(!value.endsWith(".png") && !value.endsWith(".jpg") && !value.endsWith(".jpeg")){
                          return "Seçeceğin formatı sikim";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                            title: _editedProduct.title,
                            price: _editedProduct.price,
                            description: _editedProduct.description,
                            imageUrl: value,
                            id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite,
                        );
                      },
                      onFieldSubmitted: (_) {
                        _saveForm();
                      },
                      focusNode: _imageUrlFocusNode,
                      controller: _imageUrlController,
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                          fillColor: Colors.white,
                          focusColor: Colors.white,
                          hoverColor: Colors.white,
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: BorderSide(
                                  color: Colors.white
                              )
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: BorderSide(
                                  color: Colors.white
                              )
                          ),
                          labelStyle: TextStyle(color:  Colors.white,),
                        labelText: "Image URL"
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

