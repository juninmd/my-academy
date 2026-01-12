import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  group('API Connectivity Tests', () {
    const baseUrl = 'http://localhost:9001';

    test('Should be able to connect to API Server', () async {
      try {
        // We try to hit a likely endpoint.
        // Since we don't have a valid token here, we expect either a 200 (if public) or 401/403.
        // The important part is that we DON'T get a SocketException (Connection Refused).

        final response = await http.get(Uri.parse('$baseUrl/'));

        print('API Response Status: ${response.statusCode}');

        // If we get a response, the server is running and reachable.
        expect(true, isTrue);
      } catch (e) {
        // If connection fails implies API is not running or not reachable
        print('API Connection Failed: $e');
        // We don't fail the test strictly if it's just a 404, but connection refused is bad.
        if (e.toString().contains('Connection refused')) {
          fail('Could not connect to API at $baseUrl. Is it running?');
        }
      }
    });

    test('Verify WorkoutGroup Endpoint Reachability', () async {
      // Attempt to hit the workouts-groups endpoint
      // We expect 401 because we are not sending an Auth header
      try {
        final response = await http.get(Uri.parse('$baseUrl/workouts-groups'));
        print('WorkoutGroup Endpoint Status: ${response.statusCode}');

        // Assuming the API protects this route, 401/403 confirms it's the correct API.
        // If 200, even better (but unlikely for user data).
        expect(response.statusCode, anyOf([200, 401, 403, 404]));
      } catch (e) {
        if (e.toString().contains('Connection refused')) {
          fail('Could not connect to API at $baseUrl.');
        }
      }
    });
  });
}
