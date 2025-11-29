import 'package:flutter/material.dart';
import '../../../data/models/event.dart';
import '../../../data/repositories/event_repository.dart';

class EventCreateScreen extends StatefulWidget {
  const EventCreateScreen({super.key});

  @override
  State<EventCreateScreen> createState() => _EventCreateScreenState();
}

class _EventCreateScreenState extends State<EventCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dateCtrl.dispose();
    _locationCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _saveEvent() {
    if (!_formKey.currentState!.validate()) return;
    final repo = EventRepository();
    final event = EventModel(
      name: _nameCtrl.text,
      date: _dateCtrl.text,
      location: _locationCtrl.text,
      description: _descCtrl.text,
      organizer: '',
      website: '',
    );
    repo.saveEvent(event).then((_) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event created')));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Create Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(labelText: 'Event Name', labelStyle: TextStyle(color: Colors.grey[400]), filled: true, fillColor: Colors.grey[900], border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
                validator: (v) => v == null || v.isEmpty ? 'Name required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dateCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(labelText: 'Date', labelStyle: TextStyle(color: Colors.grey[400]), filled: true, fillColor: Colors.grey[900], border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(labelText: 'Location', labelStyle: TextStyle(color: Colors.grey[400]), filled: true, fillColor: Colors.grey[900], border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                style: const TextStyle(color: Colors.white),
                maxLines: 5,
                decoration: InputDecoration(labelText: 'Description', labelStyle: TextStyle(color: Colors.grey[400]), filled: true, fillColor: Colors.grey[900], border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveEvent,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1F6DB4)),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Save Event', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
