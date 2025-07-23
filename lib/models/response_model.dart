class ResponseModel {
  String id;
  String formId;
  Map<String, dynamic> answers;
  DateTime submittedAt;
  String? submitterEmail;

  ResponseModel({
    required this.id,
    required this.formId,
    required this.answers,
    required this.submittedAt,
    this.submitterEmail,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'form_id': formId,
      'answers': answers,
      'submitted_at': submittedAt.toIso8601String(),
      'submitter_email': submitterEmail,
    };
  }

  factory ResponseModel.fromJson(Map<String, dynamic> json) {
    return ResponseModel(
      id: json['id'],
      formId: json['form_id'],
      answers: json['answers'],
      submittedAt: DateTime.parse(json['submitted_at']),
      submitterEmail: json['submitter_email'],
    );
  }
}
