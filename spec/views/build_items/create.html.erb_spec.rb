# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'build_items/create.html.erb', type: :view do
  it 'exists as a view template' do
    # This is a basic test to ensure the view template exists
    # Most create actions redirect, so this template might be minimal
    render
    expect(rendered).to be_present
  end
end
