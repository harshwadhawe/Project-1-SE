# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'cpus/show.html.erb', type: :view do
  before do
    @cpu = assign(:cpu, cpu(brand: 'AMD', name: 'Ryzen 7 5800X'))
  end

  it 'renders without errors' do
    render
    expect(rendered).to be_present
  end
end
