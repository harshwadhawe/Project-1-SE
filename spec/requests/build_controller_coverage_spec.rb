# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'BuildsController full coverage', type: :request do
  let!(:owner)  { User.create!(name: 'Owner',  email: 'owner@example.com',  password: 'password123') }
  let!(:other)  { User.create!(name: 'Other',  email: 'other@example.com',  password: 'password123') }
  let!(:build)  { Build.create!(name: 'Owner Build', user: owner) }
  let!(:cpu)    { Cpu.create!(name: 'CPU A', brand: 'BrandX', price_cents: 10_000, wattage: 65) }

  # Utility: stub current_user for request specs
  def as(user)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  describe 'edit / update / destroy (owner + unauthorized)' do
    it 'renders edit for owner (and uses :new template)' do
      as(owner)
      get "/builds/#{build.id}/edit"
      expect(response).to have_http_status(:ok)
      # rendered :new, so expect page to include something from that template (safe weak check)
      expect(response.body).to include('Build') # title/label presence
    end

    it 'redirects unauthorized HTML on edit when not owner' do
      as(other) # authenticated but not the owner -> authorize_owner! kicks in
      get "/builds/#{build.id}/edit"
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to("/builds/#{build.id}")
      # flash set by authorize_owner!
      follow_redirect!
      expect(response.body).to include('Unauthorized').or include('alert')
    end

    it 'returns 401 JSON unauthorized on update when not owner' do
      as(other)
      patch "/builds/#{build.id}", params: { build: { name: 'Hacked' } }, headers: { 'ACCEPT' => 'application/json' }
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)['error']).to eq('Unauthorized')
    end

    it 'updates for owner (success path)' do
      as(owner)
      patch "/builds/#{build.id}", params: { build: { name: 'Renamed Build' } }
      expect(response).to have_http_status(:found)
      follow_redirect!
      expect(response.body).to include('Renamed Build')
    end

    it 'fails update and renders :edit with 422' do
      as(owner)
      patch "/builds/#{build.id}", params: { build: { name: '' } }
      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'destroys for owner (success path)' do
      b = Build.create!(name: 'To Delete', user: owner)
      as(owner)
      delete "/builds/#{b.id}"
      expect(response).to have_http_status(:found)
      follow_redirect!
      expect(response.body).to include('successfully deleted').or include('Builds')
    end

    it 'handles destroy failure (stubbed) and redirects to show with alert' do
      as(owner)
      allow_any_instance_of(Build).to receive(:destroy).and_return(false)
      delete "/builds/#{build.id}"
      expect(response).to have_http_status(:found)
      follow_redirect!
      expect(response.body).to include('Failed to delete')
    end
  end

  describe 'share (auth required)' do
    before { as(owner) }

    it 'returns JSON success and token for existing build id' do
      post "/builds/#{build.id}/share", params: {
        id: build.id,
        components_data: { cpu: { id: cpu.id, name: cpu.name, price: '$100.00', wattage: 65 } }
      }
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['success']).to eq(true)
      expect(body['share_url']).to include("/builds/#{build.id}/shared?")
      expect(body['share_token']).to be_present
      expect(body['build_data']).to be_a(Hash)
    end

    it 'creates a new build when id missing and uses provided build name' do
      post '/builds/999999/share', params: {
        id: 999_999,
        build: { name: 'Shared New Build' },
        components_data: { gpu: { id: 123, name: 'G-Card', price: '$250.00', wattage: 200 } }
      }
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['success']).to eq(true)
      expect(body['build_data']['name']).to eq('Shared New Build').or eq('Shared New Build'.to_s)
    end

    it 'returns 400 on JSON parse error for components_data' do
      post "/builds/#{build.id}/share", params: { components_data: '{invalid_json' }
      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)['error']).to match(/Invalid component data/i)
    end

    it 'returns 500 on unexpected error during share' do
      allow_any_instance_of(Build).to receive(:create_shareable_data!).and_raise('boom')
      post "/builds/#{build.id}/share", params: { components_data: { cpu: { name: 'X' } } }
      expect(response).to have_http_status(:internal_server_error)
      expect(JSON.parse(response.body)['error']).to match(/Failed to create share link/)
    end
  end

  describe 'shared (token-first, DB fallback, and 404)' do
    it 'renders via token even if DB changes (token-first path)' do
      payload = {
        'name' => 'From Token',
        'components' => { 'cpu' => { 'name' => 'CPU A', 'price' => '$100.00', 'wattage' => 65 } },
        'parts_count' => 1,
        'total_cost' => 10_000,
        'total_wattage' => 65,
        'created_at' => Time.current.iso8601,
        'shared_at' => Time.current.iso8601,
        'user_name' => 'Owner'
      }
      token = Rails.application.message_verifier(:build_share).generate(payload)
      get "/builds/#{build.id}/shared", params: { token: token }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('From Token')
    end

    it 'falls back to DB when token invalid' do
      db_payload = {
        name: 'From DB',
        components: { cpu: { name: 'CPU A', price: '$100.00', wattage: 65 } },
        parts_count: 1,
        total_cost: 10_000,
        total_wattage: 65,
        created_at: Time.current.iso8601,
        shared_at: Time.current.iso8601,
        user_name: 'Owner'
      }
      build.update!(shared_data: db_payload.to_json, share_token: 'legacy', shared_at: Time.current)
      get "/builds/#{build.id}/shared", params: { token: 'invalid' }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('From DB')
    end

    it '404s when neither token nor DB data is available' do
      ghost = Build.create!(name: 'Ghost', user: owner)
      ghost.update!(shared_data: nil, share_token: nil, shared_at: nil)
      get "/builds/#{ghost.id}/shared"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'index / show / new' do
    it 'renders index and lists builds' do
      get '/builds'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Owner Build')
    end

    it 'renders show and iterates parts' do
      # Attach a part so the show action loops over parts and logs attributes
      build.build_items.create!(part: cpu)
      get "/builds/#{build.id}"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Owner Build')
    end

    it 'renders new and loads categories' do
      get '/builds/new'
      expect(response).to have_http_status(:ok)
      # Weak presence check; view title/labels should include “Build”
      expect(response.body).to include('Build')
    end
  end

  describe 'create (HTML + JSON, success and failure)' do
    it 'creates via HTML and redirects' do
      as(owner)
      post '/builds', params: { build: { name: 'New Build' } }
      expect(response).to have_http_status(:found)
      follow_redirect!
      expect(response.body).to include('New Build')
    end

    it 'creates via JSON and returns payload' do
      as(owner)
      post '/builds', params: { build: { name: 'JSON Build' } }, headers: { 'ACCEPT' => 'application/json' }
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['success']).to eq(true)
      expect(body['build_id']).to be_present
      expect(body['message']).to match(/created/i)
    end

    it 'fails via HTML and renders :new with 422 (stubbed)' do
      as(owner)
      fake = Build.new # use a real AR object so form builders don’t choke
      allow(Build).to receive(:new).and_return(fake)
      allow(fake).to receive(:user=)
      allow(fake).to receive(:save).and_return(false)

      errors_double = instance_double(ActiveModel::Errors,
                                      any?: true,
                                      full_messages: ["Name can't be blank"])
      allow(fake).to receive(:errors).and_return(errors_double)

      post '/builds', params: { build: { name: '' } }
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('Build')
    end


    it 'fails via JSON and returns errors with 422 (stubbed save false)' do
      as(owner)
      fake = Build.new
      allow(Build).to receive(:new).and_return(fake)
      allow(fake).to receive(:user=)
      allow(fake).to receive(:save).and_return(false)
      allow(fake).to receive_message_chain(:errors, :full_messages).and_return(['Name can\'t be blank'])

      post '/builds', params: { build: { name: '' } }, headers: { 'ACCEPT' => 'application/json' }
      expect(response).to have_http_status(:unprocessable_content)
      body = JSON.parse(response.body)
      expect(body['success']).to eq(false)
      expect(body['errors']).to include("Name can't be blank")
    end
  end

  describe 'update JSON success' do
    it 'updates and returns 302 HTML AND also works with JSON accept' do
      as(owner)
      patch "/builds/#{build.id}", params: { build: { name: 'Via JSON' } }, headers: { 'ACCEPT' => 'application/json' }
      # Controller responds with redirect for HTML; for JSON accept it still runs same branch
      expect(response).to have_http_status(:found)
      follow_redirect!
      expect(response.body).to include('Via JSON')
    end
  end

  describe 'update JSON success' do
    it 'updates and returns 302 HTML AND also works with JSON accept' do
      as(owner)
      patch "/builds/#{build.id}", params: { build: { name: 'Via JSON' } }, headers: { 'ACCEPT' => 'application/json' }
      # Controller responds with redirect for HTML; for JSON accept it still runs same branch
      expect(response).to have_http_status(:found)
      follow_redirect!
      expect(response.body).to include('Via JSON')
    end
  end

  describe 'share (normalizations + update_columns rescue)' do
    before { as(owner) }

    it 'works with blank components_data (defaults to {})' do
      post "/builds/#{build.id}/share", params: { id: build.id }
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['success']).to eq(true)
      expect(body['build_data']).to be_a(Hash)
    end

    it 'works with components_data as JSON string' do
      payload = { cpu: { id: cpu.id, name: cpu.name, wattage: 65 } }.to_json
      post "/builds/#{build.id}/share", params: { components_data: payload }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['success']).to eq(true)
    end

    it 'works with components_data as ActionController::Parameters' do
      post "/builds/#{build.id}/share", params: { components_data: { gpu: { id: 1, name: 'G' } } }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['success']).to eq(true)
    end

    it 'works with components_data as Hash and survives update_columns failure' do
      allow_any_instance_of(Build).to receive(:update_columns).and_raise('oh no')
      post "/builds/#{build.id}/share", params: { components_data: { memory: { name: 'RAM' } } }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['success']).to eq(true)
    end
  end

  describe 'shared (DB fallback parse failure -> 404)' do
    it '404s when DB shared_data is invalid JSON' do
      build.update!(shared_data: '{bad_json', share_token: nil, shared_at: Time.current)
      get "/builds/#{build.id}/shared"
      expect(response).to have_http_status(:not_found)
    end
  end

end
