part of 'implementation.dart';

SqliteException createExceptionRaw(
    Bindings bindings, Pointer<sqlite3> db, int returnCode,
    [String? previousStatement]) {
  // Getting hold of more explanatory error code as SQLITE_IOERR error group has
  // an extensive list of extended error codes
  final extendedCode = bindings.sqlite3_extended_errcode(db);
  return createExceptionFromExtendedCode(
      bindings, db, returnCode, extendedCode, previousStatement);
}

SqliteException createExceptionFromExtendedCode(Bindings bindings,
    Pointer<sqlite3> db, int returnCode, int extendedErrorCode,
    [String? previousStatement]) {
  // We don't need to free the pointer returned by sqlite3_errmsg: "Memory to
  // hold the error message string is managed internally. The application does
  // not need to worry about freeing the result."
  // https://www.sqlite.org/c3ref/errcode.html
  final dbMessage = bindings.sqlite3_errmsg(db).readString();

  final errStr = bindings.sqlite3_errstr(extendedErrorCode).readString();
  final explanation = '$errStr (code $extendedErrorCode)';

  return SqliteException(returnCode, dbMessage, explanation, previousStatement);
}

SqliteException createException(DatabaseImpl db, int returnCode,
    [String? previousStatement]) {
  final bindings = db._bindings;
  final handle = db._finalizable._handle;

  return createExceptionRaw(bindings, handle, returnCode, previousStatement);
}

Never throwException(DatabaseImpl db, int returnCode,
    [String? previousStatement]) {
  throw createException(db, returnCode, previousStatement);
}
