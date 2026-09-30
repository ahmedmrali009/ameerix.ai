import 'package:flutter/foundation.dart';

enum ContactRequestType { demo, contact }

/// Stable, language-independent identifiers for the industry dropdown.
/// Labels are localised in the UI; the backend always receives these ids.
enum IndustryOption {
  gourmetFood('gourmet_food'),
  cosmetics('cosmetics_personal_care'),
  furniture('furniture_interiors'),
  hospitalityConstruction('hospitality_construction_supplies'),
  gccTrade('gcc_import_distribution'),
  advisory('association_chamber_consultancy'),
  other('other');

  const IndustryOption(this.id);
  final String id;
}

/// Payload sent to the contact/demo backend.
@immutable
class ContactRequest {
  const ContactRequest({
    required this.type,
    required this.firstName,
    required this.lastName,
    required this.company,
    required this.jobTitle,
    required this.email,
    required this.phone,
    required this.country,
    required this.industry,
    required this.message,
    required this.language,
    required this.consent,
  });

  final ContactRequestType type;
  final String firstName;
  final String lastName;
  final String company;
  final String jobTitle;
  final String email;
  final String phone;
  final String country;
  final IndustryOption industry;
  final String message;

  /// Language the visitor was using (useful for replying in kind).
  final String language;
  final bool consent;

  Map<String, Object?> toJson() => <String, Object?>{
        'type': type.name,
        'firstName': firstName,
        'lastName': lastName,
        'company': company,
        'jobTitle': jobTitle,
        'email': email,
        'phone': phone.isEmpty ? null : phone,
        'country': country,
        'industry': industry.id,
        'message': message,
        'language': language,
        'consent': consent,
        'source': 'website',
        'submittedAt': DateTime.now().toUtc().toIso8601String(),
      };
}
