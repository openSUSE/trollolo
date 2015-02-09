def webmock_mapping
  [
    {
      url: %r{https://api.trello.com/1/boards/.*\?key=.*&token=.*\Z},
      file: 'board.json'
    },
    {
      url: %r{https://api.trello.com/1/boards/.*/lists\?filter=open&key=.*&token=.*\Z},
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
      url: %r{https://api.trello.com/1/boards/.*\?cards=all&key=.*&lists=all&token=.*},
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
