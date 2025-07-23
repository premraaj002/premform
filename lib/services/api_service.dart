import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/form_model.dart';
import '../models/response_model.dart';

class ApiService extends ChangeNotifier {
  static const String baseUrl = 'http://localhost:8000/api'; // Your Python backend URL
  
  List<FormModel> _forms = [];
  List<FormModel> get forms => _forms;

  Future<List<FormModel>> getForms() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/forms'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _forms = data.map((json) => FormModel.fromJson(json)).toList();
        notifyListeners();
        return _forms;
      } else {
        throw Exception('Failed to load forms: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching forms: $e');
      // For development: use mock data if backend is not available
      _forms = _getMockForms();
      notifyListeners();
      return _forms;
    }
  }

  Future<FormModel> createForm(FormModel form) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forms'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(form.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final FormModel newForm = FormModel.fromJson(json.decode(response.body));
        _forms.add(newForm);
        notifyListeners();
        return newForm;
      } else {
        throw Exception('Failed to create form: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating form: $e');
      // For development: save locally
      _forms.add(form);
      notifyListeners();
      return form;
    }
  }

  Future<FormModel> updateForm(FormModel form) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/forms/${form.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(form.toJson()),
      );

      if (response.statusCode == 200) {
        final FormModel updatedForm = FormModel.fromJson(json.decode(response.body));
        final index = _forms.indexWhere((f) => f.id == form.id);
        if (index != -1) {
          _forms[index] = updatedForm;
        } else {
          _forms.add(updatedForm);
        }
        notifyListeners();
        return updatedForm;
      } else {
        throw Exception('Failed to update form: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating form: $e');
      // For development: save locally
      final index = _forms.indexWhere((f) => f.id == form.id);
      if (index != -1) {
        _forms[index] = form;
      } else {
        _forms.add(form);
      }
      notifyListeners();
      return form;
    }
  }

  Future<void> deleteForm(String formId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/forms/$formId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        _forms.removeWhere((form) => form.id == formId);
        notifyListeners();
      } else {
        throw Exception('Failed to delete form: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting form: $e');
      // For development: delete locally
      _forms.removeWhere((form) => form.id == formId);
      notifyListeners();
    }
  }

  Future<FormModel> getFormById(String formId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/forms/$formId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return FormModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load form: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching form: $e');
      // For development: find locally
      final form = _forms.firstWhere((f) => f.id == formId);
      return form;
    }
  }

  Future<ResponseModel> submitResponse(ResponseModel response) async {
    try {
      final httpResponse = await http.post(
        Uri.parse('$baseUrl/responses'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(response.toJson()),
      );

      if (httpResponse.statusCode == 201 || httpResponse.statusCode == 200) {
        return ResponseModel.fromJson(json.decode(httpResponse.body));
      } else {
        throw Exception('Failed to submit response: ${httpResponse.statusCode}');
      }
    } catch (e) {
      print('Error submitting response: $e');
      // For development: return the response as-is
      return response;
    }
  }

  Future<List<ResponseModel>> getFormResponses(String formId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/forms/$formId/responses'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ResponseModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load responses: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching responses: $e');
      // For development: return empty list
      return [];
    }
  }

  // Mock data for development
  List<FormModel> _getMockForms() {
    return [];
  }
}
