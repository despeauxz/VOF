$(document).ready =>
  if ((pageUrl[1] && typeof Number(pageUrl[2]) == 'number' && pageUrl.length == 4)) && (pageUrl[3] is 'panels')
    panelSetupApp = new Panel.PanelSetup.App()
    panelSetupApp.start()
    panelSetupTour = new Panel.PanelsPageTour.App()
    panelSetupTour.start()
    
  if typeof Number(pageUrl[2]) == 'number' && pageUrl[3] is 'panels' && pageUrl[4] is 'new'
    panelSetupApp = new Panel.PanelSetup.App()
    panelSetupApp.pitchPanel()
    PanelSetupTour = new Panel.PanelSetupTour.App()
    PanelSetupTour.start()

  if typeof Number(pageUrl[2]) == 'number' && pageUrl[3] is 'panels' && pageUrl[5] is 'edit'
    panelSetupApp = new Panel.PanelSetup.App()
    panelSetupApp.update(pageUrl[4])
    panelEditTour = new Panel.PanelEditTour.App()
    panelEditTour.start()

  if typeof Number(pageUrl[2]) == 'number' && pageUrl[3] is 'panels' && pageUrl[4] != 'new' && typeof Number(pageUrl[4]) == 'number' && pageUrl.length == 5
    learnerModal = new Pitch.LearnerRatingModal.App()
    if ($('.lfa-modal-dialog').css('display') == 'none')
        $('.view-score-breakdown').text('View score breakdown')
        $('<span><i class="fa fa-angle-down"></i></span>').appendTo( $( ".view-score-breakdown" ) );
    learnerModal.start()
    $(".tab-btn-back-icon").on 'click', () ->
      window.location.href = "/pitch/#{pageUrl[2]}/panels"
    viewPanelTour = new Panel.ViewPanelTour.App()
    viewPanelTour.start()
       
