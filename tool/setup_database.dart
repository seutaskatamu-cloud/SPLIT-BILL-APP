// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Idempotent schema migration for Neon PostgreSQL.
/// Run with: `dart run tool/setup_database.dart`
/// Credentials are read from the project `.env` file (never hardcoded).
Map<String, String> _loadEnv() {
  final file = File('.env');
  if (!file.existsSync()) {
    print('ERROR: .env not found. Copy .env.example to .env and fill DB_* values.');
    exit(1);
  }
  final env = <String, String>{};
  for (final raw in file.readAsLinesSync()) {
    final line = raw.trim();
    if (line.isEmpty || line.startsWith('#') || !line.contains('=')) continue;
    final idx = line.indexOf('=');
    env[line.substring(0, idx).trim()] = line.substring(idx + 1).trim();
  }
  return env;
}

void main() async {
  final env = _loadEnv();
  print('Connecting to Neon PostgreSQL via Serverless HTTP...');

  final host = env['DB_HOST'] ?? '';
  final username = env['DB_USER'] ?? '';
  final password = env['DB_PASSWORD'] ?? '';
  final database = env['DB_NAME'] ?? 'neondb';

  if (host.isEmpty || username.isEmpty || password.isEmpty) {
    print('ERROR: Missing DB_HOST, DB_USER, or DB_PASSWORD in .env');
    exit(1);
  }

  final url = Uri.parse('https://$host/sql');
  final connectionString =
      'postgresql://$username:$password@$host/$database?sslmode=require';
  final client = http.Client();

  final statements = [
    'CREATE EXTENSION IF NOT EXISTS "uuid-ossp";',
    'CREATE EXTENSION IF NOT EXISTS "pgcrypto";',
    '''CREATE TABLE IF NOT EXISTS users (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        email VARCHAR(255) UNIQUE NOT NULL,
        full_name VARCHAR(150) NOT NULL,
        phone_number VARCHAR(30),
        avatar_url TEXT,
        password_hash TEXT NOT NULL,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
    );''',
    '''CREATE TABLE IF NOT EXISTS groups (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        name VARCHAR(150) NOT NULL,
        category VARCHAR(50) DEFAULT 'General',
        icon_name VARCHAR(50) DEFAULT 'group',
        created_by UUID REFERENCES users(id) ON DELETE CASCADE,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
    );''',
    'ALTER TABLE groups ADD COLUMN IF NOT EXISTS description TEXT;',
    '''CREATE TABLE IF NOT EXISTS group_members (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        group_id UUID REFERENCES groups(id) ON DELETE CASCADE,
        user_id UUID REFERENCES users(id) ON DELETE CASCADE,
        role VARCHAR(20) DEFAULT 'member',
        joined_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(group_id, user_id)
    );''',
    'ALTER TABLE group_members ADD COLUMN IF NOT EXISTS display_name VARCHAR(150);',
    'ALTER TABLE group_members ADD COLUMN IF NOT EXISTS phone_number VARCHAR(30);',
    '''CREATE TABLE IF NOT EXISTS expenses (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        group_id UUID REFERENCES groups(id) ON DELETE CASCADE,
        payer_id UUID REFERENCES users(id) ON DELETE SET NULL,
        title VARCHAR(200) NOT NULL,
        total_amount NUMERIC(15, 2) NOT NULL,
        split_type VARCHAR(30) DEFAULT 'EQUAL',
        tax_amount NUMERIC(15, 2) DEFAULT 0.00,
        service_charge NUMERIC(15, 2) DEFAULT 0.00,
        bill_image_url TEXT,
        expense_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
    );''',
    'ALTER TABLE expenses ADD COLUMN IF NOT EXISTS category VARCHAR(50);',
    'ALTER TABLE expenses ADD COLUMN IF NOT EXISTS note TEXT;',
    '''CREATE TABLE IF NOT EXISTS expense_splits (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        expense_id UUID REFERENCES expenses(id) ON DELETE CASCADE,
        user_id UUID REFERENCES users(id) ON DELETE CASCADE,
        amount_owed NUMERIC(15, 2) NOT NULL,
        is_settled BOOLEAN DEFAULT FALSE,
        settled_at TIMESTAMP WITH TIME ZONE
    );''',
    '''CREATE TABLE IF NOT EXISTS settlements (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        group_id UUID REFERENCES groups(id) ON DELETE CASCADE,
        debtor_id UUID REFERENCES users(id) ON DELETE CASCADE,
        creditor_id UUID REFERENCES users(id) ON DELETE CASCADE,
        amount NUMERIC(15, 2) NOT NULL,
        proof_image_url TEXT,
        status VARCHAR(30) DEFAULT 'COMPLETED',
        settled_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
    );''',
    'ALTER TABLE settlements ADD COLUMN IF NOT EXISTS method VARCHAR(50);',
    'CREATE INDEX IF NOT EXISTS idx_expenses_group ON expenses(group_id);',
    'CREATE INDEX IF NOT EXISTS idx_splits_expense ON expense_splits(expense_id);',
    'CREATE INDEX IF NOT EXISTS idx_settlements_group ON settlements(group_id);',
    'CREATE INDEX IF NOT EXISTS idx_members_group ON group_members(group_id);',
  ];

  try {
    print('Executing SQL statements one by one...');
    for (int i = 0; i < statements.length; i++) {
      final resp = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Neon-Connection-String': connectionString,
        },
        body: jsonEncode({'query': statements[i]}),
      );
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        print('Executed statement #${i + 1}');
      } else {
        print('Error on statement #${i + 1} (${resp.statusCode}): ${resp.body}');
      }
    }

    // Verify tables
    final tablesResp = await client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Neon-Connection-String': connectionString,
        'Neon-Array-Mode': 'true',
      },
      body: jsonEncode({
        'query':
            "SELECT table_name FROM information_schema.tables WHERE table_schema='public' ORDER BY table_name;",
      }),
    );

    if (tablesResp.statusCode >= 200 && tablesResp.statusCode < 300) {
      final data = jsonDecode(tablesResp.body);
      print('\nConfirmed tables in Neon PostgreSQL:');
      if (data['rows'] is List) {
        for (final row in data['rows']) {
          print(' - ${row[0]}');
        }
      }
    }

    client.close();
    print('\nDatabase schema verification complete!');
  } catch (e, stack) {
    print('Failed to setup database: $e');
    print(stack);
    exit(1);
  }
}
