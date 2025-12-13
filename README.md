# muni-login-client gem

> **Note**: This repository was originally intended to host multiple Muni gems, but the architecture has evolved. It now contains only the `muni-login-client` gem, which provides authentication and authorization integration with the Muni Login Service.

A Ruby gem providing client-side authentication and authorization for the Muni Login Service. This gem enables Rails applications to integrate with the centralized SSO authentication system.

## Overview

The `muni-login-client` gem provides:

- **Session Authentication**: Cookie-based and JWT-based authentication
- **Identity Management**: Access to authenticated User, Admin, Customer, and ApiUser identities
- **Service Integration**: Communication with the login-service microservice
- **Logging**: Structured authentication logging with security considerations
- **Token Management**: Reference tokens, JWT encoding/decoding, and token validation
- **Caching**: Redis-backed identity caching for performance

## Architecture

### Core Components

**IdpRequest**: Request context containing authentication metadata (action signature, API vector, headers, cookies)

**IdpKeep**: Identity storage managing authenticated identities (admin, user, customer, api_user) and session metadata

**IdpLogger**: Structured logging for authentication events with security-conscious log levels

**IdpCache**: Redis-backed caching layer for identity data (15-minute default TTL)

**Wardens**: Authentication strategies (SidWarden for JWT tokens, VendorWarden for API keys)

**CookieReader**: Reads SID tokens from cookies

**Settings**: Centralized configuration using ActiveSupport::Configurable

### Authentication Flow

```
1. Request arrives with SID cookie or JWT token
2. CookieReader extracts token from request cookies
3. Warden validates token (JWT signature + expiration)
4. ServiceProxy calls login-service to authenticate
5. IdpKeep retrieves identity from database (cached via IdpCache)
6. Identity available to application via idkeep.admin, idkeep.user, etc.
```

## Development Workflow

### Setup

This gem is maintained by the SOA development meta and is part of the "login" stack:

```bash
bin/stacks/set login
bin/dc/build
```

### Run Specs

```bash
bin/dc/login/client/spec
```

Expected output:
```
X examples, 0 failures
```

### Build the Gem

```bash
bin/dc/login/client/make
```

This generates `vendor/gems/muni-login-client-0.0.41.gem` (or current version). You can see it from
the host system like so:
```bash
ls muni-gems/login-client/gem/*.gem
```

### Install Locally

```bash
gem install vendor/gems/muni-login-client-0.0.41.gem
gem list | grep muni
```

### Remove Old Versions

```bash
gem cleanup muni-login-client
```

## Configuration

### Required Environment Variables

```bash
# SID cookie configuration
MUNI_SID_COOKIE_NAME="muni_sid"              # Session cookie name
MUNI_SID_COOKIE_DURATION="PT168H"            # ISO 8601 duration (default: 7 days)

# Login service discovery
LOGIN_SERVICE_URL_LIST="http://login.munidev.local:5401,http://login-service:5401"

# Redis configuration for identity cache
REDIS_NAMESPACE="munidev"                     # Namespace for cache keys
MUNI_IDP_CACHE_DURATION="PT15M"              # ISO 8601 duration (default: 15 minutes)

# Security secrets
REF_TOKEN_SECRET="your-reference-token-secret"
MUNI_API_SECRETS_CSV="secret1,secret2,secret3"  # CSV list of valid API secrets

# Development-only: Enable trace logging (NEVER in production)
MUNIDEV_IDPLOG_TRACE="true"                   # Enables IdpLogger.trace() output
```

### Initializer Configuration

```ruby
# config/initializers/muni_login_client.rb
Muni::Login::Client::Settings.configure do |config|
  config.sid_cookie_name = ENV['MUNI_SID_COOKIE_NAME']
  config.sid_cookie_duration = 7.days
  config.idpc_app_name = 'billing'
  config.idpc_redis_bucket = ENV['REDIS_NAMESPACE']
  config.idpc_retention = 15.minutes
  config.login_service_url_list = ENV['LOGIN_SERVICE_URL_LIST']
  config.log_trace_enabled = false  # NEVER true in production
  config.api_secrets_csv = ENV['MUNI_API_SECRETS_CSV']
end
```

## Usage Examples

### Basic Authentication

```ruby
# In your controller
class ApplicationController < ActionController::Base
  before_action :authenticate_session!

  private

  def authenticate_session!
    # Initialize request context
    idrequest = Muni::Security::IdpRequest.new(
      request: request,
      action_signature: "#{controller_name}##{action_name}",
      api_vector: 'web'
    )

    # Initialize identity storage
    idkeep = Muni::Login::Client::IdpKeep.new

    # Authenticate via SID warden
    warden = Muni::Login::Client::Wardens::SidWarden.new(
      idrequest: idrequest,
      idkeep: idkeep
    )
    warden.authorize!

    # Now you can access authenticated identity
    @current_admin = idkeep.admin
    @current_user = idkeep.user
    @current_customer = idkeep.customer
  end
end
```

### Logging

```ruby
# Create logger
authlog = Muni::Security::AuthLogger.new(idrequest)

# trace() - For debugging only (disabled in production)
# Use for sensitive data: tokens, credentials, session IDs
authlog.trace(
  location: "SessionsController.create",
  token_digest: Digest::SHA256.hexdigest(token),
  action: 'validate'
)

# info() - For production logging
# NEVER log sensitive data at this level
authlog.info(
  location: "SessionsController.create",
  user_id: 123,
  action: 'login_success'
)

# warn() - For suspicious activity
authlog.warn(
  location: "SessionsController.create",
  ip_address: request.remote_ip,
  event: 'invalid_token_format'
)

# error() - For authentication failures
authlog.error(
  location: "SessionsController.create",
  event: 'authentication_failed',
  reason: 'expired_token'
)
```

