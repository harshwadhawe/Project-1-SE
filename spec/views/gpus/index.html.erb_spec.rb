require 'rails_helper'

RSpec.describe "gpus/index.html.erb", type: :view do
  before do
    assign(:gpus, [
      gpu(brand: 'NVIDIA', name: 'RTX 4080', price_cents: 120000),
      gpu(brand: 'AMD', name: 'RX 7800 XT', price_cents: 50000)
    ])
  end

  it 'renders the GPUs catalog title' do
    render
    expect(rendered).to match(/GPU Catalog/)
  end

  it 'displays GPU information' do
    render
    expect(rendered).to include('NVIDIA')
    expect(rendered).to include('RTX 4080')
    expect(rendered).to include('AMD')
    expect(rendered).to include('RX 7800 XT')
  end
end
