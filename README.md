# rspec-doc

A gem help build markdown for rspec testing.

### Install

`gem install rspec-doc`

### Generate models

Generate `ActiveRecord` models based on the specified database.

1. Create the `database_config.yml` file

```yaml
my_db:
  adapter: mysql2
  host: <% ENV['MY_DB_HOST'] >
  database: my_app
  port: 3306
  username: root
  password: <% ENV['MY_DB_PASSWORD'] >
  rare_map_opts:
    foreign_key:
      alias:
        user_id: account
```

You can write erb code in the `database_config.yml` file.

This tool using `rare_map`, look [more detail](https://github.com/wnameless/rare_map).

2. Run `rspecdoc build_models`

3. New models will be added into `./app/models` directory.

4. The `./demo.rb` show you how to require these models all.

### Build markdown for rspec files

**HTTP Request**

rspec file `metaweather_spec.rb`

```ruby
require 'rspec-doc' 

RSpec.describe 'www.metaweather.com' do
  describe 'query location' do 
    it 'responses 200' do |example|
      resp = RSpecDoc::RestClient.get(
        example,
        'https://www.metaweather.com/api/location/search/?query=beijing'
      )

      expect(resp.code).to eq 200
    end
  end
end
```

run the rspec command:

`rspec metaweather_spec.rb  --require 'rspec-doc' --format RSpecDoc::MarkdownFormatter`

outputs:

```markdown
## www.metaweather.com

### query location
  - responses 200

    #### Api Request

    GET https://www.metaweather.com/api/location/search/?query=beijing

    **Response Headers**

    | Key | Value |
    | :--- |:--- |
    | X-Xss-Protection | 1; mode=block |
    | Content-Language | en |
    | X-Content-Type-Options | nosniff |
    | Strict-Transport-Security | max-age=2592000; includeSubDomains |
    | Vary | Accept-Language, Cookie |
    | Allow | GET, HEAD, OPTIONS |
    | X-Frame-Options | DENY |
    | Content-Type | application/json |
    | X-Cloud-Trace-Context | 725f020745ba04e2b8004a753c8ee7bc |
    | Date | Tue, 10 Oct 2017 08:40:29 GMT |
    | Server | Google Frontend |
    | Content-Length | 95 |

    **Response Body**

    ```json
    [
      {
        "title": "Beijing",
        "location_type": "City",
        "woeid": 2151330,
        "latt_long": "39.906010,116.387909"
      }
    ]
    ```

Finished in 1.24 seconds (files took 0.65387 seconds to load)
```

**ActiveRecord**

rspec files `dog_spec.rb`

```ruby
require 'sqlite3'
require 'active_record'
require 'rspec-doc'

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database =>  'demo.db'
)

ActiveRecord::Migration.class_eval do
  create_table :dogs do |t|
    t.string :name
  end
end

class Dog < ActiveRecord::Base
end

RSpec.describe Dog do
  describe 'create' do
    it 'find the inserted dog' do |example|
      Dog.create({
        name: 'foo'        
      })

      dog = Dog.first
      # just wrap the origin expectation statements in the RSpecDoc::ActiveRecord.describe block
      RSpecDoc::ActiveRecord.describe(example, dog) do
        expect(dog.name).to eq 'foo'
      end
    end
  end
end
```

run the rspec command:

`rspec dog_spec.rb --require 'rspec-doc' --format RSpecDoc::MarkdownFormatter`

outputs:

```markdown
## Dog

### create
  - find the inserted dog

    #### Database Assertion

    **dogs**[id=1]

    | Column | Assertion | Value |
    | :--- |:--- |:--- |
    | name | == | "foo" |

Finished in 0.01727 seconds (files took 0.76396 seconds to load)
```

### Test

`rake test`
