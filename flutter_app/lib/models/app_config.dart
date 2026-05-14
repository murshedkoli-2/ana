class AppConfig {
  // Database Configuration (Direct Connection to Neon)
  // DATABASE_URL: postgresql://neondb_owner:npg_D6Y7ihKktSXa@ep-rapid-wind-apix3grh-pooler.c-7.us-east-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require
  
  static const String databaseHost = 'ep-rapid-wind-apix3grh-pooler.c-7.us-east-1.aws.neon.tech';
  static const String databaseName = 'neondb';
  static const String databaseUser = 'neondb_owner';
  static const String databasePassword = 'npg_D6Y7ihKktSXa';
  static const int databasePort = 5432;
  static const bool databaseSSL = true;
  
  static const String appName = 'ANA';
  static const String appVersion = '1.0.0';
  
  // UI Colors
  static const primaryColor = 0xFF3b82f6;
  static const successColor = 0xFF10b981;
  static const warningColor = 0xFFf59e0b;
  static const destructiveColor = 0xFFef4444;
  
  static const backgroundColor = 0xFFffffff;
  static const surfaceColor = 0xFFF9fafb;
  static const borderColor = 0xFFe5e7eb;
  
  static const textPrimary = 0xFF0f172a;
  static const textSecondary = 0xFF64748b;
  static const textTertiary = 0xFF94a3b8;
}
