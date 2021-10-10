import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';
import 'dart:convert';
import 'product.dart';

class Products with ChangeNotifier{
  List<Product> _items = [
    /*
    Product(
        id: "p1",
        title: "Adhansia",
        description: "A white t-shirt- cool t-shirt",
        price: 29.0,
        imageUrl: "https://images.unsplash.com/photo-1522426197515-ad17e39de88d?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=700&q=80"
    ),

    Product(
        id: "p2",
        title: "Old Weed",
        description: "A white t-shirt- cool t-shirt",
        price: 229.0,
        imageUrl: "https://images.unsplash.com/photo-1623044557650-c23f904df4ba?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=1879&q=80"
    ),
    Product(
        id: "p3",
        title: "Molly",
        description: "A white t-shirt- cool t-shirt",
        price: 219.0,
        imageUrl: "https://images.unsplash.com/photo-1516826049371-1e7856387270?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=1950&q=80"
    ),
    Product(
        id: "p4",
        title: "MDMA",
        description: "A white t-shirt- cool t-shirt",
        price: 19.99,
        imageUrl: "https://images.unsplash.com/photo-1605760677558-e8efc327a974?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=400&q=80"
    ),
    Product(
        id: "p5",
        title: "Weed V2",
        description: "A white t-shirt- cool t-shirt",
        price: 229.0,
        imageUrl: "https://images.unsplash.com/photo-1498671546682-94a232c26d17?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=1887&q=80"
    ),
    Product(
        id: "p6",
        title: "Ecstasy Green",
        description: "A white t-shirt- cool t-shirt",
        price: 229.0,
        imageUrl: "https://images.unsplash.com/photo-1580377968242-daed42865732?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=387&q=80"
    ),
     */
  ];

  //var _showFavoritesOnly = false;

  final String authToken;
  final String userId;

  Products(this.authToken,this.userId,this._items);

  List<Product> get items {
    //if(_showFavoritesOnly){
      //return _items.where((prodItem) => prodItem.isFavorite!).toList();
    //}
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite!).toList();
  }

  Product findById(String id){
    return _items.firstWhere((prod) => prod.id == id);
  }

  //void showFavoritesOnly(){
    //_showFavoritesOnly = true;
    //notifyListeners();
  //}

  //void showAll(){
    //_showFavoritesOnly = false;
    //notifyListeners();
  //}

  Future<void>? fetchAndSetProduct([bool filterByUser = false])async{

    var _params;
    if (filterByUser) {
      _params = <String, String>{
        'auth': authToken,
        'orderBy': json.encode("creatorId"),
        'equalTo': json.encode(userId),
      };
    }
    if (filterByUser == false) {
      _params = <String, String>{
        'auth': authToken,
      };
    }
    var url = Uri.https('shopapp-95fbb-default-rtdb.europe-west1.firebasedatabase.app',
        '/products.json', _params);
    try{
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if(extractedData == null){
        return;
      }

       url = Uri.https('shopapp-95fbb-default-rtdb.europe-west1.firebasedatabase.app',
          '/userFavorites/$userId.json', {'auth': '$authToken'});
      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);

      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData["description"],
          price: prodData["price"],
          isFavorite: favoriteData == null ? false : favoriteData[prodId] ?? false,
          imageUrl: prodData["imageUrl"],

        ));
      });
      _items = loadedProducts;
      notifyListeners();
      //print(json.decode(response.body));
    }catch(error){
      throw(error);
    }

  }


  Future<void>? addProduct(Product product) async{
    //_items.add(value);

    final url = Uri.https('shopapp-95fbb-default-rtdb.europe-west1.firebasedatabase.app',
        '/products.json', {'auth': '$authToken'});
    try {
      final response = await http
          .post(url, body: json.encode({
        "title": product.title,
        "description": product.description,
        "imageUrl": product.imageUrl,
        "price": product.price,
        'creatorId': userId,
        //"isFavorite": product.isFavorite,
      }),
      );
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
      // _items.insert(0, newProduct);
      notifyListeners();
    } catch(error){
      print(error);
      throw error;
    }


      //print(error);
      //throw error;


  }


  Future<void> updateProduct(String id, Product newProduct)async{
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if(prodIndex >= 0){
      final url = Uri.https('shopapp-95fbb-default-rtdb.europe-west1.firebasedatabase.app',
          '/products.json', {'auth': '$authToken'});
      await http.patch(url,body: json.encode({
        'title': newProduct.title,
        'description': newProduct.description,
        'imageUrl': newProduct.imageUrl,
        'price': newProduct.price,
      }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    }else{
      print("...");
    }
  }

  Future<void> deleteProduct(String id) async{


    final url = Uri.https('shopapp-95fbb-default-rtdb.europe-west1.firebasedatabase.app',
        '/products/$id.json', {'auth': '$authToken'});
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    Product? existingProduct = _items[existingProductIndex];

    _items.removeAt(existingProductIndex);
    notifyListeners();
    //_items.removeWhere((prod) => prod.id == id);
    final response = await http.delete(url);
      //print(response.statusCode);
      if(response.statusCode >= 400){
        _items.insert(existingProductIndex, existingProduct);
        
        notifyListeners();
        throw HttpException('Could not Delete Product');
      }
      existingProduct = null;

  }

}