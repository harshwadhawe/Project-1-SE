require 'rails_helper'

RSpec.describe "memories/index.html.erb", type: :view do
  before do
    assign(:memories, [
      memory(brand: 'Corsair', name: 'Vengeance LPX', price_cents: 8000),
      memory(brand: 'G.Skill', name: 'Trident Z', price_cents: 9500)
    ])
  end

  it 'renders the memory catalog title' do
    render
    expect(rendered).to match(/Memory Catalog/)
  end

  it 'displays memory information' do
    render
    expect(rendered).to include('Corsair')
    expect(rendered).to include('Vengeance LPX')
    expect(rendered).to include('G.Skill')
    expect(rendered).to include('Trident Z')
  end
end
