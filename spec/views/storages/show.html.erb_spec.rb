require 'rails_helper'

RSpec.describe "storages/show.html.erb", type: :view do
  before do
    @storage = assign(:storage, storage(brand: 'Samsung', name: '980 PRO'))
  end

  it 'renders without errors' do
    render
    expect(rendered).to be_present
  end
end
