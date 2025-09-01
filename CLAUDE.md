# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a health assistant application with:
- **Backend API**: .NET 8 RESTful API (`apps/health_api/`) with JWT authentication, quota management, care circles, and OpenAI integration
- **Mobile App**: Flutter Material 3 application (`apps/health_app/`)
- **Database**: PostgreSQL schema (`Database/health_postgres.sql`) with health schema including users, care circles, patients, conversations

## Development Commands

### Backend (.NET API)
```bash
# Navigate to API directory
cd apps/health_api

# Restore packages
dotnet restore

# Set encryption key (required for API key encryption)
# Linux/Mac:
export KEYRING_MASTER_KEY=$(openssl rand -base64 32)
# Windows PowerShell:
setx KEYRING_MASTER_KEY ([Convert]::ToBase64String((New-Object byte[] 32 | % {[void](New-Object System.Security.Cryptography.RNGCryptoServiceProvider).GetBytes($_)})))

# Run in development (uses SQLite by default)
dotnet run

# Build
dotnet build

# Run tests (if available)
dotnet test
```

### Flutter App
```bash
# Navigate to app directory
cd apps/health_app

# Install dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Build APK
flutter build apk

# Build iOS (Mac only)
flutter build ios

# Analyze code
flutter analyze
```

### Database Setup
```bash
# Connect to Google Cloud SQL
gcloud sql connect racketrallydb --user=postgres --database=postgres --project=ldtech

# Initialize database
\encoding UTF8
\i D:/ldtech/health/halth/Database/health_postgres.sql

# Switch to health database
\c racketrally
SET search_path TO health, public;
```

## Architecture

### Backend API Structure
- **Authentication**: JWT-based with Bearer tokens (`/api/auth/`)
- **User Management**: Quota system (3 free questions/day), user plans (free/standard/pro)
- **Care Circles**: Family/care group management with owner/admin/member roles
- **OpenAI Integration**: Secure API key storage (AES-GCM encryption), proxy endpoint at `/api/openai/ask`
- **Database**: Entity Framework Core with support for both SQLite (dev) and PostgreSQL (prod)
- **CORS**: Configured for `https://app.ldetch.co.jp` and localhost ports

### Key API Endpoints
- Auth: `POST /api/auth/register`, `POST /api/auth/login`
- User: `GET /api/users/me`, `GET /api/users/me/quota`
- Circles: `GET/POST /api/circles`, `POST /api/circles/{id}/members`
- Patients: `GET/POST /api/patients`
- Conversations: `GET/POST /api/conversations`
- OpenAI: `POST /api/openai/ask` (quota-gated proxy)
- Settings: `GET/POST /api/orgsettings/openai` (admin only)

### Database Schema
- Uses PostgreSQL with `health` schema
- Key tables: `users`, `care_circles`, `care_circle_members`, `patients`, `conversations`, `share_grants`, `quota_usages`, `api_key_secrets`
- Built-in functions for quota management: `fn_quota_try_consume()`, `fn_quota_get()`
- Audit logging with triggers
- Support for timezone-aware quota resets

### Flutter App
- Material 3 design system
- Provider for state management
- SharedPreferences for local storage
- Internationalization support (l10n)

## Important Configurations

### Required Environment Variables
- `KEYRING_MASTER_KEY`: Base64-encoded 32-byte key for AES-GCM encryption (required)
- `Jwt__SigningKey`: JWT signing key (≥32 characters recommended)
- `ConnectionStrings__Default`: Database connection (defaults to SQLite)

### Domain Configuration
- Primary domain: `ldetch.co.jp`
- App subdomain: `app.ldetch.co.jp`
- CORS and JWT issuer/audience configured for these domains