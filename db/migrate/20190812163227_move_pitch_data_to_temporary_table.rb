class MovePitchDataToTemporaryTable < ActiveRecord::Migration[5.0]
  def change
    Pitch.all.each do |pitch|
      @panel = Panel.create(
        pitch_id: pitch.id,
        panel_name: "Panel-#{pitch.id}"
      )
      learners_pitches(pitch).each do |learner_pitch|
        move_learner_pitches_to_new_learners_panels(
          @panel.id,
          learner_pitch["camper_id"]
        )
        new_learner_panel = select_created_new_learner_panel(
          @panel.id,
          learner_pitch["camper_id"]
        )
        panelists = Panelist.where(pitch_id: pitch.id)
        panelists.each do |panelist|
          move_panelist_to_new_panelist(panelist, @panel.id)
          new_panelist = select_created_new_panelist(panelist, @panel.id)
          @ratings = Rating.where(
            panelist_id: panelist.id,
            learners_pitch_id: learner_pitch["id"]
          )
          @ratings.each do |rating|
            ActiveRecord::Base.connection.execute(
              new_ratings_insert_sql(
                new_panelist["id"],
                new_learner_panel["id"],
                rating
              )
            )
          end
        end
      end
    end
  end

  def learners_pitches(pitch)
    sql = "SELECT * FROM learners_pitches WHERE pitch_id=#{pitch.id}"
    ActiveRecord::Base.connection.execute(sql).to_a
  end

  def select_created_new_panelist(panelist, panel_id)
    ActiveRecord::Base.connection.execute(
      select_created_new_panelist_sql(
        panelist,
        panel_id
      )
    ).to_a.first
  end

  def select_created_new_panelist_sql(panelist, panel_id)
    <<-SQL.squish
     SELECT * FROM new_panelists
     WHERE panel_id='#{panel_id}'AND email='#{panelist.email}'AND
     accepted='#{panelist.accepted}' LIMIT 1
    SQL
  end

  def move_panelist_to_new_panelist(panelist, panel_id)
    ActiveRecord::Base.connection.execute(
      insert_sql_panelist_to_new_panelist(
        panelist,
        panel_id
      )
    )
  end

  def insert_sql_panelist_to_new_panelist(panelist, panel_id)
    <<-SQL.squish
     INSERT INTO new_panelists(panel_id,email,accepted,created_at,updated_at)
     VALUES('#{panel_id}','#{panelist.email}','#{panelist.accepted}',
     '#{Date.today}','#{Date.today}')
    SQL
  end

  def select_created_new_learner_panel(panel_id, camper_id)
    ActiveRecord::Base.connection.execute(
      raw_select_created_learner_panel_sql(
        panel_id,
        camper_id
      )
    ).to_a.first
  end

  def raw_select_created_learner_panel_sql(panel_id, camper_id)
    <<-SQL.squish
     SELECT * FROM new_learners_panels
     WHERE panel_id='#{panel_id}' AND camper_id='#{camper_id}' LIMIT 1
    SQL
  end

  def move_learner_pitches_to_new_learners_panels(panel_id, camper_id)
    ActiveRecord::Base.connection.execute(
      insert_new_learner_panel_sql(
        panel_id,
        camper_id
      )
    )
  end

  def insert_new_learner_panel_sql(panel_id, camper_id)
    <<-SQL.squish
    INSERT INTO new_learners_panels(panel_id,camper_id,created_at,updated_at)
    VALUES('#{panel_id}','#{camper_id}','#{Date.today}','#{Date.today}')
    SQL
  end

  def new_ratings_insert_sql(panelist_id, learner_panel_id, rate)
    <<-SQL.squish
   INSERT INTO new_ratings (new_panelist_id,new_learners_panel_id,
   ui_ux,api_functionality,error_handling,project_understanding,
   presentational_skill,decision,comment,created_at,updated_at)VALUES('#{panelist_id}',
   '#{learner_panel_id}','#{rate.ui_ux}','#{rate.api_functionality}',
   '#{rate.error_handling}','#{rate.project_understanding}','#{rate.presentational_skill}',
   '#{rate.decision}','#{rate.comment.gsub(/[^a-z ]/, '')}','#{Date.today}','#{Date.today}')
    SQL
  end
end
