import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';
import '../widgets/user_product_item.dart';
import '../widgets/app_drawer.dart';
import './edit_product_screen.dart';

class UserProductsScreen extends StatelessWidget {
  //const UserProductsScreen({Key? key}) : super(key: key);
  static const routeName = "/user-products";

  Future<void> _refreshProducts(BuildContext context)async{
    await Provider.of<Products>(context,listen: false).fetchAndSetProduct(true);
  }

  @override
  Widget build(BuildContext context) {
    //final productsData = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Product's"),
        actions: <Widget>[
          IconButton(onPressed: (){
            Navigator.of(context).pushNamed(EditProductScreen.routeName);
          },
              icon: const Icon(Icons.add),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx, snapshot) => snapshot.connectionState == ConnectionState.waiting
            ? Center(child: CircularProgressIndicator(),)
            : RefreshIndicator(
          onRefresh: () => _refreshProducts(context),
          child: Consumer<Products>(
            builder: (ctx,productsData,_) => Padding(
              padding: EdgeInsets.all(8),
              child: ListView.builder(itemBuilder: (_,i) => Column(children:[UserProductItem(
                  productsData.items[i].id!,
                  productsData.items[i].title!,
                  productsData.items[i].imageUrl!
              ),
                Divider(color: Colors.white,)],),
                itemCount: productsData.items.length,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
