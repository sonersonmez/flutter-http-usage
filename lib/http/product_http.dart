import 'package:http/http.dart' as http;
import 'dart:convert' as convert;


class ProductHttpController {

  
  var GET_PRODUCTS = Uri.parse('http://127.0.0.1:8000/api/');

  getProducts() async{
    var response = await http.get(GET_PRODUCTS);

    if (response.statusCode==200) {
     // var jsonResponse = convert.jsonDecode(response.body);
     
    }

  }
}