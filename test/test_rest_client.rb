require 'test/unit'
require 'rspec-doc'
require_relative 'mock'

# mock the RestClient post method
module RestClient
  class MockPostResponse
    attr_accessor :headers, :body
  end

  def self.post(url, payload, headers={})
    response = MockPostResponse.new
    response.headers = {
        content_type: 'application/json; charset=UTF-8'
    }
    response.body = {
      foo: 1
    }
    response
  end
end

class RestClientTest < Test::Unit::TestCase
  def test_post
    expected = [
      'POST http://demo.loc',      
      '**Request Headers**',
      "| Key | Value |\n| :--- |:--- |\n| Cookies | rememberteleport: 1b2CKOkA_qQyFBLeUkw5GGmq0V8ssA== |",
      "**Request Body**",
      "```json\n{\n  \"name\": \"foo\"\n}\n```",
      '**Response Headers**',
      "| Key | Value |\n| :--- |:--- |\n| Content-Type | application/json; charset=UTF-8 |",
      '**Response Body**',
      "```json\n{\n  \"foo\": 1\n}\n```"
    ]

    example = MockExample.new
    RSpecDoc::RestClient.post(
      example,
      'http://demo.loc',
      {name: 'foo'},
      {cookies: {rememberteleport: '1b2CKOkA_qQyFBLeUkw5GGmq0V8ssA=='}}
    )

    assert_equal expected, example.metadata[:md_doc][:api_request]
  end
end