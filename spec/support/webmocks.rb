def webmock_mapping
  [
    {
      url: 'https://api.trello.com/1/boards/myboardid?key=mykey&token=mytoken',
      file: 'board.json'
    },
    {
      url: 'https://api.trello.com/1/boards/123?key=mykey&token=mytoken',
      file: 'board.json'
    },
    {
      url: 'https://api.trello.com/1/boards/53186e8391ef8671265eba9d/lists?filter=open&key=mykey&token=mytoken',
      file: 'lists.json'
    },
    {
      url: 'https://api.trello.com/1/lists/53186e8391ef8671265eba9f/cards?filter=open&key=mykey&token=mytoken',
      file: '53186e8391ef8671265eba9f_list.json'
    },
    {
      url: 'https://api.trello.com/1/lists/5319bf088cdf9cd82be336b0/cards?filter=open&key=mykey&token=mytoken',
      file: '5319bf088cdf9cd82be336b0_list.json'
    },
    {
      url: 'https://api.trello.com/1/lists/53186e8391ef8671265eba9e/cards?filter=open&key=mykey&token=mytoken',
      file: '53186e8391ef8671265eba9e_list.json'
    },
    {
      url: 'https://api.trello.com/1/boards/53186e8391ef8671265eba9d?cards=all&key=mykey&lists=all&token=mytoken',
      file: 'board.json'
    }
  ]
end

def full_board_mock
  webmock_mapping.each do |mapping|
    stub_request(:get, mapping[:url])
      .to_return(:status => 200, :body => load_test_file(mapping[:file]))
  end
end
