# System Architecture Documentation

## Overview

The PC Builder application is a Ruby on Rails web application that allows users to design, manage, and share custom PC configurations. The system follows the Model-View-Controller (MVC) architectural pattern with a RESTful API design.

## High-Level System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        CLIENT LAYER                        │
├─────────────────────────────────────────────────────────────┤
│  Web Browser (Chrome, Firefox, Safari, Edge)               │
│  - HTML5, CSS3, JavaScript                                 │
│  - Responsive Design (Mobile/Desktop)                      │
│  - Hotwire/Turbo for SPA-like experience                  │
└─────────────────────┬───────────────────────────────────────┘
                      │ HTTP/HTTPS
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                    APPLICATION LAYER                       │
├─────────────────────────────────────────────────────────────┤
│                   Rails Application                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │ Controllers │  │   Views     │  │   Routes    │        │
│  │   (MVC-C)   │  │  (MVC-V)    │  │  (RESTful)  │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
│                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │   Models    │  │  Services   │  │  Helpers    │        │
│  │  (MVC-M)    │  │ (Business)  │  │ (Utilities) │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
└─────────────────────┬───────────────────────────────────────┘
                      │ ActiveRecord ORM
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                     DATA LAYER                             │
├─────────────────────────────────────────────────────────────┤
│               SQLite Database                               │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │    Users    │  │   Builds    │  │    Parts    │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
│                   │             │                          │
│                   └─────────────┘                          │
│                   │ Build Items │                          │
│                   └─────────────┘                          │
└─────────────────────────────────────────────────────────────┘
```

## Component Architecture

### 1. Web Layer (Client-Side)

#### Frontend Technologies
- **HTML5/CSS3**: Modern semantic markup and styling
- **JavaScript (ES6+)**: Client-side interactivity
- **Hotwire Turbo**: SPA-like navigation without full page reloads
- **Stimulus**: Modest JavaScript framework for component behavior
- **Importmap**: JavaScript module management

#### Key Features
- **Responsive Design**: Mobile-first approach
- **Progressive Enhancement**: Works without JavaScript
- **Real-time Updates**: Turbo Streams for live UI updates
- **Component-based**: Reusable UI components

### 2. Application Layer (Server-Side)

#### Rails Framework Structure
```
app/
├── controllers/          # Request handling and flow control
│   ├── application_controller.rb
│   ├── builds_controller.rb
│   ├── parts_controller.rb
│   ├── users_controller.rb
│   └── sessions_controller.rb
├── models/              # Business logic and data modeling
│   ├── user.rb
│   ├── build.rb
│   ├── build_item.rb
│   ├── part.rb
│   └── [component_models].rb
├── views/               # Presentation layer templates
│   ├── layouts/
│   ├── builds/
│   ├── parts/
│   └── shared/
├── helpers/             # View helper methods
├── assets/              # Stylesheets, images, fonts
├── javascript/          # Client-side JavaScript
└── lib/                 # Custom libraries and utilities
```

### 3. Data Layer

#### Database Schema Design
- **Users**: User authentication and profiles
- **Parts**: PC component catalog with specifications
- **Builds**: User-created PC configurations
- **Build Items**: Junction table linking builds to parts

#### Key Relationships
- User has many Builds (1:N)
- Build has many Parts through Build Items (N:M)
- Build Item belongs to Build and Part (N:1)

## Detailed Component Diagrams

### 1. Class Diagram

```
┌─────────────────┐         ┌─────────────────┐
│      User       │1      *│     Build       │
├─────────────────┤◆────────├─────────────────┤
│ id: integer     │         │ id: integer     │
│ name: string    │         │ name: string    │
│ email: string   │         │ user_id: integer│
│ password_digest │         │ total_wattage   │
│ created_at      │         │ share_token     │
│ updated_at      │         │ shared_data     │
└─────────────────┘         │ shared_at       │
                           │ created_at      │
                           │ updated_at      │
                           └─────────────────┘
                                    │
                                    │ 1
                                    │
                                    │ *
                           ┌─────────────────┐
                           │   BuildItem     │
                           ├─────────────────┤
                           │ id: integer     │
                           │ build_id: int   │◆──┐
                           │ part_id: int    │   │
                           │ quantity: int   │   │
                           │ note: text      │   │
                           │ created_at      │   │
                           │ updated_at      │   │
                           └─────────────────┘   │
                                    │            │
                                    │ *          │ *
                                    │            │
                                    │ 1          │ 1
                           ┌─────────────────┐   │
                           │      Part       │◆──┘
                           ├─────────────────┤
                           │ id: integer     │
                           │ type: string    │
                           │ brand: string   │
                           │ name: string    │
                           │ model_number    │
                           │ price_cents     │
                           │ wattage: int    │
                           │ [specific_attrs]│
                           │ created_at      │
                           │ updated_at      │
                           └─────────────────┘
                                    △
                    ┌───────────────┼───────────────┐
                    │               │               │
            ┌───────────┐   ┌───────────┐   ┌───────────┐
            │    CPU    │   │    GPU    │   │ Motherboard│
            ├───────────┤   ├───────────┤   ├───────────┤
            │cpu_cores  │   │gpu_memory │   │mb_socket  │
            │cpu_threads│   │gpu_memory │   │mb_chipset │
            │core_clock │   │ _type     │   │mb_form    │
            │boost_clock│   │core_clock │   │ _factor   │
            └───────────┘   │ _mhz      │   │mb_ram     │
                           └───────────┘   │ _slots    │
                                          └───────────┘
