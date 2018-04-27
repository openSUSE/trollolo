module Pairing
  class PairingBoard
    include Scrum::CardTypeDetection

    def self.setup(settings, board_id)
      PairingBoard.new(settings.pairing).setup(board_id)
    end

    def initialize(settings)
      @settings = settings
    end
    attr_accessor :board

    def setup(board_id)
      @board = Trello::Board.find(board_id)
      self
    end

    def devs
      devs_list.cards.first.member_ids
    end

    def tracks
      tracks_list.cards
    end

    def devs_list
      @board.lists.find { |l| l.name == @settings.list_names['devs'] }
    end

    def tracks_list
      @board.lists.find { |l| l.name == @settings.list_names['tracks'] }
    end

    def pair
    end
  end
end
