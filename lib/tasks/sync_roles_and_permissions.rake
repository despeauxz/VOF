namespace :roles_and_permissions do
  desc "Sync new roles with permissions"
  task sync: :environment do
    @permissions = YAML.load_file(
      Rails.root.join("config", "permissions.yml")
    )
    @roles = Role.all
    if @roles.any?
      @roles.each do |role|
        @permissions.each do |feature, permissions|
          @feature = Feature.find_or_create_by(feature_name: feature)
          permissions.each do |permission_name|
            Permission.where(
              role_id: role.id,
              feature_id: @feature.id,
              permission_name: permission_name
            ).first_or_create!
          end
        end
      end
    end
  end
end
