// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, must_be_immutable

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gymbuddy/models/Product.dart';
import 'package:http/http.dart' as http;


class AllProductsScreen extends StatefulWidget {
  AllProductsScreen({Key? key}) : super(key: key);

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  final url = Uri.parse('http://10.0.2.2:8000/api/getproducts');

  Future getProducts() async {
    var response = await http.get(url);
    try {
      if (response.statusCode == 200) {
        var product = productFromJson(response.body);

        if (mounted) {
          setState(() {
            productResult = product;
            length = product.length;
          });

          return product;
        }
      }
    } catch (e) {}
  }

  var length;
  var productResult;

  @override
  void initState() {
    super.initState();
    getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: length != null
            ? ListView.builder(
                itemCount: length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Image.network(productResult[index].image),
                    subtitle: Text(
                      productResult[index].name,
                      textAlign: TextAlign.center,
                    ),
                    trailing: Text(
                      productResult[index].category.name,
                      textAlign: TextAlign.center,
                    ),
                  );
                })
            : Center(child: CircularProgressIndicator()),
        floatingActionButton: FloatingActionButton(onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddProduct()));
        }));
  }
}

class AddProduct extends StatefulWidget {
  const AddProduct({Key? key}) : super(key: key);

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final TextEditingController _nameContoller = TextEditingController();
  final TextEditingController _priceContoller = TextEditingController();
  final TextEditingController _imageContoller = TextEditingController();
  final TextEditingController _descriptionContoller = TextEditingController();
  final TextEditingController _categoryIdContoller = TextEditingController();

  final url = Uri.parse('http://10.0.2.2:8000/addproduct');
  String status = '';
  Future addProduct() async {
    var response = await http.post(url, body: {
      'name': _nameContoller.text,
      'category_id': _categoryIdContoller.text,
      'image': _imageContoller.text,
      'price': _priceContoller.text,
      'description': _descriptionContoller.text
    });

    if (response.statusCode == 200) {
      setState(() {
        status = 'Ürün başarıyla eklendi.';
      });
    } else {
      setState(() {
        status = response.statusCode.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(status),
            TextFormField(
              controller: _nameContoller,
            ),
            TextFormField(controller: _priceContoller),
            TextFormField(controller: _imageContoller),
            TextFormField(controller: _descriptionContoller),
            TextFormField(controller: _categoryIdContoller),
            ElevatedButton(
                onPressed: () {
                  addProduct();
                },
                child: Text('Yeni ürün ekle')),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductStream(),
                      ));
                },
                child: Text('To Stream')),
                ElevatedButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => FutureProductScreen(),));
                }, child: Text('To Future'))
          ],
        ),
      ),
    );
  }
}

class ProductStream extends StatefulWidget {
  const ProductStream({Key? key}) : super(key: key);

  @override
  State<ProductStream> createState() => _ProductStreamState();
}

class _ProductStreamState extends State<ProductStream> {
  final url = Uri.parse('http://10.0.2.2:8000/api/getproducts');

  late StreamController _productController;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  int count = 1;

  Future fetchPost() async {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      var productResult = productFromJson(response.body);
      return productResult;
    } else {
      throw Exception('Failed to load post');
    }
  }

  loadPosts() async {
    fetchPost().then((res) async {
      _productController.add(res);
      return res;
    });
  }

  Future<Null> _handleRefresh() async {
    fetchPost().then((value) {
      _productController.add(value);
    });
  }

  @override
  void initState() {
    super.initState();
    _productController = StreamController();
    loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: StreamBuilder(
        stream: _productController.stream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          print('Has error: ${snapshot.hasError}');
          print('Has data: ${snapshot.hasData}');
          print('Snapshot Data ${snapshot.data}');

          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }

          if (snapshot.hasData) {
            return Column(
              children: <Widget>[
                Expanded(
                  child: Scrollbar(
                    child: RefreshIndicator(
                      onRefresh: _handleRefresh,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          var product = snapshot.data[index];
                          return ListTile(
                            title: Text(product.name),
                            subtitle: Text(product.category.name),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const CircularProgressIndicator();
          }

          if (snapshot.connectionState != ConnectionState.done) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            return Text('No Posts');
          }
        },
      ),
    );
  }
}


class FutureProductScreen extends StatefulWidget {
  const FutureProductScreen({ Key? key }) : super(key: key);

  @override
  State<FutureProductScreen> createState() => _FutureProductScreenState();
}

class _FutureProductScreenState extends State<FutureProductScreen> {

  final url = Uri.parse('http://10.0.2.2:8000/api/getproducts');
  var length;
  var productResult;
  String status='';

  final snackBar =SnackBar(
    content: Text("Kayıt silindi."),
    backgroundColor: Colors.red,
    action: SnackBarAction(
      textColor: Colors.white,
      label: "Test Butonu",
      onPressed: (){
       
      },
    ),
  );

  Future getPosts () async{

    var response = await http.get(url);

    if(response.statusCode==200){
      var products = productFromJson(response.body);
      length = products.length;
        setState(() {
          productResult = products;
        });

      return products;
    }else{
      setState(() {
        status = response.statusCode.toString();
      });
    }
    
  }

  Future deletePost(int id) async{
    var response = await http.delete(Uri.parse('http://10.0.2.2:8000/deleteproduct?id=$id'));
    if(response.statusCode == 200){
      setState(() {
        status='Kayıt silindi.';
        _handleRefresh();
      });

    }
  }


  Future<Null> _handleRefresh ()async{
    getPosts();
  }

  @override
  void initState() {
    // TODO: implement initState
    getPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: length!=null ? ListView.builder(
            itemCount: length,
            itemBuilder: (context,index){
            return ListTile(

              title: Image.network(productResult[index].image),
              subtitle: Text(productResult[index].name),
              trailing: Text(productResult[index].category.name),
            //  leading: Text(status),
              onTap: (){
                 showAlertDialog(context, index);
               // deletePost(productResult[index].id);
              },
              );
          }) : Center(child: CircularProgressIndicator()),
        ),
    );
  }
  showAlertDialog(BuildContext context, int index) {

  // set up the buttons
  Widget remindButton = TextButton(
    child: Text("Evet, sil."),
    onPressed:  () {
      deletePost(productResult[index].id);
      Navigator.pop(context);
    },
  );
  Widget cancelButton = TextButton(
    child: Text("Hayır, silme."),
    onPressed:  () {
      Navigator.pop(context);
    },
  );
  

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Uyarı!"),
    content: Text("Silmek istediğinize emin misiniz?"),
    actions: [
      remindButton,
      cancelButton,
      
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
}