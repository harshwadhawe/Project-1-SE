# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'psus/show.html.erb', type: :view do
  before do
    @psu = assign(:psu, psu(brand: 'Corsair', name: 'RM850x'))
  end

  it 'renders without errors' do
    render
    expect(rendered).to be_present
  end
end
