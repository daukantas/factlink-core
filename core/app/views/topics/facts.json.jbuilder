json.array!(@facts) do |json, fact|
  json.partial! partial: 'facts/fact',
            formats: [:json], handlers: [:jbuilder],
            locals: {
              fact: fact[:item],
              timestamp: fact[:score]
            }
end
