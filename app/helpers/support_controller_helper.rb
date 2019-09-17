module SupportControllerHelper
  def permission_set?(role)
    role.permissions.select { |x| x.permission_status == true }.any?
  end
end
