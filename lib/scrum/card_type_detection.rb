module Scrum
  module CardTypeDetection
    def is_waterline?(card)
      card.name =~ /w.?a.?t.?e.?r.?l.?i.?n.?e/i
    end

    def is_seabed?(card)
      card.name =~ /s.?e.?a.?b.?e.?d/i
    end
  end
end