```

### 2. Database Entity-Relationship Diagram

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│     users       │     │    builds       │     │   build_items   │
├─────────────────┤     ├─────────────────┤     ├─────────────────┤
│ id (PK)         │────▶│ user_id (FK)    │────▶│ build_id (FK)   │
│ name            │     │ id (PK)         │     │ part_id (FK)    │
│ email (UNIQUE)  │     │ name            │     │ quantity        │
│ password_digest │     │ total_wattage   │     │ note            │
│ created_at      │     │ share_token     │     │ created_at      │
│ updated_at      │     │ shared_data     │     │ updated_at      │
└─────────────────┘     │ shared_at       │     └─────────────────┘
                       │ created_at      │              │
                       │ updated_at      │              │
                       └─────────────────┘              │
                                                        │
                       ┌─────────────────┐              │
                       │     parts       │◀─────────────┘
                       ├─────────────────┤
                       │ id (PK)         │
                       │ type            │
                       │ brand           │
                       │ name            │
                       │ model_number    │
                       │ price_cents     │
                       │ wattage         │
                       │ cpu_cores       │
                       │ cpu_threads     │
                       │ gpu_memory      │
                       │ mb_socket       │
                       │ [other specs]   │
                       │ created_at      │
                       │ updated_at      │
                       └─────────────────┘
```

### 3. System Flow Diagram

```
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│    Client    │    │    Router    │    │ Controller   │
└──────┬───────┘    └──────┬───────┘    └──────┬───────┘
       │                   │                   │
       │ 1. HTTP Request   │                   │
       ├──────────────────▶│                   │
       │                   │ 2. Route Match    │
       │                   ├──────────────────▶│
       │                   │                   │
       │                   │                   │ 3. Process
       │                   │                   │    Request
       │                   │                   ├─────────┐
       │                   │                   │         │
       │                   │                   │         ▼
       │                   │                   │ ┌──────────────┐
       │                   │                   │ │    Model     │
       │                   │                   │ └──────┬───────┘
       │                   │                   │        │
       │                   │                   │        │ 4. Database
       │                   │                   │        │    Query
       │                   │                   │        ▼
       │                   │                   │ ┌──────────────┐
       │                   │                   │ │   Database   │
       │                   │                   │ └──────┬───────┘
       │                   │                   │        │
       │                   │                   │        │ 5. Data
       │                   │                   │        │    Return
       │                   │                   │        ▼
       │                   │                   │ ┌──────────────┐
       │                   │                   │ │     View     │
       │                   │                   │ └──────┬───────┘
       │                   │                   │        │
       │                   │                   │ 6. Render     │
       │                   │                   │    Template   │
       │                   │                   ◀────────┘
       │                   │ 7. HTTP Response  │
       │                   ◀──────────────────┤
       │ 8. Display Page   │                   │
       ◀──────────────────┤                   │
       │                   │                   │
```

## API Architecture

### RESTful Endpoints

```
Authentication:
GET    /signup          → users#new
GET    /login           → sessions#new  
POST   /login           → sessions#create
DELETE /logout          → sessions#destroy

Users:
GET    /users           → users#index
GET    /users/:id       → users#show
POST   /users           → users#create

Builds:
GET    /builds          → builds#index
GET    /builds/:id      → builds#show
POST   /builds          → builds#create
PUT    /builds/:id      → builds#update
DELETE /builds/:id      → builds#destroy
POST   /builds/:id/share → builds#share
GET    /builds/:id/shared → builds#shared

Parts:
GET    /parts           → parts#index
GET    /parts/:id       → parts#show
GET    /cpus            → cpus#index
GET    /gpus            → gpus#index
[... other component types]

Build Items:
POST   /builds/:build_id/build_items → build_items#create
```

### Request/Response Flow

```
Client Request → Router → Controller → Model → Database
                    ↓         ↓         ↓         ↓
Client Response ← View ← Controller ← Model ← Database
```

## Security Architecture

### Authentication & Authorization
- **Password Security**: BCrypt hashing with salt
- **Session Management**: Rails secure session cookies
- **CSRF Protection**: Rails built-in CSRF tokens
- **User Authorization**: Controller-level access control

### Data Protection
- **SQL Injection**: Protected by ActiveRecord ORM
- **XSS Prevention**: Rails automatic HTML escaping
- **Mass Assignment**: Strong parameters in controllers
- **Secure Headers**: Rails security headers

## Performance Considerations

### Caching Strategy
- **Page Caching**: Static content caching
- **Fragment Caching**: Partial template caching  
- **Query Optimization**: Database indexes and eager loading
- **Asset Pipeline**: Minification and compression

### Scalability
- **Database**: SQLite for development, PostgreSQL for production
- **Application Server**: Puma with multiple workers
- **Load Balancing**: Nginx reverse proxy (production)
- **CDN**: Asset delivery optimization

---

*Last Updated: October 6, 2025*