module Scrum
  module CardTypeDetection
    def is_waterline?(card)
      card.name =~ /w.?a.?t.?e.?r.?l.?i.?n.?e/i
    end

    def is_seabed?(card)
      card.name =~ /s.?e.?a.?b.?e.?d/i
    end

    def waterline_card
      @backlog_list.cards.find { |card| is_waterline?(card) }
    end

    def seabed_card
      @backlog_list.cards.find { |card| is_seabed?(card) }
    end
  end
end
