import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event.dart';

class EventRepository {
  static const _kEventsKey = 'linkedout_events_v1';

  Future<List<EventModel>> getAllEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_kEventsKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    final List decoded = json.decode(jsonStr) as List;
    return decoded.map((e) => EventModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<void> saveEvent(EventModel event) async {
    final prefs = await SharedPreferences.getInstance();
    final events = await getAllEvents();
    events.insert(0, event);
    final enc = json.encode(events.map((e) => e.toJson()).toList());
    await prefs.setString(_kEventsKey, enc);
  }

  Future<void> deleteEvent(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final events = await getAllEvents();
    events.removeWhere((e) => e.name == name);
    final enc = json.encode(events.map((e) => e.toJson()).toList());
    await prefs.setString(_kEventsKey, enc);
  }
}
