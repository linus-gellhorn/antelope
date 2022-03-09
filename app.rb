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
    }
    LIMIT 10
    "

    result = sparql.query(query)

    result.each_solution do |solution|
        solution.each_value    { |value| data["actors"] << value }
    end

    return JSON[data]
  end

end