**Security Notes:**
- `trace()` is automatically disabled in production (controlled by `MUNIDEV_IDPLOG_TRACE`)
- Never log raw tokens, passwords, or PII at info/warn/error levels
- Use SHA256 digests when logging token identifiers

### Identity Cache Management

```ruby
# Clear cache for specific identity (after database update)
idkeep = Muni::Login::Client::IdpKeep.new(secure_identity: secure_identity)
idkeep.clear_cache

# Clear entire keep (sign-out)
idkeep.clear
```

### API Authentication

```ruby
# System-to-system API authentication
idkeep = Muni::Login::Client::IdpKeep.new
api_token = idkeep.system_api_token  # "API_KEY:API_SECRET" format

# Use in HTTP requests
headers = { 'X-API-TOKEN' => api_token }
```

### Cookie Management

```ruby
# Read SID token from cookies
cookie_reader = Muni::Login::Client::CookieReader.new(
  plain_cookies: cookies,
  top_level_domain: '.munibilling.com'
)
sid_token = cookie_reader.sid_token

# Delete SID cookie (sign-out)
cookie_reader.delete_sid_token
```

## Error Handling

The gem raises specific exceptions for different failure modes:

```ruby
begin
  warden.authorize!
rescue Muni::Login::Client::Errors::Unauthorized => e
  # Invalid credentials
  render json: { error: 'Unauthorized' }, status: 401

rescue Muni::Login::Client::Errors::Forbidden => e
  # Valid identity but insufficient permissions
  render json: { error: 'Forbidden' }, status: 403

rescue Muni::Login::Client::Errors::MalformedIdentity => e
  # Invalid token format or expired token
  render json: { error: 'Invalid session' }, status: 401

rescue Muni::Login::Client::Errors::BadGateway => e
  # Login service unavailable
  render json: { error: 'Service unavailable' }, status: 502

rescue Muni::Login::Client::Errors::BadConfiguration => e
  # Missing or invalid configuration
  Rails.logger.error("Login client misconfigured: #{e.message}")
  render json: { error: 'Configuration error' }, status: 500
end
```

## Testing

### RSpec Integration

```ruby
# spec/support/auth_helpers.rb
module AuthHelpers
  def mock_authenticated_admin(admin)
    secure_identity = create(:secure_identity, mod: admin)
    allow_any_instance_of(Muni::Login::Client::IdpKeep)
      .to receive(:admin).and_return(admin)
    allow_any_instance_of(Muni::Login::Client::IdpKeep)
      .to receive(:secure_identity).and_return(secure_identity)
  end
end

# In your specs
RSpec.describe SessionsController, type: :controller do
  include AuthHelpers

  let(:admin) { create(:admin) }

  before do
    mock_authenticated_admin(admin)
  end

  it 'allows authenticated access' do
    get :show
    expect(response).to be_successful
  end
end
```

### Mocking IdpLogger

```ruby
# Use correct class for instance_double
let(:idrequest) { instance_double(Muni::Security::IdpRequest, action_signature: 'users#show', api_vector: 'web') }
let(:authlog) { instance_double(Muni::Security::AuthLogger, trace: true, info: true, warn: true, error: true) }

# NOT ActiveSupport::Logger - AuthLogger has different methods
```

## Integration with Muni Services

### Billing Application (muni-billing/legacy)

Uses login-client for admin and user authentication:
- `Muni::Security::AuthLogger` wraps `IdpLogger`
- `Muni::Security::CookieInjector` manages SID cookies
- `Muni::Security::IdpRequest` provides request context

### Customer Portal API (customer-portal/api)

Uses login-client for customer authentication:
- Validates customer sessions via `Wardens::SidWarden`
- Supports customer observation mode for admin viewing

### Microservices (login-service, paylib-service, core-connect)

All microservices use login-client for service-to-service authentication via API tokens.

## Troubleshooting

### "Class does not implement instance method: debug"

**Problem**: Using `instance_double(ActiveSupport::Logger, debug: true)` for AuthLogger

**Solution**: Use `instance_double(Muni::Security::AuthLogger, trace: true, info: true, warn: true, error: true)`

### "mon out of range" with Timecop

**Problem**: Timecop 0.9.10 incompatible with Ruby 3.3.7

**Solution**: Stub `Time.zone.parse` directly instead of using Timecop:
```ruby
let(:expected_time) { ActiveSupport::TimeZone.new('Eastern Time (US & Canada)').parse('2025-01-15 13:00:00') }
before do
  allow(Time.zone).to receive(:parse).and_return(expected_time)
end
```

### "api_secrets_csv not set"

**Problem**: `MUNI_API_SECRETS_CSV` environment variable missing

**Solution**: Set in `.env` or environment:
```bash
export MUNI_API_SECRETS_CSV="secret1,secret2,secret3"
```

### Session not persisting

**Problem**: Redis connection issues or namespace mismatch

**Solution**: Verify Redis configuration:
```ruby
# Check Redis connection
Redis.new(host: ENV['REDIS_HOST'], port: ENV['REDIS_PORT']).ping
# => "PONG"

# Check namespace
Muni::Login::Client::Settings.new.idpc_redis_bucket
# => "munidev"
```

## Version History

**Current Version**: 0.0.41

See `muni-login-client.gemspec` and `lib/muni/login/client/idp_logger.rb` for version number (kept in sync).

## References

- Login Service Documentation: `login-service/README.md`
- Authentication Flow: `muni-billing/legacy/lib/muni/security/`
- Gem Development Guide: https://guides.rubygems.org/make-your-own-gem/
