import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:virtual_helper/models/models_model.dart';

import '../constants/api_constants.dart';

class ApiService {
  static Future<List<ModelsModel>> getModels() async {
    try {
      var response = await http.get(
        Uri.parse("$BASE_URL/models"),
        headers: {'Authorization': 'Bearer $API_KEY'},
      );

      Map jsonResponse = jsonDecode(response.body);

      if (jsonResponse['error'] != null) {
        //print("jsonResponse['error'] ${jsonResponse['error']["message"]}");
        throw HttpException(jsonResponse['error']["message"]);
      }
      // print('jsonResponse $jsonResponse');
      List temp = [];
      for (var value in jsonResponse["data"]) {
        temp.add(value);
        print("temp $value");
      }
      return ModelsModel.modelsFromSnapshot(temp);
    } catch (error) {
      print("error $error");
      rethrow;
    }
  }

  // send Message

  static Future<void> sendMessage(
      {required String message, String modelId = "gpt-3.5-turbo-0301"}) async {
    try {
      var response = await http.post(Uri.parse("$BASE_URL/completions"),
          headers: {
            'Authorization': 'Bearer $API_KEY',
            "Content-Type": "application/json"
          },
          body: jsonEncode(
            {
              "model": modelId,
              "prompt": message,
              "max_tokens": 100,
            },
          ));

      Map jsonResponse = jsonDecode(response.body);

      if (jsonResponse['error'] != null) {
        //print("jsonResponse['error'] ${jsonResponse['error']["message"]}");
        throw HttpException(jsonResponse['error']["message"]);
      }
      if (jsonResponse["choices"].length > 0) {
        print(
            "jsonResponse[choices]text ${jsonResponse["choices"][0]["text"]}");
      }
    } catch (error) {
      print("error $error");
      rethrow;
    }
  }
}
