SELECT 
ratings.learners_panel_id, 
learners_panels.panel_id, 
learners_panels.camper_id, 
bootcampers.first_name,
bootcampers.last_name,
AVG(ratings.ui_ux) AS avg_ui_ux,
AVG(ratings.api_functionality) AS avg_api_functionality,
AVG(ratings.error_handling) AS avg_error_handling,
AVG(ratings.project_understanding) AS avg_project_understanding,
AVG(ratings.presentational_skill) AS avg_presentational_skill,
AVG(ui_ux + api_functionality + error_handling + project_understanding + presentational_skill)/5.0 AS cumulative_average
FROM ratings
INNER JOIN learners_panels ON (ratings.learners_panel_id = learners_panels.id)
INNER JOIN bootcampers ON (learners_panels.camper_id = bootcampers.camper_id)
GROUP BY
ratings.learners_panel_id,
learners_panels.camper_id,
bootcampers.first_name,
bootcampers.last_name,
learners_panels.panel_id
