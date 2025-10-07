# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'pc_cases/index.html.erb', type: :view do
  before do
    assign(:pc_cases, [
             pc_case(brand: 'Fractal Design', name: 'Define 7', price_cents: 15_000),
             pc_case(brand: 'NZXT', name: 'H510', price_cents: 8000)
           ])
  end

  it 'renders the PC case catalog title' do
    render
    expect(rendered).to match(/PC Case Catalog/)
  end

  it 'displays PC case information' do
    render
    expect(rendered).to include('Fractal Design')
    expect(rendered).to include('Define 7')
    expect(rendered).to include('NZXT')
    expect(rendered).to include('H510')
  end
end
