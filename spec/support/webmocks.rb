def full_board_mock
  stub_request(:get, %r{https://api.trello.com/1/boards/.*\?key=.*&token=.*\Z})
      .to_return(:status => 200, :body => load_test_file('board.json'))
  stub_request(:get, %r{https://api.trello.com/1/boards/.*/lists\?filter=open&key=.*&token=.*\Z})
      .to_return(:status => 200, :body => load_test_file('lists.json'))
  stub_request(:get, 'https://api.trello.com/1/lists/53186e8391ef8671265eba9f/cards?filter=open&key=mykey&token=mytoken')
      .to_return(:status => 200, :body => load_test_file('53186e8391ef8671265eba9f_list.json'))
  stub_request(:get, 'https://api.trello.com/1/lists/5319bf088cdf9cd82be336b0/cards?filter=open&key=mykey&token=mytoken')
      .to_return(:status => 200, :body => load_test_file('5319bf088cdf9cd82be336b0_list.json'))
  stub_request(:get, 'https://api.trello.com/1/lists/53186e8391ef8671265eba9e/cards?filter=open&key=mykey&token=mytoken')
      .to_return(:status => 200, :body => load_test_file('53186e8391ef8671265eba9e_list.json'))
  stub_request(:get, %r{https://api.trello.com/1/boards/.*\?cards=all&key=.*&lists=all&token=.*})
      .to_return(:status => 200, :body => load_test_file('board.json'))
end
