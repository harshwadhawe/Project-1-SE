# PC Builder – Rails Project

## Overview

PC Builder is a Ruby on Rails application that allows users to:

* Browse PC components (CPU, GPU, Motherboard, Memory, Storage, Cooler, Case, PSU).
* Create builds by selecting parts from each category.
* Manage users (basic).
* View recent builds and sample parts on the Home page.

---

## Project Structure

### Models

* **User**

  * Attributes: `name`, `email`
  * Validations: presence, uniqueness of email
  * Associations: `has_many :builds`

* **Build**

  * Attributes: `name`, `total_wattage`, `user_id`
  * Associations: `belongs_to :user, optional: true`, `has_many :build_items`, `has_many :parts, through: :build_items`
  * Validations: `name` required

* **BuildItem**

  * Join model between `Build` and `Part`
  * Attributes: `quantity`, `note`
  * Associations: `belongs_to :build`, `belongs_to :part`

* **Part** (STI base class)

  * Attributes: `name`, `brand`, `model_number`, `type`, `price_cents`, `wattage`
  * Subclasses (using STI):

    * `Cpu`
    * `Gpu`
    * `Motherboard`
    * `Memory`
    * `Storage`
    * `Cooler`
    * `PcCase` (renamed from `Case` to avoid conflict with Ruby keyword)
    * `Psu`

---

### Controllers

* **HomeController**

  * `index`: shows sample parts by category and recent builds.

* **UsersController**

  * `index`: list all users.
  * `show`: view user details.

* **PartsController**

  * `index`: list all parts (with optional `q` filter by type).
  * `show`: show details for a part.

* **BuildsController**

  * `index`: list all builds.
  * `show`: view a build and its parts.
  * `new`: form for creating a build with grouped checkboxes by category.
  * `create`: saves build, assigns user (default user if none signed in), creates `BuildItem`s with quantities.

* **SessionsController**

  * `create`: dev login (creates or reuses Harsh user).
  * `destroy`: logout.

---

### Views

* **Home**

  * Displays CPU, GPU, and other categories with sample parts.
  * Shows recent builds.
  * Includes Dev Login/Logout buttons.

* **Users**

  * Index: list users.
  * Show: show user profile.

* **Parts**

  * Index: list all parts (with filter).
  * Show: show details for part.

* **Builds**

  * Index: list builds.
  * Show: show selected parts + quantities.
  * New: grouped checkboxes for each category with quantity input.

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

Seeds include:

* Default user: `Harsh (harsh@example.com)`
* 2 sample entries for each category:

  * CPU: AMD Ryzen 7 7800X3D, Intel i7-14700K
  * GPU: NVIDIA RTX 4080 Super, AMD RX 7900 XT
  * Motherboard: ASUS B650E-F, MSI Z790 Tomahawk
  * Memory: G.Skill Trident Z5 32GB, Corsair Vengeance 64GB
  * Storage: Samsung 990 Pro 2TB, WD Black SN850X 4TB
  * Cooler: Noctua NH-D15, Corsair iCUE H150i
  * PcCase: Fractal Meshify 2, NZXT H7 Flow
  * PSU: Corsair RM850x, Seasonic Prime TX-1000

---

## Development Notes

* Using **STI** for parts (`type` column in `parts` table).
* Acronym models (`Cpu`, `Gpu`, `Psu`) use capitalized first letter but not full uppercase to avoid Zeitwerk conflicts.
* Default login: Dev login sets session to `harsh@example.com`.
* Build creation uses custom logic for `part_ids` and `quantities` instead of mass-assignment.

---

## Next Steps

* Add authentication (Devise or similar).
* Add total price calculation for builds.
* Style UI (Bootstrap/Tailwind).
* Add tests (RSpec).
* API endpoints for builds/parts (JSON).
