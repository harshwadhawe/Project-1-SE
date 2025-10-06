require 'rails_helper'

RSpec.describe "motherboards/index.html.erb", type: :view do
  before do
    assign(:motherboards, [
      motherboard(brand: 'ASUS', name: 'ROG Strix B550-F', price_cents: 18000),
      motherboard(brand: 'MSI', name: 'B450 Tomahawk', price_cents: 12000)
    ])
  end

  it 'renders the motherboard catalog title' do
    render
    expect(rendered).to match(/Motherboard Catalog/)
  end

  it 'displays motherboard information' do
    render
    expect(rendered).to include('ASUS')
    expect(rendered).to include('ROG Strix B550-F')
    expect(rendered).to include('MSI')
    expect(rendered).to include('B450 Tomahawk')
  end
end
