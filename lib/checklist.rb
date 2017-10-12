class Checklist
  def initialize(checklist_data)
    @checklist_data = checklist_data
  end

  def name
    @checklist_data["name"]
  end

  def checklist_items
    @checklist_data["checkItems"]
  end

  def done_tasks
    checklist_items.count { |list_item| list_item["state"] == "complete" }
  end

  def tasks
    checklist_items.count
  end
end
