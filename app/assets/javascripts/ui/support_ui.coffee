class Support.SupportSetup.UI
  constructor: (@api) ->
    @accordion = new Accordion.UI()
    @deleteConfirmationModal = new Modal.App('#panel-delete-confirmation-modal', 500, 500, 255, 255)

  initialize: ->
    @getUsers()
    @getRolePermissions()

  toastMessage: (message, status) ->
    $('.toast').messageToast.start(message, status)

  flashErrorMessage: (message) =>
    @toastMessage(message, 'error')

  flashSuccessMessage: (message) =>
    @toastMessage(message, 'success')

  getUsers: =>
    self  = @
    self.api.getUsersCall(self.flashErrorMessage)
      .then((data) -> (
        self.populateUsersTable(data.users)
      ))

  populateUsersTable: (users) =>
    self = @
    if (users && users.length > 0)
        users_list = ''
        users.map (user) ->
            name = user.email.split(".")
            first_name = name[0]
            second_name = name[1].split("@")[0]
            users_list += """
                <tr class="user-row-#{user.id}">
                    <td class="roles-permissions-username">#{first_name} #{second_name}</td>
                    <td class="roles-permissions-email">#{user.email}</td>
                    <td class="roles-permissions-role">
                        <span class="selected-role">#{user.role_name}</span>
                        <span class="role-selection">
                            Admin
                            <%= image_tag("down-blue.svg") %>
                        </span>
                    </td>
                    <td class="roles-permissions-edit-delete">
                    <span class="edit">Edit</span>
                    <span class="role-button delete" data-id="#{user.id}">Delete</span>
                    <span class="save-changes">Save changes</span>
                    </td>
                </tr>
            """
        $('.roles-and-permission-body').html(users_list)
        $('.no-users-message').hide()
    else
        $('.users-table').hide()
        $('.no-users-message').show()

    @openDeleteConfirmationModal()

  getRolePermissions: ->
    self = @
    $(".set-permissions, .view-permissions").click(->
      self.roleId =  $(this).data("role-id")
      self.api.getRoleData(self.roleId, self.toastMessage)
        .then((data) -> (
          self.populateRolePermissions(data)
        ))
    )

  populateRolePermissions: (permissionsByFeature) =>
    self = @
    $("#permissions-body").html("")
    permissionsByFeature.forEach((feature, index) ->
      self.getPermissionRows(feature, index)
    )
    @accordion.initAccordion()

  getPermissionRows: ({ feature, role, role_id, permissions }, index) =>
    self = @
    featureName = feature.replace(/_/g, " ").toLowerCase()
    $(".permissions-for-new .back-text").html("Permissions for #{role}")
    permission = """
      <div class="permissions-item">
        <div class="permissions-title
        faq-question accordion-section-title" href="#accordion-10#{index}">
          <span class='chevron-down-circle'></span><span class='chevron-right-circle'></span>
          <span class="permissions-tab-title">#{featureName}</span>
          <span class="view-permissions">Click to View Permissions</span>
        </div>
        <div id="accordion-10#{index}" class="accordion-section-content permissions-tab">
          <table class="table permissions-table permissions--option" id="learner_rating_table">
            <thead>
            <tr class="tr-head">
              <th></th>
              <th>#{role}</th>
            </tr>
            </thead>
            <tbody class="permission-attribute-#{index}">
            </tbody>
          </table>
        </div>
      </div>
    """
    $("#permissions-body").append(permission)
    permissions.forEach((attribute) ->
      self.getPermissionAttributes(attribute, index)
    )

  getPermissionAttributes: (attribute, index) =>
    self = @
    permissionName = attribute.permission_name.replace(/_/g, " ").toLowerCase();
    row = """
    <tr class="tr_row">
      <td class="permissions-tab-subtitle">#{permissionName}</td>
      <td>
        <label class="radio-container">
          <input type="checkbox" name="#{attribute.permission_name}" value="Admin">
          <span class="radio-mark"></span>
        </label>
      </td>
    </tr>
    """
    $(".permission-attribute-#{index}").append(row)
    if attribute.permission_status
      $("input[name='#{attribute.permission_name}']").prop('checked', true)

    $("input[name='#{attribute.permission_name}']").off('click').click ->
      if $("input[name='#{attribute.permission_name}']").is(':checked')
        self.setPermisions(attribute.id, true)
      else
        self.setPermisions(attribute.id, false)

  setPermisions: (id, status) ->
    self = @
    data = {
      permission_id: id,
      permission_status: status
    }
    @api.assignPermision(self.roleId, data, @flashErrorMessage)
      .then((data) ->
        if data.permission_status
          $(".set-perm-#{self.roleId}").hide()
          $(".set-permisssion-#{self.roleId}").hide()
          $(".view-perm-#{self.roleId}").hide()
          $(".view-permission-#{self.roleId}").show()
        else
          $(".view-perm-#{self.roleId}").hide()
          $(".view-permission-#{self.roleId}").hide()
          $(".set-perm-#{self.roleId}").hide()
          $(".set-permisssion-#{self.roleId}").show()
      )


  openDeleteConfirmationModal: ->
    self = @
    $(".role-button.delete").off 'click'
    $(".role-button.delete").on 'click', ->
      self.userId = $(this)[0].dataset.id
      self.deleteConfirmationModal.open()
      self.closeDeleteConfirmationModal()
      self.deleteUser(self.userId)

  closeDeleteConfirmationModal: ->
    self = @
    $('.close-delete-modal, .cancel-btn').on 'click', ->
      self.deleteConfirmationModal.close()

  deleteUser: (userId) ->
    self = @
    $('#confirm-delete-user').off('click').click ->
      self.api.deleteUser(userId, self.flashErrorMessage)
        .then((data) ->  (
          if data.error
            self.flashErrorMessage(data.error)
            self.deleteConfirmationModal.close()
          else
            self.flashSuccessMessage(data.message)
            self.deleteConfirmationModal.close()
            self.removeDeletedUser(userId)
        ))

  removeDeletedUser: (userId) ->
    $(".user-row-#{userId}").remove()
    rowcount = $('.roles-and-permission-table tr').length
    if (rowcount == 1)
      $('.users-table').hide()
      $('.no-users-message').show()
