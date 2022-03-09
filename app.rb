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

get '/movies' do
    data = {}
    
    query = "
    SELECT DISTINCT ?movieName
    WHERE {
      ?movie dbo:starring dbr:Judi_Dench;
      rdfs:label ?movieName .
      FILTER (lang(?movieName) = 'en')
    }
    LIMIT 10
    "

  result = sparql.query(query)
  result.each_solution do |solution|
    solution.each_value    { |value| puts value }
  end

  data
end

get '/cast' do
    data = {}
    
    query = "
    SELECT ?l
    WHERE {
    ?movie a dbo:Film.
    ?movie rdfs:label 'Love Actually'@en.
    ?movie dbo:starring ?p.
    ?p rdfs:label ?l
    filter (lang(?l)='en')
    }"

  result = sparql.query(query)
  result.each_solution do |solution|
    solution.each_value    { |value| puts value }
  end

  data
end

