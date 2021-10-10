import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './screens/cart_screen.dart';
import './providers/cart.dart';
import './screens/product_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './providers/products.dart';
import './providers/orders.dart';
import './screens/orders_screen.dart';
import './providers/auth.dart';
import './screens/user_product_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/auth_screen.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
        ChangeNotifierProvider(
          create: (_) => Auth(),),
        ChangeNotifierProxyProvider<Auth,Products>(
        update: (ctx,auth,previousProducts) => Products(
            auth.token!,
            auth.userId,
            previousProducts == null ? [] : previousProducts.items),
          create: (ctx) => Products('','',[]
          ),
        ),
        ChangeNotifierProvider(
        create: (ctx) => Cart(),),
        ChangeNotifierProxyProvider<Auth,Orders>(
            update: (ctx,auth,previousOrders) => Orders(
                auth.token!,
                auth.userId,
                previousOrders == null ? [] : previousOrders.orders
            ),
          create: (ctx) => Orders("","",[]),
        ),
    ],

      child: Consumer<Auth>(builder: (ctx,auth,_) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MyApp',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.black,
          primarySwatch: Colors.yellow,
          accentColor: Colors.deepOrange,
          fontFamily: "Lato",
        ),
        home: auth.isAuth ? ProductsOverview() : AuthScreen(),
        routes: {
          ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
          CartsScreen.routeName: (ctx) => CartsScreen(),
          OrdersScreen.routeName: (ctx) => OrdersScreen(),
          UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
          EditProductScreen.routeName: (ctx) => EditProductScreen(),
        },
      ),
      )
    );
  }
}


