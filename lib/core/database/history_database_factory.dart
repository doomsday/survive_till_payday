import 'app_database.dart';
import 'history_database_factory_native.dart'
    if (dart.library.js_interop) 'history_database_factory_web.dart'
    as platform;

Future<AppDatabase> createHistoryDatabase() => platform.createHistoryDatabase();
