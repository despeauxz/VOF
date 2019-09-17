class Pitch.PitchRatingBreakdown.UI
  constructor: (@api) ->

  initialize: ->
    @registerEventListeners()
    @handlePanelistClick()
    @learnerRatingsBreakdown()
    @handleEditedRatingSubmission()

  registerEventListeners: ->
    self = @

    $(".edit-button, .cancel-button").on 'click', () ->
      $('.actual-rating, .edit-rating, #submit-edited-rating-button, .cancel-button, .edit-button').toggle()

  fetchLearnerRatings: (panelistId) ->
    self = @
    self.learners_pitch_id = pageUrl[4]
    self.api.getLearnerRatings(self.learners_pitch_id, self.flashErrorMessage)
    .then((data) ->
      ratingDetails = data.rating_details.ratings
      ratingPerPanelist = ratingDetails.filter (data) -> data.panelist_id == Number(panelistId)
      self.populateRatings(ratingPerPanelist[0])
    )
  
  handlePanelistClick: ->
    self = @
    panelistCardOne = $(".one-panelist").first().addClass('one-panelist-active')
    if panelistCardOne
      cardId = $(".one-panelist-active").attr('id')
      filteredRating = self.fetchLearnerRatings(cardId)

    $(".one-panelist").on 'click', (e) ->
      $(".one-panelist").each(() ->
        if $(this).hasClass('one-panelist-active')
          $(this).removeClass('one-panelist-active')
        )
      panelistCard = $(this).addClass('one-panelist-active')
      if panelistCard
        cardId = $(".one-panelist-active").attr('id')
        filteredRating = self.fetchLearnerRatings(cardId)

  learnerRatingsBreakdown: ->
    self = @
    self.learners_pitch_id = pageUrl[4]
    self.api.getLearnerRatings(self.learners_pitch_id, self.flashErrorMessage)
    .then((data) ->
      ratingDetails = data.rating_details
      self.populateLearnerAverageRatings(ratingDetails)
    )
  
  averageRating: (key, data) ->
    averageValue
    sumValue = 0
    value = (eachRating) ->
      eachRating[key]
    sumValue += value(eachRating) for eachRating in data
    return averageValue = (sumValue / data.length).toFixed(1)

  populateLearnerAverageRatings: (ratingDetails) ->
    self = @
    ratingsData = ratingDetails.ratings
    cumulativeAverage = Number(self.averageRating('ui_ux', ratingsData)) +
    Number(self.averageRating('api_functionality', ratingsData)) +
    Number(self.averageRating('error_handling', ratingsData)) +
    Number(self.averageRating('project_understanding', ratingsData)) +
    Number(self.averageRating('presentational_skill', ratingsData))
    $(".cumulative-ratings").find(".ui-ux").html(
      self.averageRating('ui_ux', ratingsData)
    )
    $(".cumulative-ratings").find(".api-functionality").html(
      self.averageRating('api_functionality', ratingsData)
    )
    $(".cumulative-ratings").find(".error-handling").html(
      self.averageRating('error_handling', ratingsData)
    )
    $(".cumulative-ratings").find(".project-understanding").html(
      self.averageRating('project_understanding', ratingsData)
    )
    $(".cumulative-ratings").find(".presentation-skills").html(
      self.averageRating('presentational_skill', ratingsData)
    )
    $(".cumulative-ratings").find(".cumulative-average-rating").html(
      (cumulativeAverage / 5).toFixed(1)
    )

  populateRatings: (rating) ->
    self = @
    firstName = rating.panelist_email.split(".")[0]
    lastName = (rating.panelist_email.split(".")[1].split("@"))[0]
    panelistNames = "#{firstName} #{lastName}'s"
    $(".panelist-name-header").html(panelistNames)

    panelistDetails = "#{firstName} #{lastName}"
    $(".panelist-name-body").html(panelistDetails)

    firstLetter = firstName.slice(0, 1)
    lastLetter = lastName.slice(0, 1)

    imageLetters = "#{firstLetter}#{lastLetter}"

    $(".one-panelist-image").html(imageLetters)

    $(".learner-ratings-per-panelist").find(".ui-ux").html(rating.ui_ux)
    $('input[id="ui-ux"]').attr('placeholder', rating.ui_ux)

    $(".learner-ratings-per-panelist").find(".api-functionality").html(
      rating.api_functionality
    )
    $('input[id="api-functionality"]').attr('placeholder', rating.api_functionality)

    $(".learner-ratings-per-panelist").find(".error-handling").html(
      rating.error_handling
    )
    $('input[id="error-handling"]').attr('placeholder', rating.error_handling)

    $(".learner-ratings-per-panelist").find(".project-understanding").html(
      rating.project_understanding
    )
    $('input[id="project-understanding"]').attr('placeholder', rating.project_understanding)

    $(".learner-ratings-per-panelist").find(".presentation-skills").html(
      rating.presentational_skill
    )
    $('input[id="presentation-skills"]').attr('placeholder', rating.presentational_skill)

    decision = rating.decision
    if decision == "Yes"
      $(".decision-word-wrapper").css("background-color", "#00B803")
      $('input[value="yes"]').prop('checked', true)
    else if decision == "Maybe"
      $(".decision-word-wrapper").css("background-color", "#DFC20A")
      $('input[value="maybe"]').prop('checked', true)
    else if decision == "No"
      $(".decision-word-wrapper").css("background-color", "#DF0A00")
      $('input[value="no"]').prop('checked', true)

    $(".decision-word").html(rating.decision)
    $(".decision-comment").html(rating.comment)
    $('textarea[id="edit-comment"]').val(rating.comment)

  toastMessage: (message, status) ->
    $('.toast').messageToast.start(message, status)
    
  flashErrorMessage: (message) ->
    @toastMessage(message, 'error')

  collectEditData: (ratings_id) ->
    self = @
    editedRating = {}
    ratingError = false

    editedRating.ui_ux = if $('input[id="ui-ux"]').val() != "" then Number($('input[id="ui-ux"]').val()) else Number($('input[id="ui-ux"]').attr('placeholder'));

    editedRating.api_functionality =
      if $('input[id="api-functionality"]').val() != "" then Number($('input[id="api-functionality"]').val()) else Number($('input[id="api-functionality"]').attr('placeholder'));

    editedRating.error_handling =
      if $('input[id="error-handling"]').val() != "" then Number($('input[id="error-handling"]').val()) else Number($('input[id="error-handling"]').attr('placeholder'));

    editedRating.project_understanding =
      if $('input[id="project-understanding"]').val() != "" then Number($('input[id="project-understanding"]').val()) else Number($('input[id="project-understanding"]').attr('placeholder'));

    editedRating.presentational_skill =
      if $('input[id="presentation-skills"]').val() != "" then Number($('input[id="presentation-skills"]').val()) else Number($('input[id="presentation-skills"]').attr('placeholder'));

    for k,v of editedRating
      if Number(v) < 1 || Number(v) > 5 || isNaN(Number(v))
        ratingError = true
        
    if ratingError
      self.flashErrorMessage("All ratings should range from 1 to 5")
    else
      editedRating.decision = $('input[name="decision"]:checked').val()
      editedRating.comment = $('textarea[id="edit-comment"]').val()
      self.api.editLearnersRating(ratings_id, editedRating, self.flashErrorMessage)
        .then(() ->
        self.toastMessage("Rating successfully updated", "success")
        location.reload()
      )

  handleEditedRatingSubmission: ->
    self = @
    $('.submit-button').on 'click', () ->
      $(".one-panelist").each(() ->
        if $(this).hasClass('one-panelist-active')
          ratingId = $(".panelist-info").attr('id')
          self.collectEditData(ratingId)
      )
