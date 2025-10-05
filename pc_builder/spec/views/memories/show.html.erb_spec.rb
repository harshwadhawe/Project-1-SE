require 'rails_helper'

RSpec.describe "memories/show.html.erb", type: :view do
  before do
    @memory = assign(:memory, memory(brand: 'Corsair', name: 'Vengeance LPX'))
  end

  it 'renders without errors' do
    render
    expect(rendered).to be_present
  end
end
