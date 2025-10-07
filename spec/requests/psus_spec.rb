# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Psus', type: :request do
  describe 'GET /index' do
    it 'returns http success' do
      get '/psus'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /show' do
    it 'returns http success' do
      psu = Psu.create!(brand: 'Corsair', name: 'Test PSU', model_number: 'TEST-001', price_cents: 12_000, wattage: 0)
      get "/psus/#{psu.id}"
      expect(response).to have_http_status(:success)
    end
  end
end
