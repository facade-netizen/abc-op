String handleError(dynamic error) {
  final errorString = error.toString().toLowerCase();

  // Helper function
  String? matchError(Map<List<String>, String> rules) {
    for (final entry in rules.entries) {
      for (final pattern in entry.key) {
        if (errorString.contains(pattern)) {
          return entry.value;
        }
      }
    }
    return null;
  }

  //Network Errors (Essential)
  final networkErrors = {
    ['connection refused', 'connection reset', 'host unreachable', 'no route to host', 'server closed']: 'Server is currently unavailable. Please try again later.',
    ['connection timed out', 'timeout']: 'Server is not responding. Please try again later.',
    ['failed host lookup', 'cannot resolve host', 'unknown host']: 'Unable to reach server. Please check your internet connection.',
    ['socketexception', 'network']: 'Network error. Please check your connection.',
  };

  final networkResult = matchError(networkErrors);
  if (networkResult != null) return networkResult;

  //HTTP Errors (Most Common)
  final httpErrors = {
    ['400', 'bad request']: 'Invalid request. Please check your input.',
    ['401', 'unauthorized']: 'Authentication required. Please log in again.',
    ['403', 'forbidden']: 'You don\'t have permission to access this resource.',
    ['404', 'not found']: 'The requested resource was not found.',
    ['408', 'request timeout']: 'Request timed out. Please try again.',
    ['429', 'too many requests']: 'Too many requests. Try again later.',
    ['500', 'internal server error']: 'Server error. Please try again later.',
    ['502', 'bad gateway']: 'Server is temporarily down.',
    ['503', 'service unavailable']: 'Service is temporarily unavailable.',
    ['504', 'gateway timeout']: 'Server is taking too long to respond.',
  };

  final httpResult = matchError(httpErrors);
  if (httpResult != null) return httpResult;

  return 'Something went wrong. Please try again.';
}
