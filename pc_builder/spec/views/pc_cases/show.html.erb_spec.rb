require 'rails_helper'

RSpec.describe "pc_cases/show.html.erb", type: :view do
  before do
    @pc_case = assign(:pc_case, pc_case(brand: 'Fractal Design', name: 'Define 7'))
  end

  it 'renders without errors' do
    render
    expect(rendered).to be_present
  end
end
