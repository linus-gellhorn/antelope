require 'sinatra'
require 'sparql/client'

sparql = SPARQL::Client.new("http://dbpedia.org/sparql")

get '/' do
  'Hello world!'
end

get '/test' do
  'Testing, testing, 123.'
end

get '/hello/:name' do
  # matches "GET /hello/foo" and "GET /hello/bar"
  # params['name'] is 'foo' or 'bar'
  "Hello #{params['name']}!"
end

get '/posts' do
  # matches "GET /posts?title=foo&author=bar"
  title = params['title']
  author = params['author']
  # uses title and author variables; query is optional to the /posts route
  author
  title
end

get '/db' do
  # ASK WHERE { ?s ?p ?o }
  result = sparql.ask.whether([:s, :p, :o]).true?
  puts result.inspect   # => true or false
  result.inspect
end