class Support.API
  getUsersCall: (afterError) ->
    return $.ajax(
      url: "/support/users"
      type: "GET"
      contentType: 'application/json'
      error: (error) ->
        afterError(error.statusText)
    )

  getRoleData: (id, notification) ->
    return $.ajax({
      url: "/support/roles/#{id}/permissions"
      type: "GET"
      error: ({ responseJSON: { message } }) ->
        notification(message, 'error')
    })

  assignPermision: (id, data, afterError) ->
    return $.ajax(
      url: "/support/roles/#{id}/permissions/assign_permission"
      type: "PUT"
      data: data
    )

  deleteUser: (userId, afterError) ->
    return $.ajax(
      url: "/support/users/#{userId}"
      type: "DELETE"
      success: (data) ->
        return data
      error: (error) ->
        afterError(error.statusText)
    )
