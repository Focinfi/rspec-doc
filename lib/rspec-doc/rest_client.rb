require 'active_record'
require 'rest-client'
require_relative 'markdown_util'

module RSpecDoc::RestClient
  def self.get(example, url, headers={}) 
    example.metadata[:md_doc] ||= {}
    resp = RestClient.get(url, headers)    
    example.metadata[:md_doc][:api_request] = self.make_api_request_md({
      method: :get,
      url: url,
      headers: headers,
      response: resp 
    })
    resp
  end

  def self.post(example, url, payload, headers={})
    example.metadata[:md_doc] ||= {}
    resp = RestClient.post(url, payload, headers)    
    example.metadata[:md_doc][:api_request] = self.make_api_request_md({
      method: :post,
      url: url,
      payload: payload,
      headers: headers, 
      response: resp 
    })
    resp
  end

private
  def self.make_api_request_md(params = {})
    lines = []
    lines << "#{params[:method].to_s.upcase} #{params[:url]}"

    if params[:headers][:params]
      lines << "**Query String Parameters**" 
      lines << RSpecDoc::MarkdownUtil.kv_table(params[:headers][:params])
    end

    params[:headers].delete(:params)
    if params[:headers].size > 0
      lines << "**Request Headers**" 
      lines << RSpecDoc::MarkdownUtil.http_headers_table(params[:headers])
    end

    if params[:payload]
      lines << "**Request Body**" 
      lines << RSpecDoc::MarkdownUtil.json_block(params[:payload])
    end

    lines << "**Response Headers**"
    lines << RSpecDoc::MarkdownUtil.http_headers_table(params[:response].headers)

    if params[:response].headers[:content_type].to_s.include? 'json'
      lines << "**Response Body**"
      lines << RSpecDoc::MarkdownUtil.json_block(params[:response].body)
    end
    
    lines
  end
end