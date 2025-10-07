require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the BuildItemsHelper. For example:
#
# describe BuildItemsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe BuildItemsHelper, type: :helper do
  describe 'module inclusion' do
    it 'includes the helper module' do
      expect(helper.class.included_modules).to include(BuildItemsHelper)
    end
  end
end
