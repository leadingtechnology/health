# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Health assistant application with multi-language support, subscription tiers, and legal consent management:
- **Backend API**: .NET 8 RESTful API (`apps/health_api/`) with JWT authentication, quota management, care circles, and OpenAI integration
- **Mobile App**: Flutter Material 3 application (`apps/health_app/`) with internationalization (11 languages)
- **Database**: PostgreSQL with `health` schema including users, care circles, patients, conversations, and consent tracking
- **Testing**: Unit tests in `apps/health_api.Tests/`

## Development Commands

### Backend (.NET API)
```bash
# Navigate to API directory
cd apps/health_api

# Restore packages
dotnet restore

# Set encryption key (required for API key encryption)
# Windows PowerShell:
setx KEYRING_MASTER_KEY ([Convert]::ToBase64String((New-Object byte[] 32 | % {[void](New-Object System.Security.Cryptography.RNGCryptoServiceProvider).GetBytes($_)})))
# Linux/Mac:
export KEYRING_MASTER_KEY=$(openssl rand -base64 32)

# Run in development (uses PostgreSQL via ConnectionStrings:DefaultConnection)
dotnet run

# Build
dotnet build

# Run tests
cd ../health_api.Tests
dotnet test

# Generate Swagger docs (available at /swagger when running)
```

### Flutter App
```bash
# Navigate to app directory
cd apps/health_app

# Install dependencies
flutter pub get

# Generate localization files
flutter gen-l10n

# Run on connected device/emulator
flutter run

# Analyze code for issues
flutter analyze

# Run Dart analyzer
dart analyze

# Build APK
flutter build apk

# Build iOS (Mac only)
flutter build ios
```

### Database Setup
```bash
# Connect to Google Cloud SQL
gcloud sql connect racketrallydb --user=postgres --database=postgres --project=ldtech

# Initialize database with all migrations
\encoding UTF8
\set ON_ERROR_STOP on
\i D:/ldtech/health/health/Database/health_postgres.sql
\i D:/ldtech/health/health/Database/fix_citext_enable.sql
\i D:/ldtech/health/health/Database/migration_add_platinum_plan.sql
\i D:/ldtech/health/health/Database/add_multimedia_support.sql
\i D:/ldtech/health/health/Database/sql_user_consents.sql

# Switch to health database and set schema
\c racketrally
SET search_path TO health, public;
```

## Architecture

### Backend API Structure
- **Authentication**: JWT-based with Bearer tokens, OTP verification for registration
- **User Management**: Quota system (3 free questions/day), subscription plans (free/standard/pro/platinum)
- **Care Circles**: Family/care group management with role-based access (owner/admin/member)
- **OpenAI Integration**: Secure API key storage (AES-GCM encryption), quota-gated proxy endpoint
- **Legal Compliance**: Consent management system with versioned legal documents in multiple languages
- **Database**: Entity Framework Core with PostgreSQL, Npgsql with enum mappings for plan_type and model_tier
- **CORS**: Configured for production domain and localhost development

### Key API Endpoints
- **Auth**: `POST /api/auth/register`, `POST /api/auth/login`, `POST /api/auth/verify-otp`
- **User**: `GET /api/users/me`, `GET /api/users/me/quota`, `PUT /api/users/me`
- **Plans**: `GET /api/plans` (public endpoint for subscription tiers with pricing)
- **Circles**: `GET/POST /api/circles`, `POST /api/circles/{id}/members`
- **Patients**: `GET/POST /api/patients`, `PUT /api/patients/{id}`
- **Conversations**: `GET/POST /api/conversations`, `GET /api/conversations/{id}/messages`
- **OpenAI**: `POST /api/openai/ask` (quota-gated proxy)
- **Legal**: `GET /api/legal/documents/{locale}`, `POST /api/consents/record`
- **Settings**: `GET/POST /api/orgsettings/openai` (admin only)

### Database Schema
- PostgreSQL with `health` schema namespace
- Core tables: `users`, `care_circles`, `care_circle_members`, `patients`, `conversations`, `user_consents`
- Quota management: `quota_usages` table with built-in functions `fn_quota_try_consume()`, `fn_quota_get()`
- Security: `api_key_secrets` for encrypted storage, `share_grants` for access control
- Audit: Triggers for automatic timestamp updates and audit logging
- Timezone-aware quota resets with daily/monthly tracking

### Flutter App Architecture
- **State Management**: Provider pattern with `AppState` for global state
- **Services**: Dedicated service classes for API communication (`AuthService`, `ConsentService`)
- **Routing**: Named routes with authentication guards
- **UI Components**: Material 3 design system with custom widgets
- **Localization**: 11 languages (en, zh, ja, ko, es, fr, de, pt, ru, vi) via flutter_localizations
- **Storage**: SharedPreferences for JWT tokens and user preferences
- **Image Handling**: Image picker with permission handling, cached network images

## Important Configurations

### Required Environment Variables
- `KEYRING_MASTER_KEY`: Base64-encoded 32-byte key for AES-GCM encryption (REQUIRED)
- `Jwt__SigningKey`: JWT signing key (minimum 32 characters)
- `Jwt__Issuer`: JWT issuer (defaults to https://app.ldetch.co.jp)
- `Jwt__Audience`: JWT audience (defaults to https://app.ldetch.co.jp)
- `ConnectionStrings__DefaultConnection`: PostgreSQL connection string
- `Cors__AllowedOrigins`: Array of allowed CORS origins

### Domain Configuration
- Primary domain: `ldetch.co.jp`
- App subdomain: `app.ldetch.co.jp`
- API endpoints configured for both production and localhost:5173 (dev)

### Legal Documents Structure
- Documents stored in `wwwroot/legal/{locale}/` directories
- Supported types: privacy_policy, terms_of_service, data_processing_consent, cross_border_transfer
- SHA256 hashing for version tracking and consent validation