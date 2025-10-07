# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'coolers/index.html.erb', type: :view do
  before do
    assign(:coolers, [
             cooler(brand: 'Noctua', name: 'NH-D15', price_cents: 9500),
             cooler(brand: 'Corsair', name: 'H100i', price_cents: 12_000)
           ])
  end

  it 'renders the coolers catalog title' do
    render
    expect(rendered).to match(/CPU Cooler Catalog/)
  end

  it 'displays cooler information' do
    render
    expect(rendered).to include('Noctua')
    expect(rendered).to include('NH-D15')
    expect(rendered).to include('Corsair')
    expect(rendered).to include('H100i')
  end

  it 'displays formatted prices' do
    render
    expect(rendered).to include('$95.00')
    expect(rendered).to include('$120.00')
  end
end
