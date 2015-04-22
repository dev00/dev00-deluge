require 'spec_helper'
describe 'deluge' do

  context 'with defaults for all parameters' do
    it { should contain_class('deluge') }
  end
end
