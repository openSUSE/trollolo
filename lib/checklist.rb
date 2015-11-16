class Checklist
  def initialize(checklist_data)
    @checklist_data = checklist_data
  end

  def name
    @checklist_data["name"]
  end
end
