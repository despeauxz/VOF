class Panel.PanelEditTour.App
  constructor: ->
    @api = new Tour.API()
    @ui = new Panel.PanelEditTour.UI(@api)

   start: ->
    @ui.initPanelEditTour()
