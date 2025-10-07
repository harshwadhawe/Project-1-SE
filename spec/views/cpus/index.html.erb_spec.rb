# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'cpus/index.html.erb', type: :view do
  before do
    assign(:cpus, [
             cpu(brand: 'AMD', name: 'Ryzen 7 5800X', price_cents: 35_000),
             cpu(brand: 'Intel', name: 'i7-11700K', price_cents: 32_000)
           ])
  end

  it 'renders the CPUs catalog title' do
    render
    expect(rendered).to match(/CPU Catalog/)
  end

  it 'displays CPU information' do
    render
    expect(rendered).to include('AMD')
    expect(rendered).to include('Ryzen 7 5800X')
    expect(rendered).to include('Intel')
    expect(rendered).to include('i7-11700K')
  end
end
