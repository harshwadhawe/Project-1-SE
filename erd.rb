classDiagram
  class User {
    +id: bigint
    +email: string
    +password_digest: string
    has_many builds
  }

  class Build {
    +id: bigint
    +user_id: bigint
    +name: string
    +status: enum
    has_many build_items
    has_many parts through build_items
  }

  class ComponentType {
    +id: bigint
    +name: string
    +slug: string
    has_many parts
  }

  class Part {
    +id: bigint
    +component_type_id: bigint
    +name: string
    +brand: string
    +price_cents: integer
    belongs_to component_type
  }

  class Cpu inherits Part {

  }


  class BuildItem {
    +id: bigint
    +build_id: bigint
    +part_id: bigint
    +component_type_id: bigint
    belongs_to build
    belongs_to part
    belongs_to component_type
  }

  User "1" --> "many" Build
  Build "1" --> "many" BuildItem
  ComponentType "1" --> "many" Part
  Part "1" --> "many" BuildItem

  
erDiagram
  BUILDS ||--o{ BUILD_ITEMS : contains
  PARTS  ||--o{ BUILD_ITEMS : selected
  COMPONENT_TYPES ||--o{ PARTS : categorizes
  PARTS  ||--|| CPU_SPECS : "has one (for Cpu only)"

  BUILDS {
    bigint id PK
    string name
    integer status      // 0=draft,1=finalized
    string slug
    datetime created_at
    datetime updated_at
  }

  BUILD_ITEMS {
    bigint id PK
    bigint build_id FK
    bigint part_id  FK
    bigint component_type_id FK
    datetime created_at
    datetime updated_at
    // UNIQUE(build_id, component_type_id)
  }

  COMPONENT_TYPES {
    bigint id PK
    string name     // CPU, GPU, Cooler, Memory, HardDisk, Frame, ...
    string slug     // cpu, gpu, cooler, memory, hard-disk, frame
    datetime created_at
    datetime updated_at
    // UNIQUE(slug)
  }

  PARTS {
    bigint id PK
    bigint component_type_id FK
    string type        // STI: Cpu, Gpu, Cooler, Memory, HardDisk, Frame
    string name
    string brand
    integer price_cents
    string sku
    datetime created_at
    datetime updated_at
  }

  CPU_SPECS {
    bigint part_id PK, FK  // points to parts.id where parts.type='Cpu'
    integer cores
    integer threads
    numeric base_clock_ghz
    numeric boost_clock_ghz
    string socket
    integer tdp_watts
    boolean igpu
    datetime created_at
    datetime updated_at
  }
