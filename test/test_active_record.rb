require 'test/unit'
require 'rspec-doc'
require 'active_record'
require_relative 'mock'

class TestActiveRecord < Test::Unit::TestCase 
  include MockRSpec

  def test_describe
    example = MockExample.new
    targert = MockModel.new
    RSpecDoc::ActiveRecord.describe(example, targert) do
      expect(targert.name).to eq 'haha'
    end

    expected = [
      '**mock_target**[id=1]',
      "| Column | Assertion | Value |\n| :--- |:--- |:--- |\n| name | == | \"haha\" |"
    ]

    assert_equal expected, example.metadata[:md_doc][:database_assertion]
  end 
end