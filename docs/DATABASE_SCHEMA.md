# Database Schema Documentation

## Overview

The PC Builder application uses a relational database design optimized for storing user accounts, PC component catalog, and user-generated PC build configurations. The schema supports flexible component specifications and efficient querying.

## Database Technology

- **Development/Test**: SQLite 3
- **Production**: PostgreSQL (recommended) or SQLite 3
- **ORM**: ActiveRecord (Rails 8.0.3)
- **Migration System**: Rails migrations for version control

## Schema Diagram

```
┌─────────────────────┐    1:N     ┌─────────────────────┐
│       users         │◆───────────│       builds        │
├─────────────────────┤            ├─────────────────────┤
│ id (PK)             │            │ id (PK)             │
│ name                │            │ user_id (FK)        │
│ email (UNIQUE)      │            │ name                │
│ password_digest     │            │ total_wattage       │
│ created_at          │            │ share_token         │
│ updated_at          │            │ shared_data         │
└─────────────────────┘            │ shared_at           │
                                  │ created_at          │
                                  │ updated_at          │
                                  └─────────────────────┘
                                           │
                                           │ 1:N
                                           │
                                           ▼
                                  ┌─────────────────────┐
                                  │    build_items      │
                                  ├─────────────────────┤
                                  │ id (PK)             │
                                  │ build_id (FK)       │◆──┐
                                  │ part_id (FK)        │   │
                                  │ quantity            │   │
                                  │ note                │   │
                                  │ created_at          │   │
                                  │ updated_at          │   │
                                  └─────────────────────┘   │
                                           │                │
                                           │ N:1            │
                                           │                │
                                           ▼                │
┌─────────────────────────────────────────────────────────┐  │
│                        parts                            │◆─┘
├─────────────────────────────────────────────────────────┤
│ Common Attributes:                                      │
│ id (PK)                                                 │
│ type (STI - Single Table Inheritance)                  │
│ brand                                                   │
│ name                                                    │
│ model_number                                            │
│ price_cents                                             │
│ wattage                                                 │
│ created_at                                              │
│ updated_at                                              │
├─────────────────────────────────────────────────────────┤
│ CPU-specific:           │ GPU-specific:                 │
│ cpu_cores               │ gpu_memory                    │
│ cpu_threads             │ gpu_memory_type               │
│ cpu_core_clock          │ gpu_core_clock_mhz            │
│ cpu_boost_clock         │ gpu_core_boost_mhz            │
├─────────────────────────────────────────────────────────┤
│ Motherboard-specific:   │ Memory-specific:              │
│ mb_socket               │ mem_type                      │
│ mb_chipset              │ mem_kit_capacity_gb           │
│ mb_form_factor          │ mem_modules                   │
│ mb_ram_slots            │ mem_speed_mhz                 │
│ mb_max_ram_gb           │ mem_first_word_latency        │
├─────────────────────────────────────────────────────────┤
│ Storage-specific:       │ Cooler-specific:              │
│ stor_type               │ cooler_type                   │
│ stor_interface          │ cooler_fan_size_mm            │
│ stor_capacity_gb        │ cooler_sockets                │
├─────────────────────────────────────────────────────────┤
│ Case-specific:          │ PSU-specific:                 │
│ case_type               │ psu_efficiency                │
│ case_supported_mb       │ psu_modularity                │
│ case_color              │ psu_wattage                   │
└─────────────────────────────────────────────────────────┘
```

## Table Specifications

### 1. users

Stores user account information and authentication data.

```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_digest VARCHAR(255) NOT NULL,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL
);

CREATE UNIQUE INDEX index_users_on_email ON users(email);
```

#### Columns:
- **id**: Primary key, auto-incrementing integer
- **name**: User's display name (required)
- **email**: Unique email address for login (required, indexed)
- **password_digest**: BCrypt hashed password (required)
- **created_at/updated_at**: Rails timestamps

#### Constraints:
- **Email uniqueness**: Enforced at database and application level
- **Password security**: Minimum 6 characters (application-level)
- **Email validation**: Valid email format (application-level)

---

### 2. builds

Stores user-created PC configurations.

```sql
CREATE TABLE builds (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  name VARCHAR(255),
  total_wattage INTEGER,
  share_token VARCHAR(255),
  shared_data TEXT,
  shared_at DATETIME,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE INDEX index_builds_on_user_id ON builds(user_id);
```

#### Columns:
- **id**: Primary key
- **user_id**: Foreign key to users table (required)
- **name**: Build name/title
- **total_wattage**: Calculated total power consumption
- **share_token**: Unique token for sharing builds publicly
- **shared_data**: JSON data for shared build snapshots
- **shared_at**: Timestamp when build was shared
- **created_at/updated_at**: Rails timestamps

