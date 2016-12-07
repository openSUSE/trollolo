module Scrum
  class PriorityName
    PRIORITY_REGEX      = /^(?:\([\d.]+\) )?P(\d+): /

    def priority(name)
      return unless m = name.match(PRIORITY_REGEX)
      m.captures.first.to_i
    end

    def build(name, n)
      return name.sub(/P\d+: /, "P#{n}: ") if priority(name)
      "P#{n}: #{name}"
    end
  end
end
