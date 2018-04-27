module Scrum
  module CardTypeDetection
    def sticky?(card)
      by_label(card, 'sticky')
    end

    def ci?(card)
      by_label(card, 'ci')
    end

    def interrupt?(card)
      by_label(card, 'interrupt')
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

    private

    def by_label(card, label)
      card.labels.any? { |l| l.name == @settings.label_names[label] }
    end
  end
end
