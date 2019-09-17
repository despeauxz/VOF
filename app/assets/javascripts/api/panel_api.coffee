class Panel.API
  getPanelData: (size, page) ->
    url = "/pitch/#{pageUrl[2]}/panels"
    return $.ajax(
      url: "#{url}?size=#{size}&page=#{page}"
      type: "GET"
      success: (data) ->
        return data
      error: (error) ->
        afterError(error.statusText)
    )

  deletePanel: (panelId, afterError) ->
    return $.ajax(
      url: "/pitch/#{pageUrl[2]}/panels/#{panelId}"
      type: "DELETE"
      success: (data) ->
        return data
      error: (error) ->
        afterError(error.statusText)
    )

  getAllCampersInPitch: (pitch_id, afterError) ->
    return $.ajax(
      url: "/pitch/#{pitch_id}/panels/new"
      type: "GET"
      error: (error) ->
        afterError(error.statusText)
  )

  createPanel: (data, afterError) ->
    return $.ajax(
      url: "/pitch/#{pageUrl[2]}/panels"
      type: "POST"
      data: data
      error: (error) ->
        afterError(error.statusText)
    )

  editPanel: (panelId, afterError) ->
    return $.ajax(
      url: "/pitch/#{pageUrl[2]}/panels/#{panelId}/edit"
      type: "GET"
      error: (error) ->
        afterError(error.statusText)
    )

  updatePanel: (data, afterError) ->
    return $.ajax(
      url: "/pitch/#{pageUrl[2]}/panels/#{pageUrl[4]}"
      type: "PUT"
      data: data
      error: (error) ->
        afterError(error.statusText)
    )
    
  submitLearnersRating: (data, afterError) ->
      return $.ajax(
        url: "/pitch/panel/submit_learner_ratings"
        type: "POST"
        data: data
        error: (error) ->
          afterError(error.statusText)
      )

  # method for GET requests on pitches
  getPitchRatingSummary: (size, page, filterParams='') ->
    return $.ajax(
        url: "/pitch/#{pageUrl[2]}/summary_ratings?page=#{page}&size=#{size}&filterParams=#{filterParams}"
        type: "GET"
        error: (error) ->
          afterError(error.statusText)
      )

