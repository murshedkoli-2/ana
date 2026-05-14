import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:postgres/postgres.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  late Connection _connection;
  bool _initialized = false;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  /// Initialize database connection
  Future<void> init() async {
    if (_initialized) return;

    // Web doesn't support direct database connections
    if (kIsWeb) {
      print('⚠️  [DatabaseService] Running on web - database operations will be disabled');
      print('💡 Web app should use REST API instead of direct database connections');
      _initialized = true;
      return;
    }

    try {
      print('[DatabaseService] Initializing connection to Neon PostgreSQL...');
      
      // Connect to Neon PostgreSQL with SSL
      _connection = await Connection.open(
        Endpoint(
          host: 'ep-rapid-wind-apix3grh-pooler.c-7.us-east-1.aws.neon.tech',
          database: 'neondb',
          username: 'neondb_owner',
          password: 'npg_D6Y7ihKktSXa',
          port: 5432,
        ),
        settings: ConnectionSettings(
          sslMode: SslMode.require,
        ),
      );

      _initialized = true;
      print('✅ [DatabaseService] Connected to Neon PostgreSQL');
      print('📍 Host: ep-rapid-wind-apix3grh-pooler.c-7.us-east-1.aws.neon.tech');
      print('🗄️  Database: neondb');
    } catch (e) {
      print('❌ [DatabaseService] Failed to initialize: $e');
      rethrow;
    }
  }

  /// Extract parameter names from SQL and create map from list
  Map<String, dynamic> _extractAndMapParameters(String sql, List<Object?> params) {
    final Map<String, dynamic> paramMap = {};
    
    // Find all @paramName occurrences in SQL
    final regex = RegExp(r'@(\w+)');
    final matches = regex.allMatches(sql);
    
    // Map each parameter name to values from the list
    int index = 0;
    for (final match in matches) {
      final paramName = match.group(1)!;
      if (index < params.length) {
        paramMap[paramName] = params[index];
        index++;
      }
    }
    
    return paramMap;
  }

  /// Execute a query and return rows as maps
  Future<List<Map<String, dynamic>>> query(
    String sql, [
    List<Object?> substitutionValues = const [],
  ]) async {
    if (kIsWeb) {
      throw UnsupportedError(
        'Direct database queries are not supported on web. '
        'Please use the REST API instead.'
      );
    }

    if (!_initialized) throw Exception('DatabaseService not initialized');

    try {
      final paramMap = _extractAndMapParameters(sql, substitutionValues);
      
      final result = await _connection.execute(
        Sql.named(sql),
        parameters: paramMap,
      );
      
      return result.map((row) => row.toColumnMap()).toList();
    } catch (e) {
      print('❌ [DatabaseService] Query error: $e');
      print('   SQL: $sql');
      print('   Params: $substitutionValues');
      rethrow;
    }
  }

  /// Execute a single row query
  Future<Map<String, dynamic>?> querySingle(
    String sql, [
    List<Object?> substitutionValues = const [],
  ]) async {
    final results = await query(sql, substitutionValues);
    return results.isNotEmpty ? results.first : null;
  }

  /// Execute update/insert/delete
  Future<int> execute(
    String sql, [
    List<Object?> substitutionValues = const [],
  ]) async {
    if (kIsWeb) {
      throw UnsupportedError(
        'Direct database operations are not supported on web. '
        'Please use the REST API instead.'
      );
    }

    if (!_initialized) throw Exception('DatabaseService not initialized');

    try {
      final paramMap = _extractAndMapParameters(sql, substitutionValues);
      
      final result = await _connection.execute(
        Sql.named(sql),
        parameters: paramMap,
      );
      return result.rowsAffected;
    } catch (e) {
      print('❌ [DatabaseService] Execute error: $e');
      print('   SQL: $sql');
      print('   Params: $substitutionValues');
      rethrow;
    }
  }

  /// Dispose database connection
  Future<void> dispose() async {
    if (_initialized && !kIsWeb) {
      await _connection.close();
      _initialized = false;
      print('[DatabaseService] Connection closed');
    }
  }

  /// Check if database is initialized
  bool get isInitialized => _initialized;
}
