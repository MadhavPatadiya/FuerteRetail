import 'dart:convert';

import 'package:billingsphere/data/models/deliveryChallan/delivery_challan_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/constant.dart';

class DeliveryChallanServices {
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Add inward challan
  Future<void> createDeliveryChallan(DeliveryChallan challan) async {
    String? token = await getToken();

    final response = await http.post(
      Uri.parse('${Constants.baseUrl}/delivery-challan/create'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      },
      // body: jsonEncode(challan.toJson()),
      body: challan.toJson(),
    );

    print(response.body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create inward challan');
    }
  }

  Future<List<DeliveryChallan>> fetchDeliveryChallan() async {
    String? token = await getToken();

    final response = await http.get(
      Uri.parse('${Constants.baseUrl}/delivery-challan/delivery_challans'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      },
    );
    final responseData = json.decode(response.body);
    // print('PRINT DEVLIERY CHALLAN $responseData');
    if (responseData['success'] == true) {
      final deliveryChallanData = responseData['data'];

      // final List<DeliveryChallan> deliveryChallan = List.from(
      //     deliveryChallanData.map((entry) => DeliveryChallan.fromMap(entry)));

      final List<DeliveryChallan> items =
          List.from(deliveryChallanData.map((entry) {
        return DeliveryChallan.fromMap(entry);
      }));

      // print(items);

      return items;
    } else {
      throw Exception('${responseData['message']}');
    }
  }

  Future<DeliveryChallan?> fetchDeliveryChallanById(String id) async {
    try {
      final String? token = await getToken();
      final response = await http.get(
        Uri.parse('${Constants.baseUrl}/delivery-challan/delivery_challan/$id'),
        headers: {
          'Authorization': '$token',
        },
      );

      final responseData = json.decode(response.body);

      print(responseData);

      if (responseData['success'] == true) {
        var itemData = responseData['data'];

        if (itemData != null) {
          return DeliveryChallan.fromMap(itemData);
        } else {
          return null;
        }
      } else {
        print('${responseData['message']}');
        return null;
      }
    } catch (error) {
      print(error.toString());
      return null;
    }
  }
}
