class Pitch.PitchCreationTour.App
  constructor: ->
    @api = new Tour.API()
    @ui = new Pitch.PitchCreationTour.UI(@api)

  start: ->
    @ui.initPitchCreationTour()
