import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/response_model.dart';

class ResponsesListScreen extends StatefulWidget {
  final String formId;

  const ResponsesListScreen({Key? key, required this.formId}) : super(key: key);

  @override
  _ResponsesListScreenState createState() => _ResponsesListScreenState();
}

class _ResponsesListScreenState extends State<ResponsesListScreen> {
  List<ResponseModel> _responses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadResponses();
  }

  Future<void> _loadResponses() async {
    try {
      final responses = await context.read<ApiService>().getFormResponses(widget.formId);
      setState(() {
        _responses = responses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading responses: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Form Responses'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadResponses,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _responses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No responses yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _responses.length,
                  itemBuilder: (context, index) {
                    final response = _responses[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 16),
                      child: ExpansionTile(
                        title: Text('Response ${index + 1}'),
                        subtitle: Text('Submitted: ${response.submittedAt.toString().split('.')[0]}'),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: response.answers.entries.map((entry) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Field ID: ${entry.key}',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text('Answer: ${entry.value}'),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
