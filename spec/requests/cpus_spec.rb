# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Cpus', type: :request do
  describe 'GET /index' do
    it 'returns http success' do
      get '/cpus'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /show' do
    it 'returns http success' do
      cpu = Cpu.create!(brand: 'AMD', name: 'Test CPU', model_number: 'TEST-001', price_cents: 30_000, wattage: 65)
      get "/cpus/#{cpu.id}"
      expect(response).to have_http_status(:success)
    end
  end
end
