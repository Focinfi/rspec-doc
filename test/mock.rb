class MockExample
  attr_accessor :metadata

  def initialize()
    @metadata = {} 
  end
end

class MockExpectation
  def initialize(targert)
    @targert = targert
  end

  def to(matcher)
  end

  def not_to(matcher)
  end
end

class MockModel
  def id
    1
  end

  def self.table_name
    'mock_target'
  end

  def name
    'haha'
  end

  def is_a?(c)
    true
  end
end

module MockRSpec
  def expect(targert)
    MockExpectation.new(targert) 
  end

  def eq(expected)
  end
end