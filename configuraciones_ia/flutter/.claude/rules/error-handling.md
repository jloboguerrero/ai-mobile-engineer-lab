# Error handling

Two layers, no `dartz`, no generic `Failure` class hierarchy.

## HTTP boundary — `Result<T, E>` (e.g. the `oxidized` package)

Confined to the HTTP client layer only:

```dart
@override
Future<Result<HttpResponse, AppException>> get(
  String url, {
  Map<String, dynamic>? queryParameters,
}) async {
  try {
    final response = await client.get(url, queryParameters: queryParameters);
    return Result.ok(_handleResponse(response));
  } catch (error) {
    return Result.err(HttpClientError.processError(error));
  }
}
```

## Datasource — unwraps, doesn't propagate `Result`

```dart
final data = result.unwrap().data; // throws on error
```

Datasources return plain `Future<T>`, not `Future<Result<T, E>>`. `unwrap()` throws the
typed exception on failure, so repositories and usecases above the datasource also have
plain `Future<T>` signatures — no `Result` type leaks past the HTTP layer.

## Typed exceptions

```dart
class AppException implements Exception {
  const AppException({required this.message, this.code = -1});
  final String message;
  final int code;
}
```

Subclasses: `final class ... extends AppException` with a sensible default message —
`NetworkException`, `ServerException`, `UnauthorizedException`, `NotFoundException`,
`BadRequestException`, `UnknownException`, etc.

## Where try/catch lives: the bloc

The bloc — not the repository, not the usecase — is where exceptions are caught and
turned into UI-facing error states:

```dart
try {
  final result = await _resetPasswordUsecase.execute(...);
  if (isClosed) return;
  emit(SendedResetPasswordState(state.model));
} catch (_) {
  if (isClosed) return;
  emit(ErrorSendResetPasswordState(state.model));
}
```

**Never let a raw exception reach the UI unhandled.** If you're writing a repository or
usecase and tempted to add a try/catch there, stop — that responsibility belongs to the
bloc that calls it, unless the project has explicitly established otherwise.
