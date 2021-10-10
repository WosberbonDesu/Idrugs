
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './cart_screen.dart';
import '../widgets/products_grid.dart';
import '../providers/cart.dart';
import '../widgets/badge.dart';
import '../widgets/app_drawer.dart';
import '../providers/products.dart';

enum filterOptions {
  Favorites,
  All,

}

class ProductsOverview extends StatefulWidget {


  //final List<Product> loadedProducts = ;
  @override
  _ProductsOverviewState createState() => _ProductsOverviewState();
}

class _ProductsOverviewState extends State<ProductsOverview> {

  var _showOnlyFavorites = false;
  var _isInit = true;
  var _isLoading = false;


  @override
  void initState() {
    // TODO: implement initState
    //Provider.of<Products>(context).fetchAndSetProduct();
    // if you add listen:false you can use in initstate but of context things not working in init state
    //Future.delayed(Duration.zero).then((_){
      //Provider.of<Products>(context).fetchAndSetProduct();
    //});
    super.initState();
  }


  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    if(_isInit){

      setState(() {
        _isLoading = true;
      });

      Provider.of<Products>(context).fetchAndSetProduct()!.then((_) {
        setState(() {
          _isLoading = false;
        });

      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }


  @override
  Widget build(BuildContext context) {

    //final productsContainer = Provider.of<Products>(context,listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text("IDrugs"),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (filterOptions selectedValue){
              setState(() {
                if (selectedValue == filterOptions.Favorites){
                  //productsContainer.showFavoritesOnly();
                  _showOnlyFavorites = true;
                } else {
                  //productsContainer.showAll();
                  _showOnlyFavorites = false;
                }
              });

              //print(selectedValue);
            },
            icon: Icon(Icons.more_vert,)
            ,itemBuilder: (_) => [
              PopupMenuItem(child: Text("Only Favorites"), value: filterOptions.Favorites,),
              PopupMenuItem(child: Text("Show All"), value: filterOptions.All,),
          ],
          ),

          Consumer<Cart>(
            builder: (_, cart, ch) =>
                Badge(child: ch, value: cart.itemCount.toString()),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartsScreen.routeName);
              },
            ),
          ),
        ],
      ),

      drawer: AppDrawer(

      ),
      body: _isLoading ? Center(child: CircularProgressIndicator(color: Colors.white,) ,)
          : new ProductsGrid(_showOnlyFavorites),
    );
  }
}



