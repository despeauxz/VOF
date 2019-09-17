class Panel.PanelsPageTour.App
  constructor: ->
    @api = new Tour.API()
    @ui = new Panel.PanelsPageTour.UI(@api)

  start: ->
    @ui.initPanelsPageTour()
