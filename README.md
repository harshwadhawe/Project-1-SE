# PC Builder – Ruby on Rails Project

**Live Website:** [https://project-se-1-0d8c6f6dc1ab.herokuapp.com/](https://project-se-1-0d8c6f6dc1ab.herokuapp.com/)

---

## Deployment Instructions (Heroku)

```bash
# Push code to Heroku
git push heroku change-repo-structure:main

# Run database migrations
heroku run rails db:migrate -a project-se-1

# Seed initial data
heroku run rails db:seed -a project-se-1
````

Once deployed, visit:
**[https://project-se-1-0d8c6f6dc1ab.herokuapp.com/](https://project-se-1-0d8c6f6dc1ab.herokuapp.com/)**

---

## Overview

PC Builder is a full-stack Ruby on Rails web application that allows users to browse, filter, and assemble custom PC builds.
It provides a modular architecture with clearly separated models, controllers, and views for scalability and maintainability.

### Key Features

* Browse PC components (CPU, GPU, Motherboard, Memory, Storage, Cooler, Case, PSU)
* View detailed specifications per component type
* Filter by type, brand, and keywords
* Create and manage PC builds
* Sample parts and recent builds displayed on the Home page
* Lightweight login system (Dev login / guest browsing)

---

## Project Structure

### Models

#### User

* Attributes: `name`, `email`
* Validations: presence and uniqueness of `email`
* Associations:
  `has_many :builds`

#### Build

* Attributes: `name`, `total_wattage`, `user_id`
* Associations:
  `belongs_to :user, optional: true`
  `has_many :build_items`
  `has_many :parts, through: :build_items`
* Validations: presence of `name`

#### BuildItem

* Join model between `Build` and `Part`
* Attributes: `quantity`, `note`
* Validations: `quantity > 0`
* Associations:
  `belongs_to :build`, `belongs_to :part`

#### Part (STI Base Class)

* Attributes: `name`, `brand`, `model_number`, `type`, `price_cents`, `wattage`
* Subclasses:

  * `Cpu` – extra fields: cores, threads, base/boost GHz, socket, TDP, cache, iGPU
  * `Gpu`, `Motherboard`, `Memory`, `Storage`, `Cooler`, `PcCase`, `Psu` – placeholders
* Note: `PcCase` replaces `Case` to avoid Ruby keyword conflicts.

---

## Controllers

| Controller       | Description                                                                       |
| ---------------- | --------------------------------------------------------------------------------- |
| HomeController   | Displays featured parts and recent builds                                         |
| UsersController  | Lists all users and user profiles                                                 |
| PartsController  | Handles browsing and filtering of all PC parts (`index`, `show`)                  |
| BuildsController | CRUD for builds (`index`, `show`, `new`, `create`) with grouped quantity handling |

---

## Views

### Home

* Displays sample parts grouped by category
* Shows recent builds and login/logout buttons

### Users

* `index` and `show` pages for user info

### Parts

* `index.html.erb`: parts table with type, brand, name
* `show.html.erb`: detailed specs per part
* Dynamic partials for type-specific details (`_details_cpu.html.erb`, etc.)

### Builds

* `index`: user builds overview
* `show`: lists selected parts per build
* `new`: form for creating a build with grouped inputs

---

## Routes

```ruby
Rails.application.routes.draw do
  root "home#index"

  resources :users, only: [:index, :show]
  resources :parts, only: [:index, :show]
  resources :builds

  post   "/dev_login", to: "sessions#create"
  delete "/logout",    to: "sessions#destroy"
end
```

---

## Seed Data

* Default user: Harsh ([harsh@example.com](mailto:harsh@example.com))
* Example CPU: Ryzen 7 7800X3D

  * 8 cores / 16 threads
  * 4.2 GHz base / 5.0 GHz boost
  * AM5 socket, 120W TDP, 104MB cache
* Sample placeholder data for other components (GPU, Motherboard, Memory, etc.)

---

## Development Notes

* Uses Single Table Inheritance (STI) for parts (`type` column)
* Acronym models (`Cpu`, `Gpu`, `Psu`) follow Zeitwerk autoloading conventions
* `parts#show` dynamically loads partials based on part type
* Dev Login auto-creates a guest session (`harsh@example.com`)
* Build creation supports both `part_ids` and `quantities`

---

## Local Development Setup

### 1. Clone and Install

```bash
git clone <repo_url>
cd pc_builder
bundle install
```

### 2. Database Setup

**PostgreSQL (recommended, matches Heroku):**

```bash
rails db:drop db:create db:migrate db:seed
```

**SQLite (default local dev):**

```bash
rails db:prepare
```

### 3. Start Server

```bash
bin/rails server
```

Then visit [http://localhost:3000](http://localhost:3000)

---

## Testing

* Uses RSpec for model, controller, and integration tests.
* Coverage reports generated via SimpleCov.

Run tests:

```bash
bundle exec rspec
```

---

## Next Steps

* Extend component attributes (GPU, Motherboard, Memory, etc.)
* Compute `Build#total_price` and `Build#total_wattage`
* Add authentication with Devise
* Tailwind CSS for modern UI design
* Increase test coverage with RSpec
* Add JSON APIs for builds and parts

---

# Documentation

This repository also includes comprehensive technical documentation for both end-users and developers.

---

## Available Documentation

### User Documentation

* **[User Guide](docs/USER_GUIDE.md)** — Complete guide for end-users on how to use the PC Builder application

### Technical Documentation (Required)

* **[Deployment Guide](docs/DEPLOYMENT_GUIDE.md)** — Detailed instructions for setting up, configuring, and deploying the application
* **[System Architecture](docs/ARCHITECTURE.md)** — System, class, and component architecture diagrams
* **[Database Schema](docs/DATABASE_SCHEMA.md)** — Entity-relationship and schema documentation

### Development Documentation

* **[Logging Guide](docs/LOGGING_GUIDE.md)** — Technical documentation for the logging and monitoring system

---

## Documentation Structure

```
docs/
├── README.md              # Documentation index (this section)
├── USER_GUIDE.md          # End-user documentation
├── DEPLOYMENT_GUIDE.md    # Zero-to-deployed setup guide
├── ARCHITECTURE.md        # System and component architecture diagrams
├── DATABASE_SCHEMA.md     # Database structure and ER diagrams
└── LOGGING_GUIDE.md       # Logging system and configuration details
```

---

## Quick Navigation

### For End Users

* [Start Here: User Guide](docs/USER_GUIDE.md) – Complete usage guide for PC Builder

### For Developers and DevOps

* [Deployment Guide](docs/DEPLOYMENT_GUIDE.md) – Setup and deploy from scratch
* [System Architecture](docs/ARCHITECTURE.md) – Understand the architecture and design
* [Database Schema](docs/DATABASE_SCHEMA.md) – Explore database structure and relationships
* [Logging Guide](docs/LOGGING_GUIDE.md) – Learn how logging is implemented and used

---

## Documentation Standards

### Architectural Schemas Included

* System Diagram: High-level system architecture with layers
* Class Diagram: Object-oriented design and relationships
* Database Diagram: Entity-relationship diagrams and schema
* Component Architecture: Detailed component interactions
* API Flow Diagrams: Request/response flow visualization

### Deployment Requirements Covered

* Zero to Deployed: Complete setup from fresh clone
* Development Setup: Local environment configuration
* Production Deployment: Docker, Kamal, or manual setups
* Environment Configuration: Database, SSL, and monitoring
* Troubleshooting: Common issues and their resolutions

---

## Future Documentation

### Architecture Decision Records

* ADR-001: Technology Stack Selection
* ADR-002: Database Design Decisions
* ADR-003: Authentication Strategy
* ADR-004: API Design Approach

### Additional Technical Documentation

* API Documentation: REST API endpoints and usage
* Testing Strategy: Testing standards and practices
* Security Guide: Implementation and hardening guidelines
* Performance Guide: Optimization and monitoring strategies

---

**Last Updated:** October 6, 2025
**Project:** PC Builder Rails Application
**Documentation Version:** 1.0