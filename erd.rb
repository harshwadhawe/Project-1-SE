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
