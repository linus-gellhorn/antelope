require 'sinatra'
require 'sparql/client'

sparql = SPARQL::Client.new("http://dbpedia.org/sparql")

previous_actor_queries = {}
previous_film_queries = {}

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

    if previous_actor_queries.key?(actor)
      puts "#{actor} is already in storage..."
      # Early return from storage hash
      data_from_storage = { "films" => previous_actor_queries[actor]}
      return JSON[data_from_storage]
    end

    actor_query = "
    SELECT DISTINCT ?movieName
    WHERE {
      ?movie dbo:starring dbr:#{actor};
      rdfs:label ?movieName .
      FILTER (lang(?movieName) = 'en')
    }
    LIMIT 10
    "

    result = sparql.query(actor_query)

    result.each_solution do |solution|
        solution.each_value    { |value| data["films"] << value }
    end

    previous_actor_queries.merge!(actor => data["films"])
    puts "So now actors storage is:"
    puts previous_actor_queries

    return JSON[data]
  end

  # Provide a film, return the cast
  if parameters.include? "film="
    film_transformed_to_spaces = film.gsub('_',' ')
    puts "Returning cast for #{film_transformed_to_spaces}"
   
    data = {"actors" => []}

    if previous_film_queries.key?(film)
      puts "#{film} is already in storage..."
      # Early return from storage hash
      data_from_storage = { "actors" => previous_film_queries[film]}
      return JSON[data_from_storage]
    end
    
    film_query = "
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

    result = sparql.query(film_query)

    result.each_solution do |solution|
        solution.each_value    { |value| data["actors"] << value }
    end

    previous_film_queries.merge!(film => data["actors"])
    puts "So now films storage is:"
    puts previous_film_queries

    return JSON[data]
  end

end