#### Business Rules:
- **Name validation**: Required, max 255 characters
- **Wattage calculation**: Auto-calculated from components
- **Share token**: Generated when build is shared
- **Soft delete**: Builds are not hard-deleted to preserve references

---

### 3. build_items

Junction table linking builds to parts with quantities.

```sql
CREATE TABLE build_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  build_id INTEGER NOT NULL,
  part_id INTEGER NOT NULL,
  quantity INTEGER DEFAULT 1,
  note TEXT,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL,
  FOREIGN KEY (build_id) REFERENCES builds(id),
  FOREIGN KEY (part_id) REFERENCES parts(id)
);

CREATE INDEX index_build_items_on_build_id ON build_items(build_id);
CREATE INDEX index_build_items_on_part_id ON build_items(part_id);
```

#### Columns:
- **id**: Primary key
- **build_id**: Foreign key to builds table (required)
- **part_id**: Foreign key to parts table (required)
- **quantity**: Number of this part in the build (default: 1)
- **note**: Optional user notes about this component
- **created_at/updated_at**: Rails timestamps

#### Business Rules:
- **Quantity validation**: Must be greater than 0
- **Unique combinations**: One record per part per build
- **Cascade handling**: Deleting build removes associated build_items

---

### 4. parts

Stores PC component catalog using Single Table Inheritance (STI).

```sql
CREATE TABLE parts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  type VARCHAR(255) NOT NULL,
  brand VARCHAR(255),
  name VARCHAR(255) NOT NULL,
  model_number VARCHAR(255),
  price_cents INTEGER NOT NULL DEFAULT 0,
  wattage INTEGER DEFAULT 0,
  
  -- CPU-specific attributes
  cpu_cores INTEGER,
  cpu_threads INTEGER,
  cpu_core_clock DECIMAL,
  cpu_boost_clock DECIMAL,
  
  -- GPU-specific attributes
  gpu_memory INTEGER,
  gpu_memory_type VARCHAR(255),
  gpu_core_clock_mhz INTEGER,
  gpu_core_boost_mhz INTEGER,
  
  -- Motherboard-specific attributes
  mb_socket VARCHAR(255),
  mb_chipset VARCHAR(255),
  mb_form_factor VARCHAR(255),
  mb_ram_slots INTEGER,
  mb_max_ram_gb INTEGER,
  
  -- Memory-specific attributes
  mem_type VARCHAR(255),
  mem_kit_capacity_gb INTEGER,
  mem_modules INTEGER,
  mem_speed_mhz INTEGER,
  mem_first_word_latency INTEGER,
  
  -- Storage-specific attributes
  stor_type VARCHAR(255),
  stor_interface VARCHAR(255),
  stor_capacity_gb INTEGER,
  
  -- Cooler-specific attributes
  cooler_type VARCHAR(255),
  cooler_fan_size_mm INTEGER,
  cooler_sockets VARCHAR(255),
  
  -- Case-specific attributes
  case_type VARCHAR(255),
  case_supported_mb VARCHAR(255),
  case_color VARCHAR(255),
  
  -- PSU-specific attributes
  psu_efficiency VARCHAR(255),
  psu_modularity VARCHAR(255),
  psu_wattage VARCHAR(255),
  
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL
);
```

#### STI Model Types:
- **Cpu**: Processors
- **Gpu**: Graphics cards
- **Motherboard**: Motherboards
- **Memory**: RAM modules
- **Storage**: Hard drives, SSDs
- **Cooler**: CPU coolers
- **PcCase**: Computer cases
- **Psu**: Power supplies

#### Common Attributes:
- **type**: STI discriminator column (required)
- **brand**: Manufacturer name
- **name**: Product name (required)
- **model_number**: Specific model identifier
- **price_cents**: Price in cents to avoid floating point issues
- **wattage**: Power consumption in watts

#### Component-Specific Attributes:

**CPU (type: 'Cpu')**
- `cpu_cores`: Number of cores
- `cpu_threads`: Number of threads
- `cpu_core_clock`: Base clock speed (GHz)
- `cpu_boost_clock`: Boost clock speed (GHz)

**GPU (type: 'Gpu')**
- `gpu_memory`: VRAM capacity (MB)
- `gpu_memory_type`: Memory type (GDDR6, etc.)
- `gpu_core_clock_mhz`: Base core clock (MHz)
- `gpu_core_boost_mhz`: Boost core clock (MHz)

