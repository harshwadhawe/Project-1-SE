erDiagram
  USERS ||--o{ BUILDS : owns
  BUILDS ||--o{ BUILD_ITEMS : contains
  COMPONENT_TYPES ||--o{ PARTS : categorizes
  PARTS ||--o{ BUILD_ITEMS : selected

  USERS {
    bigint id PK
    string email
    string password_digest
  }

  BUILDS {
    bigint id PK
    bigint user_id FK
    string name
    integer status
  }

  COMPONENT_TYPES {
    bigint id PK
    string name
    string slug
  }

  PARTS {
    bigint id PK
    bigint component_type_id FK
    string name
    string brand
    integer price_cents
  }

  BUILD_ITEMS {
    bigint id PK
    bigint build_id FK
    bigint part_id FK
    bigint component_type_id FK
  }
