classDiagram
  direction LR

  class User {
    id: integer
    name: string
    email: string (unique, downcased)
    -- validations --
    +valid_email
  }

  class Build {
    id: integer
    name: string
    total_wattage: integer (cached, optional)
    user_id: integer (nullable for now)
    -- methods --
    +parts()
    +recalculate_wattage()
  }

  class BuildItem {
    id: integer
    build_id: integer
    part_id: integer
    quantity: integer
    note: text
  }

  class Part {
    id: integer
    type: string  <<STI>>
    brand: string
    name: string
    model_number: string
    price_cents: integer
    wattage: integer  (0 if N/A)
  }

  class Cpu
  class GPU
  class Motherboard
  class Memory
  class Storage
  class Cooler
  class Case
  class PSU

  User "1" -- "0..*" Build : owns
  Build "1" -- "1..*" BuildItem : has
  Part "1" -- "0..*" BuildItem : used in

  Part <|-- Cpu
  Part <|-- GPU
  Part <|-- Motherboard
  Part <|-- Memory
  Part <|-- Storage
  Part <|-- Cooler
  Part <|-- Case
  Part <|-- PSU
