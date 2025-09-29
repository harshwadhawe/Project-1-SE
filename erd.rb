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

  