**Motherboard (type: 'Motherboard')**
- `mb_socket`: CPU socket type (LGA1700, AM4, etc.)
- `mb_chipset`: Chipset (Z790, B650, etc.)
- `mb_form_factor`: Size (ATX, mATX, Mini-ITX)
- `mb_ram_slots`: Number of RAM slots
- `mb_max_ram_gb`: Maximum RAM capacity

**Memory (type: 'Memory')**
- `mem_type`: Memory type (DDR4, DDR5)
- `mem_kit_capacity_gb`: Total kit capacity
- `mem_modules`: Number of modules in kit
- `mem_speed_mhz`: Memory speed (MHz)
- `mem_first_word_latency`: Latency specification

**Storage (type: 'Storage')**
- `stor_type`: Storage type (SSD, HDD)
- `stor_interface`: Interface (SATA, NVMe)
- `stor_capacity_gb`: Storage capacity

**Cooler (type: 'Cooler')**
- `cooler_type`: Cooler type (Air, AIO)
- `cooler_fan_size_mm`: Fan size
- `cooler_sockets`: Supported CPU sockets

**PC Case (type: 'PcCase')**
- `case_type`: Case type (Full Tower, Mid Tower)
- `case_supported_mb`: Supported motherboard sizes
- `case_color`: Case color

**PSU (type: 'Psu')**
- `psu_efficiency`: Efficiency rating (80+ Gold, etc.)
- `psu_modularity`: Cable modularity (Fully, Semi, Non)
- `psu_wattage`: Power output rating

## Indexes

### Primary Indexes
- All tables have primary key indexes on `id`

### Foreign Key Indexes
```sql
-- Performance optimization for joins
CREATE INDEX index_builds_on_user_id ON builds(user_id);
CREATE INDEX index_build_items_on_build_id ON build_items(build_id);
CREATE INDEX index_build_items_on_part_id ON build_items(part_id);
```

### Unique Indexes
```sql
-- Ensure email uniqueness
CREATE UNIQUE INDEX index_users_on_email ON users(email);
```

### Query Optimization Indexes (Recommended)
```sql
-- For part filtering and searching
CREATE INDEX index_parts_on_type ON parts(type);
CREATE INDEX index_parts_on_brand ON parts(brand);
CREATE INDEX index_parts_on_price_cents ON parts(price_cents);

-- For build sharing
CREATE INDEX index_builds_on_share_token ON builds(share_token);
```

## Database Relationships

### One-to-Many Relationships
- **User → Builds**: One user can have many builds
- **Build → BuildItems**: One build can have many build items

### Many-to-One Relationships
- **Builds → User**: Many builds belong to one user
- **BuildItems → Build**: Many build items belong to one build
- **BuildItems → Part**: Many build items can reference one part

### Many-to-Many Relationships
- **Builds ↔ Parts**: Through BuildItems junction table

## Data Integrity Constraints

### Referential Integrity
- Foreign key constraints ensure valid references
- Cascade rules prevent orphaned records

### Business Logic Constraints
```ruby
# Application-level validations
class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  validates :name, presence: true
  has_secure_password
end

class Build < ApplicationRecord
  validates :name, presence: true, length: { maximum: 255 }
  validates :user_id, presence: true
  belongs_to :user
end

class BuildItem < ApplicationRecord
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :build_id, presence: true
  validates :part_id, presence: true
  belongs_to :build
  belongs_to :part
end

class Part < ApplicationRecord
  validates :name, presence: true
  validates :type, presence: true
  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }
end
```

## Migration History

The database schema is managed through Rails migrations:

```
db/migrate/
├── 20240901000001_create_users.rb
├── 20240901000002_create_parts.rb
├── 20240901000003_create_builds.rb
├── 20240901000004_create_build_items.rb
├── 20240901000005_add_password_digest_to_users.rb
├── 20240901000006_add_sharing_to_builds.rb
└── 20250930154447_add_indexes_for_performance.rb
```

## Performance Considerations

### Query Optimization
- **Eager Loading**: Use `includes()` to avoid N+1 queries
- **Select Specific Columns**: Use `select()` for large result sets
- **Pagination**: Implement pagination for large data sets

### Storage Optimization
- **Price Storage**: Using cents (integer) instead of decimal
- **STI Design**: Single table for parts reduces joins
- **Index Strategy**: Strategic indexes for common queries

### Caching Strategy
- **Fragment Caching**: Cache expensive part catalogs
- **Counter Caches**: Cache build item counts
- **Query Caching**: Rails automatic query caching

---

*Last Updated: October 6, 2025*