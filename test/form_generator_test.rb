require 'test_helper'
require 'rails/generators/form/form_generator'
describe Rails::Generators::FormGenerator do
  let(:arguments) { ['test'] }
  let(:content) { File.read("./tmp/generators/app/forms/#{arguments[0]}_form.rb") }

  before do
    Rails::Generators.invoke('form', arguments, destination_root: './tmp/generators')
  end

  after do
    FileUtils.rm_rf './tmp/generators'
  end

  it 'generates form' do
    content.must_match /^class TestForm < Reform::Form$/
  end

  describe 'when properties are present' do
    let(:arguments) { ['second_test', 'username', 'password'] }

    it 'generates form with properties' do
      content.must_match /^  property :username$/
      content.must_match /^  property :password$/
    end
  end
end
