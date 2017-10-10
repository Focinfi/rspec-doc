require 'test/unit'
require 'rspec-doc'

class MarkdownUtilTest < Test::Unit::TestCase
  def test_table
    expected_table_markdown = p %{| Name | Followers | Likes |
| :--- |:--- |:--- |
| Foo | 3 | Apple |
| Bar | 10 | Sky |}

    table_markdown = RSpecDoc::MarkdownUtil.table(
      ['Name', 'Followers', 'Likes'],
      [
        ['Foo', 3, 'Apple'],
        ['Bar', 10, 'Sky']
      ]
    )

    assert_equal expected_table_markdown, table_markdown
  end

  def test_json_blcok
    expected = p %{```json
{
  "foo": "bar",
  "followers": 3,
  "likes": [
    "apples",
    "sky"
  ]
}
```}

    target_hash = {
      foo: 'bar',
      followers: 3,
      likes: [
        'apples',
        'sky'
      ]
    }

    assert_equal expected, RSpecDoc::MarkdownUtil.json_block(target_hash)
    assert_equal expected, RSpecDoc::MarkdownUtil.json_block(target_hash.to_json)
  end

  def test_http_headers_table
    expected = p %{| Key | Value |
| :--- |:--- |
| Access-Control-Allow-Origin | * |
| Content-Length | 126 |}

    target_hash = {
      access_control_allow_origin: '*',
      content_length: 126
    }

    assert_equal expected, RSpecDoc::MarkdownUtil.http_headers_table(target_hash)
  end
end
