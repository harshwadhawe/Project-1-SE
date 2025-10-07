require 'rails_helper'

RSpec.describe "motherboards/show.html.erb", type: :view do
  before do
    @motherboard = assign(:motherboard, motherboard(brand: 'ASUS', name: 'ROG Strix B550-F'))
  end

  it 'renders without errors' do
    render
    expect(rendered).to be_present
  end
end
