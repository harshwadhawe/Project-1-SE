require 'rails_helper'

RSpec.describe "gpus/show.html.erb", type: :view do
  before do
    @gpu = assign(:gpu, gpu(brand: 'NVIDIA', name: 'RTX 4080'))
  end

  it 'renders without errors' do
    render
    expect(rendered).to be_present
  end
end
