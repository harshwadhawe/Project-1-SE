# Technical Documentation

## Deployment Guide

### Prerequisites

Before deploying the PC Builder application, ensure you have the following installed:

- **Ruby**: Version 3.2+ (check with `ruby -v`)
- **Rails**: Version 8.0.3+ (check with `rails -v`)
- **Node.js**: Version 16+ (for asset compilation)
- **SQLite3**: For development/testing
- **Git**: For version control

### Development Setup (Zero to Running)

#### 1. Clone the Repository
```bash
# Clone the repository
git clone https://github.com/harshwadhawe/Project-1-SE.git
cd Project-1-SE/pc_builder
```

#### 2. Install Dependencies
```bash
# Install Ruby gems
bundle install

#### 3. Database Setup
```bash
# Create and migrate the database
rails db:create
rails db:migrate

# Seed the database with sample data
rails db:seed
```

#### 4. Run the Development Server
```bash
# Start the Rails server
rails server

# Application will be available at:
# http://localhost:3000
```

#### 5. Run Tests (Optional)
```bash
# Run RSpec unit tests
bundle exec rspec

# Run Cucumber acceptance tests
bundle exec cucumber

# Check test coverage
COVERAGE=true bundle exec rspec
```

### Production Deployment

#### Using Docker (Recommended)

1. **Build Docker Image**
```bash
# Build the production image
docker build -t pc-builder .

# Run the container
docker run -p 3000:3000 pc-builder
```

2. **Using Docker Compose**
```yaml
# docker-compose.yml
version: '3.8'
services:
  web:
    build: .
    ports:
      - "3000:3000"
    environment:
      - RAILS_ENV=production
    volumes:
      - ./storage:/rails/storage
```

#### Using Kamal (Rails 8 Native)

```bash
# Deploy using Kamal
kamal deploy
```

#### Manual Production Setup

1. **Server Preparation**
```bash
# Install Ruby and dependencies
curl -fsSL https://rvm.io/mpapis.asc | gpg --import -
curl -fsSL https://rvm.io/pkuczynski.asc | gpg --import -
curl -sSL https://get.rvm.io | bash -s stable --ruby

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
```

2. **Application Deployment**
```bash
# Clone and setup
git clone https://github.com/harshwadhawe/Project-1-SE.git
cd Project-1-SE/pc_builder

# Install dependencies
bundle install --without development test
npm install

# Setup database
RAILS_ENV=production rails db:create
RAILS_ENV=production rails db:migrate
RAILS_ENV=production rails db:seed

# Precompile assets
RAILS_ENV=production rails assets:precompile

# Start production server
RAILS_ENV=production rails server -p 80
```

### Environment Variables

Create a `.env` file for environment-specific configuration:

```bash
# .env
RAILS_ENV=production
SECRET_KEY_BASE=your_secret_key_here
DATABASE_URL=sqlite3:storage/production.sqlite3

# Optional: External database
# DATABASE_URL=postgresql://user:password@localhost/pc_builder_production
```

### Database Configuration

#### SQLite (Default)
- **Development**: `storage/development.sqlite3`
- **Test**: `storage/test.sqlite3`
- **Production**: `storage/production.sqlite3`

#### PostgreSQL (Production Recommended)
```yaml
# config/database.yml
production:
  adapter: postgresql
  database: pc_builder_production
  username: <%= ENV['DB_USERNAME'] %>
  password: <%= ENV['DB_PASSWORD'] %>
  host: <%= ENV['DB_HOST'] %>
  port: <%= ENV['DB_PORT'] %>
```

### SSL/Security Configuration

For production deployment:

```ruby
# config/environments/production.rb
config.force_ssl = true
config.ssl_options = { redirect: { status: 301, body: nil } }
```

### Monitoring and Logging

- **Application logs**: `log/production.log`
- **Error tracking**: Configure external service (e.g., Sentry)
- **Performance monitoring**: Configure APM tool (e.g., New Relic)

### Backup Strategy

```bash
# Database backup
sqlite3 storage/production.sqlite3 ".backup backup_$(date +%Y%m%d).sqlite3"

# Full application backup
tar -czf pc_builder_backup_$(date +%Y%m%d).tar.gz .
```

### Troubleshooting

#### Common Issues

1. **Bundle install fails**
   ```bash
   # Clear gem cache
   bundle clean --force
   rm Gemfile.lock
   bundle install
   ```

2. **Database migration errors**
   ```bash
   # Reset database
   rails db:drop db:create db:migrate db:seed
   ```

3. **Asset compilation issues**
   ```bash
   # Clear assets
   rails assets:clobber
   rails assets:precompile
   ```

4. **Permission issues**
   ```bash
   # Fix file permissions
   chmod +x bin/rails
   chmod -R 755 storage/
   ```

### Performance Optimization

1. **Enable caching**
   ```ruby
   # config/environments/production.rb
   config.cache_classes = true
   config.eager_load = true
   config.cache_store = :memory_store
   ```

2. **Database optimization**
   ```ruby
   # Add database indexes for performance
   # See db/migrate files for existing indexes
   ```

3. **Asset optimization**
   ```ruby
   # config/environments/production.rb
   config.assets.compile = false
   config.assets.digest = true
   config.assets.compress = true
   ```

---

*Last Updated: October 6, 2025*