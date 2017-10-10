require 'active_record'
require 'method_source'

require_relative 'markdown_util'

module RSpecDoc::ActiveRecord  
  def self.describe(example, model, &block)
    model_name = model.to_s
    id = ''
    if model.is_a?(ActiveRecord::Base)
      model_name = "#{model.class.table_name}"
      id = "[id=#{model.id}]"
    end

    db_assertion_md = make_db_assertion_md(block.source)
    return unless db_assertion_md

    example.metadata[:md_doc] ||= {}
    example.metadata[:md_doc][:database_assertion] ||= []
    example.metadata[:md_doc][:database_assertion].concat(
      ["**#{model_name}**#{id}", db_assertion_md]
    )

    block.call
  end

private
  EQUAL_MATCHERS = ['eq', 'eql', 'equal', 'be']

  def self.is_symbol(is)
    return is ? '==' : '!='
  end

  def self.is_string(is)
    return is ? '' : 'does not'
  end

  def self.matcher_name(is, matcher)
    return self.is_symbol(is) if EQUAL_MATCHERS.include? matcher   

    "#{self.is_string(is)} #{matcher}"
  end

  def self.make_db_assertion_md(expectation_source)
    expectation_source = expectation_source.lstrip
    # get the target obj name 
    /\.describe[\(\s+]example,\s+(?<model>.*)[\)\s+]do/ =~ expectation_source
    return nil unless model
    
    model.chomp!(')')    
    items = []
    # select the target obj item 
    expectation_source.gsub!(model, 'model')
    expectation_source.gsub!('be_', 'be ')
    expectation_items = expectation_source.lines do |line| 
      key, matcher, value = nil
      /expect\(model\.(?<key>.*)\)\.(?<is>to|not_to)[\s+\(](?<matcher>.*)[\s+\(](?<value>.*)[\,\)\s+\n]/ =~ "#{line.strip}\n"
      next unless key && is && matcher && value
      
      value = value.strip.chomp(')' * (value.count(')') - value.count('('))) # remove tailing extra ')'
      begin
        value = eval(value).inspect
      rescue => exception
        value = "`#{value}`"
      end

      items << [key.strip, "#{matcher_name(is == 'to', matcher.strip)}", value]
    end

    # build markdown table 
    RSpecDoc::MarkdownUtil.table(['Column', 'Assertion', 'Value'], items)
  end 
end
