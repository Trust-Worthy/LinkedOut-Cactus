import 'dart:convert';
import '../../data/models/contact.dart';

class QRDataService {
  // Encode user profile + contacts into JSON for QR code
  static String encodeUserData(Contact userProfile, List<Contact> contacts) {
    final data = {
      'type': 'linkedout_profile',
      'profile': _contactToJson(userProfile),
      'contacts': contacts.map((c) => _contactToJson(c)).toList(),
    };
    return jsonEncode(data);
  }

  // Decode QR data back to profile + contacts
  static Map<String, dynamic>? decodeUserData(String qrContent) {
    try {
      final data = jsonDecode(qrContent) as Map<String, dynamic>;
      if (data['type'] != 'linkedout_profile') return null;
      
      return {
        'profile': _jsonToContact(data['profile'] as Map<String, dynamic>),
        'contacts': (data['contacts'] as List)
            .map((c) => _jsonToContact(c as Map<String, dynamic>))
            .toList(),
      };
    } catch (e) {
      return null;
    }
  }

  static Map<String, dynamic> _contactToJson(Contact contact) {
    return {
      'name': contact.name,
      'email': contact.email,
      'phone': contact.phone,
      'company': contact.company,
      'title': contact.title,
      'linkedin': contact.linkedin,
      'instagram': contact.instagram,
      'twitter': contact.twitter,
      'notes': contact.notes,
      'addressLabel': contact.addressLabel,
      'eventName': contact.eventName,
    };
  }

  static Contact _jsonToContact(Map<String, dynamic> json) {
    return Contact(
      name: json['name'] as String? ?? 'Unknown',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      company: json['company'] as String?,
      title: json['title'] as String?,
      linkedin: json['linkedin'] as String?,
      instagram: json['instagram'] as String?,
      twitter: json['twitter'] as String?,
      notes: json['notes'] as String?,
      addressLabel: json['addressLabel'] as String?,
      eventName: json['eventName'] as String?,
      metAt: DateTime.now(),
    );
  }
}
