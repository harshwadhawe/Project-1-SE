# PC Builder Application - Logging Configuration Guide

## Overview
This application has been enhanced with comprehensive logging to help with debugging, monitoring, and understanding application behavior in production environments.

## Logging Levels and Categories

### Log Levels
- **DEBUG**: Detailed information for debugging (SQL queries, object initialization, method calls)
- **INFO**: General application flow and important events (user actions, business logic, performance metrics)
- **WARN**: Warning conditions (slow queries, validation failures, security events)
- **ERROR**: Error conditions (exceptions, failures, critical issues)

### Log Categories
Each log entry is prefixed with a category identifier:

#### Controller Logging
- `[REQUEST START/END]` - HTTP request lifecycle
- `[PERFORMANCE START/END]` - Action execution timing
- `[SLOW REQUEST]` - Requests taking > 1 second
- `[ERROR]` - Controller-level errors and exceptions
- `[*_CONTROLLER]` - Controller-specific actions (BUILD_CONTROLLER, PARTS_CONTROLLER, etc.)

#### Model Logging
- `[USER]` - User model operations (creation, validation, updates)
- `[BUILD]` - Build model operations (creation, part assignments, calculations)
- `[PART]` - Part model operations (creation, queries, updates)
- `[BUILD_ITEM]` - BuildItem model operations (part additions, quantities)
- `[*_VALIDATION]` - Model validation results
- `[*_QUERY]` - Database query operations
- `[SLOW_QUERY]` - Database queries taking > 500ms

#### Application-Level Logging
- `[APPLICATION]` - Application startup and configuration
- `[DATABASE]` - Database connection and configuration
- `[MEMORY]` - Memory usage monitoring
- `[SECURITY]` - Security-related events
- `[BUSINESS_LOGIC]` - Business rule enforcement
- `[USER_ACTIVITY]` - User behavior tracking
- `[API]` - External API interactions

#### Performance Logging
- `[PERFORMANCE]` - General performance metrics
- `[SLOW_OPERATION]` - Operations taking > 100ms
- `[SLOW_REQUEST]` - HTTP requests taking > 1 second
- `[SLOW_QUERY]` - Database queries taking > 500ms

## Environment-Specific Configuration

### Development Environment
- **Log Level**: DEBUG
- **Output**: Console + log/development.log
- **Features**: 
  - Colored output
  - Detailed SQL query logging
  - Request parameter logging
  - Memory usage monitoring
  - Full error backtraces

### Production Environment
- **Log Level**: INFO (configurable via RAILS_LOG_LEVEL environment variable)
- **Output**: STDOUT (structured JSON format)
- **Features**:
  - Structured JSON logging for log aggregation
  - Request ID tracking
  - User-Agent and IP logging
  - Log rotation (daily)
  - Performance monitoring
  - Security event logging

### Test Environment
- **Log Level**: WARN
- **Output**: Minimal logging to reduce test noise

## Key Features Added

### 1. Request Lifecycle Tracking
Every HTTP request is logged with:
- Request method and path
- User identification
- Request parameters (sanitized)
- Response status and timing
- Slow request detection

### 2. Database Operation Monitoring
All database operations are logged with:
- Query type and conditions
- Execution time
- Record counts
- Slow query detection
- Model lifecycle events (create, update, destroy)

### 3. User Activity Tracking
User actions are logged including:
- Authentication events
- Build creation and modification
- Part browsing and selection
- Session management

### 4. Performance Monitoring
Performance metrics tracked:
- Request response times
- Database query execution times
- Memory usage patterns
- Slow operation detection

### 5. Error Handling and Security
Comprehensive error logging:
- Exception details and backtraces
- Context information
- Security event detection
- Validation failure tracking

### 6. Business Logic Logging
Domain-specific logging for:
- Build creation workflow
- Part selection and validation
- User registration and management
- Price and wattage calculations

## Usage Examples

### Manual Logging in Controllers
```ruby
def create
  log_user_activity(current_user&.id, 'build_creation_started', { build_name: params[:build][:name] })
  
  # ... business logic ...
  
  log_business_logic('build_created', { build_id: @build.id, parts_count: @build.parts.count })
end
```

### Performance Monitoring
```ruby
log_performance('expensive_operation') do
  # Complex business logic here
end
```

### Database Query Logging
```ruby
Build.with_query_logging('loading_recent_builds') do
  Build.order(created_at: :desc).limit(10)
end
```

### Error Tracking
```ruby
begin
  # Risky operation
rescue StandardError => e
  log_error(e, { user_id: current_user&.id, action: 'build_creation' })
  raise
end
```

## Monitoring and Alerting

### Production Monitoring
In production, you can monitor:
- Error rates and patterns
- Performance degradation
- User activity patterns
- Database performance issues
- Security events

### Log Analysis
Recommended tools for log analysis:
- **ELK Stack** (Elasticsearch, Logstash, Kibana)
- **Splunk**
- **DataDog**
- **New Relic**
- **Sentry** (for error tracking)

### Key Metrics to Monitor
1. **Response Time**: Average and 95th percentile request times
2. **Error Rate**: Percentage of requests resulting in errors
3. **Database Performance**: Query execution times and slow query frequency
4. **User Activity**: Active users, build creation rates, part selection patterns
5. **Memory Usage**: Application memory consumption patterns

## Configuration Options

### Environment Variables
- `RAILS_LOG_LEVEL`: Set log level (debug, info, warn, error)
- `LOG_TO_STDOUT`: Force logging to stdout (production default)

### Custom Configuration
Modify `/config/initializers/logging.rb` to:
- Add custom log formatters
- Configure external logging services
- Set up log rotation policies
- Add custom log categories

## Security Considerations

### Sensitive Data Protection
The logging system automatically filters:
- Passwords and authentication tokens
- Credit card information
- Personal identification numbers
- Session tokens

### Log Access Control
Ensure production logs are:
- Stored securely with appropriate access controls
- Encrypted in transit and at rest
- Regularly rotated and archived
- Compliant with data retention policies

## Troubleshooting Common Issues

### High Log Volume
If logs become too verbose:
1. Increase log level to INFO or WARN in production
2. Add more specific filtering for debug logs
3. Use log sampling for high-traffic endpoints

### Performance Impact
Logging overhead is minimal but can be reduced by:
1. Using asynchronous logging for high-throughput applications
2. Configuring log levels appropriately per environment
3. Avoiding excessive debug logging in production

### Missing Context
If logs lack context:
1. Ensure request ID tracking is enabled
2. Add user ID to log tags
3. Include relevant business object IDs in log messages

## Future Enhancements

Planned logging improvements:
1. Integration with external monitoring services
2. Real-time log streaming and alerting
3. Advanced performance profiling
4. Custom business metrics tracking
5. Automated anomaly detection

---

This logging system provides comprehensive visibility into your PC Builder application's behavior, making debugging and monitoring much more effective in production environments.