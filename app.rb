require 'sinatra'
require 'sparql/client'

sparql = SPARQL::Client.new("http://dbpedia.org/sparql")

get '/' do
  # matches "GET /?actor=foo&film=bar"
  actor = params['actor']
  film = params['film']

  # Getting the text of query string to determine which data to send back
  parameters = request.query_string
  
  # Provide an actor, return their films
  if parameters.include? "actor="
    puts "Returning films for #{actor}"
    
    data = {"films" => []}
    
    query = "
    SELECT DISTINCT ?movieName
    WHERE {
      ?movie dbo:starring dbr:#{actor};
      rdfs:label ?movieName .
      FILTER (lang(?movieName) = 'en')
    }
    LIMIT 10
    "

    result = sparql.query(query)

    result.each_solution do |solution|
        solution.each_value    { |value| data["films"] << value }
    end

    return JSON[data]
  end

  # Provide a film, return the cast
  if parameters.include? "film="
    film_transformed_to_spaces = film.gsub('_',' ')

    puts "Returning cast for #{film_transformed_to_spaces}"
    data = {"actors" => []}
    
    query = "
    SELECT ?l
    WHERE {
    ?movie a dbo:Film.
    ?movie rdfs:label '#{film_transformed_to_spaces}'@en.
    ?movie dbo:starring ?p.
    ?p rdfs:label ?l
    filter (lang(?l)='en')
    }"

    result = sparql.query(query)

    result.each_solution do |solution|
        solution.each_value    { |value| data["actors"] << value }
    end

    return JSON[data]
  end

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
  
get '/films' do
    data = {"films" => []}
    
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
    solution.each_value    { |value| data["films"] << value }
  end

  JSON[data]
end

get '/actors' do
    data = {"actors" => []}
    
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
    solution.each_value    { |value| data["actors"] << value }
  end

  JSON[data]
end

