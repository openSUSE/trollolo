def webmock_mapping
  [
    {
      path: 'boards/53186e8391ef8671265eba9d',
      file: 'board.json'
    },
    {
      path: 'boards/53186e8391ef8671265eba9d/lists',
      parameters: {
        "filter" => "open"
      },
      file: 'lists.json'
    },
    {
      path: 'boards/53186e8391ef8671265eba9d',
      parameters: {
        "cards" => "open",
        "lists" => "open"
      },
      file: 'full-board.json'
    }
  ]
end

def parameters_as_string(mapping, parameters = nil)
  parameters ||= []
  if mapping[:parameters]
    mapping[:parameters].each do |key, value|
      parameters.push("#{key}=#{value}")
    end
  end
  if !parameters.empty?
    parameters_string = "?" + parameters.join("&")
  else
    parameters_string = ""
  end
  parameters_string
end

def mapping_url(mapping, parameters = nil)
  url = "https://api.trello.com/1/" + mapping[:path]
  url += parameters_as_string(mapping, parameters)
end

def full_board_mock
  webmock_mapping.each do |mapping|
    url = mapping_url(mapping, [ "key=mykey", "token=mytoken" ])
    stub_request(:get, url)
      .to_return(:status => 200, :body => load_test_file(mapping[:file]))
  end
end
