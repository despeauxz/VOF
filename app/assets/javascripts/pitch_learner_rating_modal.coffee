$(document).ready ->
  learnerModal = new Pitch.LearnerRatingModal.App()
  if ($('.lfa-modal-dialog').css('display') == 'none')
        $('.view-score-breakdown').text('View score breakdown')
        $('<span><i class="fa fa-angle-down"></i></span>').appendTo( $( ".view-score-breakdown" ) );
  learnerModal.start()
  $(".tab-btn-back-icon").on 'click', () ->
    window.location.href = "/pitch/#{pageUrl[2]}/panels"
