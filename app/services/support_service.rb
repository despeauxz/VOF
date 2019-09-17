require "default_json_files_service"

class SupportService < DefaultJsonFileService
  def get_support_data
    read_file("support_data.json")
  end
end
