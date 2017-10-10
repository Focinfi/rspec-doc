require 'json'

module RSpecDoc::MarkdownUtil
  def self.table(header, body)
    return '' unless header.is_a?(Enumerable) and body.is_a?(Enumerable)

    header_line = "| #{header.join(' | ')} |"
    direction_line = "| #{':--- |' * header.size}"
    [header_line, direction_line]
      .concat(body.map { |item| "| #{item.join(' | ')} |" })
      .join("\n")
  end

  def self.kv_table(kv, params = {})
    return '' unless kv

    kv = JSON.parse(kv) if kv.is_a? String
    items = []
    kv.each do |key, value|
      next unless value

      value = value.map { |k, v| "#{k}: #{v}" }.join("\n") if value.is_a? Hash
      value = value.join("\n") if value.is_a? Enumerable
      key = params[:key_formatter].call(key) if params[:key_formatter].is_a? Proc
      items << [key, value]
    end

    return '' if items.size == 0 

    self.table(['Key', 'Value'], items)
  end

  def self.http_headers_table(kv)
    formatter = -> (k) { k.to_s.split('_').map(&:capitalize).join('-') }
    self.kv_table(kv, {key_formatter: formatter})
  end

  def self.code_block(type, body)
    [
      "```#{type.to_s}",
      body,
      '```'
    ].join("\n")
  end

  def self.json_block(h)
    h = JSON.parse(h) if h.is_a? String
    self.code_block(:json, JSON.pretty_generate(h))
  end
end