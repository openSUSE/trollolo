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
      path: 'lists/53186e8391ef8671265eba9f/cards',
      parameters: {
        "filter" => "open"
      },
      file: '53186e8391ef8671265eba9f_list.json'
    },
    {
      path: 'lists/5319bf088cdf9cd82be336b0/cards',
      parameters: {
        "filter" => "open"
      },
      file: '5319bf088cdf9cd82be336b0_list.json'
    },
    {
      path: 'lists/53186e8391ef8671265eba9e/cards',
      parameters: {
        "filter" => "open"
      },
      file: '53186e8391ef8671265eba9e_list.json'
    },
    {
      path: 'boards/53186e8391ef8671265eba9d',
      parameters: {
        "cards" => "all",
        "lists" => "all"
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
