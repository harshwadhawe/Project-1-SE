classDiagram
  class Build {
    +id: bigint
    +name: string
    +status: enum
    +slug: string
    +total_price_cents(): integer
  }

  class BuildItem {
    +id: bigint
    +build_id: bigint
    +part_id: bigint
    +component_type_id: bigint
  }

  class ComponentType {
    +id: bigint
    +name: string
    +slug: string
  }

  class Part {
    +id: bigint
    +component_type_id: bigint
    +type: string  // STI
    +name: string
    +brand: string
    +price_cents: integer
    +sku: string
  }

  class Cpu {
    // behavior inherits from Part (STI)
    +cpu_spec(): CpuSpec
    +cores(): integer
    +threads(): integer
    +base_clock_ghz(): decimal
    +boost_clock_ghz(): decimal
    +socket(): string
    +tdp_watts(): integer
    +igpu(): boolean
  }
  Cpu --|> Part

  class CpuSpec {
    +part_id: bigint (PK/FK to parts.id)
    +cores: integer
    +threads: integer
    +base_clock_ghz: decimal
    +boost_clock_ghz: decimal
    +socket: string
    +tdp_watts: integer
    +igpu: boolean
  }

  Part "1" --> "many" BuildItem
  ComponentType "1" --> "many" Part
  Cpu "1" --> "1" CpuSpec : has_one
