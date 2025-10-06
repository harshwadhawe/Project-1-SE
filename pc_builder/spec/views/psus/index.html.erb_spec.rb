require 'rails_helper'

RSpec.describe "psus/index.html.erb", type: :view do
  before do
    assign(:psus, [
      psu(brand: 'Corsair', name: 'RM850x', price_cents: 14000),
      psu(brand: 'EVGA', name: 'SuperNOVA 750 G3', price_cents: 12000)
    ])
  end

  it 'renders the PSU catalog title' do
    render
    expect(rendered).to match(/Power Supply Catalog/)
  end

  it 'displays PSU information' do
    render
    expect(rendered).to include('Corsair')
    expect(rendered).to include('RM850x')
    expect(rendered).to include('EVGA')
    expect(rendered).to include('SuperNOVA 750 G3')
  end
end
