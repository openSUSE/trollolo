def webmock_mapping
  [
    {
      path: 'boards/myboardid',
      parameters: {
        "key" => "mykey",
        "token" => "mytoken"
      },
      file: 'board.json'
    },
    {
      path: 'boards/123',
      parameters: {
        "key" => "mykey",
        "token" => "mytoken"
      },
      file: 'board.json'
    },
    {
      path: 'boards/53186e8391ef8671265eba9d/lists',
      parameters: {
        "filter" => "open",
        "key" => "mykey",
        "token" => "mytoken"
      },
      file: 'lists.json'
    },
    {
      path: 'lists/53186e8391ef8671265eba9f/cards',
      parameters: {
        "filter" => "open",
        "key" => "mykey",
        "token" => "mytoken"
      },
      file: '53186e8391ef8671265eba9f_list.json'
    },
    {
      path: 'lists/5319bf088cdf9cd82be336b0/cards',
      parameters: {
        "filter" => "open",
        "key" => "mykey",
        "token" => "mytoken"
      },
      file: '5319bf088cdf9cd82be336b0_list.json'
    },
    {
      path: 'lists/53186e8391ef8671265eba9e/cards',
      parameters: {
        "filter" => "open",
        "key" => "mykey",
        "token" => "mytoken"
      },
      file: '53186e8391ef8671265eba9e_list.json'
    },
    {
      path: 'boards/53186e8391ef8671265eba9d',
      parameters: {
        "cards" => "all",
        "key" => "mykey",
        "lists" => "all",
        "token" => "mytoken"
      },
      file: 'board.json'
    }
  ]
end

def full_board_mock
  webmock_mapping.each do |mapping|
    url = "https://api.trello.com/1/" + mapping[:path]
    if mapping[:parameters]
      parameters = []
      mapping[:parameters].each do |key, value|
        parameters.push("#{key}=#{value}")
      end
      url += "?" + parameters.join("&")
    end
    stub_request(:get, url)
      .to_return(:status => 200, :body => load_test_file(mapping[:file]))
  end
end
