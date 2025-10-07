# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'coolers/show.html.erb', type: :view do
  before do
    @cooler = assign(:cooler, cooler(brand: 'Noctua', name: 'NH-D15'))
  end

  it 'renders without errors' do
    render
    expect(rendered).to be_present
  end
end
