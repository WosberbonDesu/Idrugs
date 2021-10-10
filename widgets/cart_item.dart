import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';


class CartItem extends StatelessWidget {

  final String id;
  final String productId;
  final double price;
  final int quantity;
  final String title;


  CartItem(
      this.id,
      this.productId,
      this.price,
      this.quantity,
      this.title
      );

  //const CartItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      background: Container(
        color: Theme.of(context).errorColor,
        child: Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        margin: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction){
        //return Future.value(true);
        return showDialog(context: context, builder: (ctx) => AlertDialog(title: Text("Are you sure?"),
          content: Text("Do you want to remove the item from the cart?"),
          actions: <Widget>[
            TextButton(onPressed: (){
              Navigator.of(ctx).pop(false);
            }, child: Text("No",style: TextStyle(color: Colors.redAccent),)),
            TextButton(onPressed: (){
              Navigator.of(ctx).pop(true);
            }, child: Text("Yes",style: TextStyle(color: Colors.redAccent),))
          ],
        )
        );
      },
      onDismissed: (direction){
        Provider.of<Cart>(context,listen: false).removeItem(productId);
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 15,vertical: 4),
        child: Padding(padding: EdgeInsets.all(8),
        child: ListTile(
          leading: CircleAvatar(child: Padding(padding: EdgeInsets.all(5),
              child: FittedBox(child: Text("\$$price"))),),
          title: Text(title),
          subtitle: Text("Total: \$${(price * quantity)}",style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor),),
          trailing: Text('$quantity x'),
        ),
        ),
      ),
    );
  }
}
