class Pitch.PitchLearnerSubmission.App
  constructor: ->
    @api = new Pitch.API()
    @panel_api = new Panel.API()
    @ui = new Pitch.PitchLearnerSubmission.UI(@api, @panel_api)

  start: =>
    @ui.initialize()
