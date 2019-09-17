class Panel.ViewPanelTour.App
  constructor: ->
   @api = new Tour.API()
   @ui = new Panel.ViewPanelTour.UI(@api)

  start: -> 
   @ui.initViewPanelTour() 
