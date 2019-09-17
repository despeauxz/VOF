require "default_json_files_service"

class DecisionService < DefaultJsonFileService
  def get_decision_data
    read_file("decision_data.json")
  end
end
