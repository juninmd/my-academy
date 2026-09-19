// Constants used across the app

const String baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:9000/api/',
);
const String mockAuthToken = 'mock-token';
// Local homologation only: build with --dart-define=USE_MOCK_AUTH=true.
const bool useMockAuth = bool.fromEnvironment('USE_MOCK_AUTH');
