import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/app_config.dart';
import '../../models/contact_request.dart';

enum SubmissionStatus { success, notConfigured, failed }

class SubmissionResult {
  const SubmissionResult(this.status, [this.detail]);

  final SubmissionStatus status;
  final String? detail;

  bool get isSuccess => status == SubmissionStatus.success;
}

/// Abstraction over the lead/contact backend.
///
/// Swap the implementation in [ContactService.fromConfig] to connect a CRM,
/// a serverless function, a form service or your own API.
abstract class ContactService {
  const ContactService();

  Future<SubmissionResult> submit(ContactRequest request);

  factory ContactService.fromConfig() {
    final endpoint = AppConfig.contactEndpoint.trim();
    if (endpoint.isEmpty) return const UnconfiguredContactService();
    return HttpContactService(Uri.parse(endpoint));
  }
}

/// Used when no endpoint is configured. It does NOT pretend to send anything.
class UnconfiguredContactService extends ContactService {
  const UnconfiguredContactService();

  @override
  Future<SubmissionResult> submit(ContactRequest request) async =>
      const SubmissionResult(SubmissionStatus.notConfigured);
}

/// Posts the request as JSON. Expects any 2xx response on success.
///
/// The endpoint must allow CORS from the website origin and should apply its
/// own validation, rate limiting and spam protection.
class HttpContactService extends ContactService {
  HttpContactService(this.endpoint, {http.Client? client, this.timeout = const Duration(seconds: 20)})
      : _client = client ?? http.Client();

  final Uri endpoint;
  final Duration timeout;
  final http.Client _client;

  @override
  Future<SubmissionResult> submit(ContactRequest request) async {
    try {
      final response = await _client
          .post(
            endpoint,
            headers: const <String, String>{
              'Content-Type': 'application/json; charset=utf-8',
              'Accept': 'application/json',
            },
            body: jsonEncode(request.toJson()),
          )
          .timeout(timeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return const SubmissionResult(SubmissionStatus.success);
      }
      return SubmissionResult(SubmissionStatus.failed, 'HTTP ${response.statusCode}');
    } on TimeoutException {
      return const SubmissionResult(SubmissionStatus.failed, 'timeout');
    } catch (e) {
      return SubmissionResult(SubmissionStatus.failed, e.toString());
    }
  }
}
