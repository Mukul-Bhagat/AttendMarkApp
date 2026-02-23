import 'package:flutter_test/flutter_test.dart';
import 'package:attend_mark/models/session_model.dart';

void main() {
  group('SessionModel.fromJson', () {
    test('parses location object with geolocation safely', () {
      final model = SessionModel.fromJson({
        '_id': 'abc123',
        'name': 'Session A',
        'startTime': '10:00',
        'endTime': '11:00',
        'location': {
          'type': 'COORDS',
          'geolocation': {'latitude': 20.03888, 'longitude': 73.80420},
        },
      });

      expect(model.id, 'abc123');
      expect(model.title, 'Session A');
      expect(model.location, '20.03888, 73.8042');
    });

    test('parses location object with link safely', () {
      final model = SessionModel.fromJson({
        '_id': 'abc124',
        'name': 'Session B',
        'startTime': '10:00',
        'endTime': '11:00',
        'location': {
          'type': 'LINK',
          'link': 'https://meet.example.com/room',
        },
      });

      expect(model.location, 'https://meet.example.com/room');
    });

    test('prefers physicalLocation when present', () {
      final model = SessionModel.fromJson({
        '_id': 'abc125',
        'name': 'Session C',
        'startTime': '10:00',
        'endTime': '11:00',
        'physicalLocation': 'HQ Office',
        'location': {
          'type': 'COORDS',
          'geolocation': {'latitude': 1, 'longitude': 2},
        },
      });

      expect(model.location, 'HQ Office');
    });
  });
}
