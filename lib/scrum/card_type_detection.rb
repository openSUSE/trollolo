module Scrum
  module CardTypeDetection
    def sticky?(card)
      card.labels.any? { |l| l.name == "Sticky" }
    end

    def waterline?(card)
      card.name =~ /w.?a.?t.?e.?r.?l.?i.?n.?e/i
    end

    def seabed?(card)
      card.name =~ /s.?e.?a.?b.?e.?d/i
    end

    def waterline_card
      @backlog_list.cards.find { |card| waterline?(card) }
    end

    def seabed_card
      @backlog_list.cards.find { |card| seabed?(card) }
    end
  end
end
