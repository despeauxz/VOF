class Pitch.PitchEditTour.App
  constructor: ->
    @api = new Tour.API
    @ui = new Pitch.PitchEditTour.UI(@api)

  start: ->
    @ui.initPitchEditTour()
