class LearnersProfile.App
  constructor: ->
    @api = new LearnersProfile.API()
    @ui = new LearnersProfile.UI(@api)

  start: ->
    @ui.initializeEditPersonalDetails()
    @ui.initializeEditOutputLinks()
