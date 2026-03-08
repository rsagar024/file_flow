class Failure {
  final String message;

  Failure([this.message = 'Something went wrong !']);

  factory Failure.handleException(Object e) {
    return Failure(e.toString());
  }
}