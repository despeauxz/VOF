$(document).ready ->
  if pageUrl[1] is 'pitch'

    if ((pageUrl[2] && typeof Number(pageUrl[2]) == 'number' && pageUrl.length == 3) ||
    pageUrl[2] is 'setup' || !pageUrl[2] || pageUrl[3] is 'edit')
      pitchSetupApp = new Pitch.PitchSetup.App()
      pitchSetupApp.start()
      pitchSetupTour = new Pitch.PitchSetupTour.App()
      pitchSetupTour.start()
      
    if (pageUrl[1] == 'pitch' and pageUrl[2] == 'setup')
      pitchCreationTour = new Pitch.PitchCreationTour.App()
      pitchCreationTour.start()
      

    if pageUrl[3] is 'edit'
      pitchSetupApp.update(pageUrl[2])
      pitchEditTour = new Pitch.PitchEditTour.App()
      pitchEditTour.start()

     if (pageUrl.length == 6 && typeof Number(pageUrl[2]) == 'number' && typeof Number(pageUrl[4]) == 'number' &&
     typeof Number(pageUrl[5]) == 'number' && pageUrl[3] is 'panels' && pageUrl[5] != 'edit' )
       pitchRateLearnerTour = new Pitch.PitchRateLearnerTour.App()
       pitchRateLearnerTour.start()

    if !isNaN(pageUrl[2]) and !pageUrl[3]
      pitchPageTour = new Pitch.PitchPageTour.App()
      pitchPageTour.start()
