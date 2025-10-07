# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Motherboards', type: :request do
  describe 'GET /index' do
    it 'returns http success' do
      get '/motherboards'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /show' do
    it 'returns http success' do
      motherboard = Motherboard.create!(brand: 'ASUS', name: 'Test Motherboard', model_number: 'TEST-001',
                                        price_cents: 20_000, wattage: 25)
      get "/motherboards/#{motherboard.id}"
      expect(response).to have_http_status(:success)
    end
  end
end
