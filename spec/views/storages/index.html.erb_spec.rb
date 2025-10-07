require 'rails_helper'

RSpec.describe "storages/index.html.erb", type: :view do
  before do
    assign(:storages, [
      storage(brand: 'Samsung', name: '980 PRO', price_cents: 15000),
      storage(brand: 'WD', name: 'Black SN850', price_cents: 13000)
    ])
  end

  it 'renders the storage catalog title' do
    render
    expect(rendered).to match(/Storage Catalog/)
  end

  it 'displays storage information' do
    render
    expect(rendered).to include('Samsung')
    expect(rendered).to include('980 PRO')
    expect(rendered).to include('WD')
    expect(rendered).to include('Black SN850')
  end
end
