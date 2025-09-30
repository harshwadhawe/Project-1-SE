# PC Builder – Rails Project

## Overview

PC Builder is a Ruby on Rails application that allows users to:

* Browse PC components (CPU, GPU, Motherboard, Memory, Storage, Cooler, PcCase, PSU).
* View extra specifications for each part type (e.g. CPU cores/threads, base/boost clocks).
* Create builds by selecting parts from each category and assigning quantities.
* Manage users and builds.
* View sample parts and recent builds on the Home page.

---

## Project Structure

### Models

* **User**

  * Attributes: `name`, `email`
  * Validations: presence and uniqueness of email
  * Associations: `has_many :builds`

* **Build**

  * Attributes: `name`, `total_wattage`, `user_id`
  * Associations: `belongs_to :user, optional: true`
  * `has_many :build_items`, `has_many :parts, through: :build_items`
  * Validates presence of `name`

* **BuildItem**

  * Join model between `Build` and `Part`
  * Attributes: `quantity`, `note`
  * Validates `quantity > 0`
  * Associations: `belongs_to :build`, `belongs_to :part`

* **Part** (STI base class)

  * Attributes (shared): `name`, `brand`, `model_number`, `type`, `price_cents`, `wattage`
  * Subclasses:

    * `Cpu` – has extra fields: `cpu_cores`, `cpu_threads`, `cpu_base_ghz`, `cpu_boost_ghz`, `cpu_socket`, `cpu_tdp_w`, `cpu_cache_mb`, `cpu_igpu`
    * `Gpu` – placeholder, extra fields to be added later
    * `Motherboard` – placeholder
    * `Memory` – placeholder
    * `Storage` – placeholder
    * `Cooler` – placeholder
    * `PcCase` – renamed from `PcCase` to avoid Ruby keyword
    * `Psu` – placeholder

---

### Controllers

* **HomeController**

  * `index`: shows sample parts by category and recent builds.

* **UsersController**

  * `index`: list all users
  * `show`: view user details

* **PartsController**

  * `index`: list all parts, with optional `q` filter by type
  * `show`: displays part details with type-specific partials

* **BuildsController**

  * `index`: list all builds
  * `show`: view a build and its parts
  * `new`: form for creating a build (parts grouped by category, quantities)
  * `create`: saves build, attaches default user if none logged in, creates `BuildItem`s

---

### Views

* **Home**

  * Shows parts grouped by category and recent builds
  * Dev login/logout buttons

* **Users**

  * Index & show pages

* **Parts**

  * Index: lists all parts with optional filter
  * Show: shows common info + type-specific partial
  * Partial examples:

    * `_details_cpu.html.erb` (cores, threads, base/boost GHz, socket, TDP, cache, iGPU)

* **Builds**

  * Index, show, and new form (with grouped checkboxes + quantity inputs)

---

### Routes

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

### Seeds

* Default user: `Harsh (harsh@example.com)`
* Example CPU (Ryzen 7 7800X3D) with extra fields:

  * 8 cores / 16 threads
  * 4.2 GHz base / 5.0 GHz boost
  * AM5 socket, 120W TDP, 104 MB cache
* Similar placeholder data for GPU, Motherboard, Memory, Storage, Cooler, PcCase, PSU

---

## Development Notes

* Using **STI** for parts (`type` column in `parts` table).
* Acronym models (`Cpu`, `Gpu`, `Psu`) are capitalized with only the first letter to play well with Zeitwerk.
* `parts#show` automatically looks for a type-specific partial (`_details_cpu`, `_details_gpu`, etc.).
* Default login sets the session to `harsh@example.com`.
* Build creation handles both `part_ids` and `quantities`.

---

## Next Steps

* Extend extra attributes and partials for `Gpu`, `Motherboard`, `Memory`, `Storage`, `Cooler`, `PcCase`, `Psu`.
* Add computed fields (e.g. `Build#total_wattage`, `Build#total_price`).
* Improve authentication (Devise or similar).
* Add styling (Bootstrap or Tailwind).
* Write full test coverage (RSpec for controllers + system tests).
* Optionally expose JSON APIs for builds and parts.