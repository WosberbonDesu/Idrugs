import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';
import '../models/http_exception.dart';


enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              //gradient: LinearGradient(
                //colors: [
                  //Color.fromRGBO(248, 0, 0, 1).withOpacity(0.8),
                  //Color.fromRGBO(0, 0, 0, 1).withOpacity(0.5),
                //],
                //begin: Alignment.topLeft,
                //end: Alignment.bottomRight,
                //stops: [0, 1],
              //),
              image: DecorationImage(
                image: AssetImage("assets/images/be.png"),
                fit: BoxFit.cover
              )
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 94.0),
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        ..translate(-10.0),
                      // ..translate(-10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.black,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        'IDrugs',
                        style: TextStyle(
                          color: Colors.pink,
                          fontSize: 50,
                          fontFamily: 'Anton',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key? key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin{
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();
  //var containerHeight = 260;
  AnimationController? _controller;
  Animation<Size>? _heightAnimation;

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _heightAnimation = Tween<Size>(
        begin: Size(double.infinity,260),
        end: Size(double.infinity,320)
    ).animate(CurvedAnimation(
        parent: _controller!,
        curve: Curves.fastOutSlowIn)
    );
    _heightAnimation!.addListener(() => setState(() {

    }));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller!.dispose();
  }

  void _showErrorDialog(String message){
    showDialog(context: context, builder: (ctx) => AlertDialog(
      content: Text(message),
      title: Text('An Error Occured',style: TextStyle(color: Colors.redAccent),),
      actions: <Widget>[
        TextButton(
            onPressed: (){
              Navigator.of(context).pop();
            },
            child: Text('Okay')
        )
      ],
    )
    );
  }

  Future<void> _submit() async{
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try{
      if (_authMode == AuthMode.Login) {
        // Log user in
        await Provider.of<Auth>(context,listen: false).login(
            _authData['email']!,
            _authData['password']!
        );
      } else {
        // Sign user up
        await Provider.of<Auth>(context,listen: false).signup(
            _authData['email']!,
            _authData['password']!
        );
      }

      //Navigator.of(context).pushReplacementNamed('/products-overview');


    }on HttpException catch(error){
      var errorMessage = 'Authentication failed!';
      if(error.toString().contains('EMAIL_EXISTS')){
        errorMessage = 'This email address is already taken in use.';
      }else if(error.toString().contains('INVALID_EMAIL')){
        errorMessage = 'This is not a valid email address';
      }else if(error.toString().contains('WEAK_PASSWORD')){
        errorMessage = 'This password is too weak!';
      }else if(error.toString().contains('EMAIL_NOT_FOUND')){
        errorMessage = 'Email you given is not found please check for the mistakes';
      }else if(error.toString().contains('INVALID_PASSWORD')){
        errorMessage = 'Password you entered is not found check try again';
      }
      
      _showErrorDialog(errorMessage);
        
    }catch(error){
      const errorMessage = 'Could not authenticate your account. Please try again later';
      _showErrorDialog(errorMessage);
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
      _controller!.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _controller!.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    Color c = const Color.fromARGB(255, 0, 0, 0);
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child:  AnimatedContainer(
        duration: Duration(milliseconds: 300),
          curve: Curves.easeIn,
          height: _authMode == AuthMode.Signup ? 320 : 260,
          //height: _heightAnimation!.value.height,
          constraints:
          BoxConstraints(
            minHeight:  _authMode == AuthMode.Signup ? 320 : 260,),
            width: deviceSize.width * 0.75,
            padding: EdgeInsets.all(16.0),
            child:  Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty || !value.contains('@')) {
                      return 'Invalid email!';
                   }
                    return null;
                  //return null;
                  },
                  onSaved: (value) {
                    _authData['email'] = value!;
                  },
                ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                controller: _passwordController,
                validator: (value) {
                  if (value!.isEmpty || value.length < 5) {
                    return 'Password is too short!';
                  }
                },
                onSaved: (value) {
                  _authData['password'] = value!;
                },
              ),
              if (_authMode == AuthMode.Signup)
                TextFormField(
                  enabled: _authMode == AuthMode.Signup,
                  decoration: InputDecoration(labelText: 'Confirm Password'),
                  obscureText: true,
                  validator: _authMode == AuthMode.Signup
                      ? (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match!';
                    }
                  }
                      : null,
                ),
              SizedBox(
                height: 20,
              ),
              if (_isLoading)
                CircularProgressIndicator()
              else
                ElevatedButton(
                  child:
                  Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP',style: TextStyle(color: Colors.white),),
                  onPressed: _submit,
                  style: ButtonStyle(
                      backgroundColor:  MaterialStateProperty.all<Color>(c),
                      padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      )
                  ),

                ),
              TextButton(
                child: Text(
                  '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD',style: TextStyle(color: Colors.lightBlue),),
                onPressed: _switchAuthMode,
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ),
      ),)
      );

  }
}
