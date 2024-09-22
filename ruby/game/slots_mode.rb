module TrogBuild
  class SlotsMode < Mode
    def custom_top_comment; 'Main slots mode' end
    def slow_tick;'650ms' end
    def medium_tick;'500ms' end
    def fast_tick;'375ms' end

    def add_timers!
      @countdown = Timer.new('slots_countdown', 30, 0, '1000ms', true, true, false)
      add_timer(@countdown)
      @rotate = Timer.new('slots_rotate', 1, 0, slow_tick, true, true, true)
      @rotate.add_tick_option('slow', slow_tick)
      @rotate.add_tick_option('medium', medium_tick)
      @rotate.add_tick_option('fast', fast_tick)
      add_timer(@rotate)
    end

    def add_shots!
      slot_square = ShotProfile.new('slot_square_profile', false)
      slot_square.add_state('inactive', 'off', nil)
      slot_square.add_state('active', 'on_color', {'color' => 'orange'})
      slot_square.add_state('locked', 'on_color', {'color' => 'red'})
      slot_square.add_state('complete_locked', 'on_color', {'color' => 'green'})
      slot_square.set_state_names_to_not_rotate('locked, complete_locked')

      add_shot_profile(slot_square)

      center = 's_drop_bank_center'
      left = 's_drop_bank_left'
      right = 's_drop_bank_right'
      a = Shot.new('slots_a', slot_square, left,   true, {'light' => 'gl_grid_1'})
      b = Shot.new('slots_b', slot_square, center, true, {'light' => 'gl_grid_2'})
      c = Shot.new('slots_c', slot_square, right,  true, {'light' => 'gl_grid_3'})
      d = Shot.new('slots_d', slot_square, left,   true, {'light' => 'gl_grid_4'})
      e = Shot.new('slots_e', slot_square, center, true, {'light' => 'gl_grid_5'})
      f = Shot.new('slots_f', slot_square, right,  true, {'light' => 'gl_grid_6'})
      g = Shot.new('slots_g', slot_square, left,   true, {'light' => 'gl_grid_7'})
      h = Shot.new('slots_h', slot_square, center, true, {'light' => 'gl_grid_8'})
      i = Shot.new('slots_i', slot_square, right,  true, {'light' => 'gl_grid_9'})
      grid_shots = [a, b, c, d, e, f, g, h, i]

      grid_shots.each do |s|
        add_shot(s)
        add_event_player(s.state_hit(1), [s.set_state_event(2), slots_active_scored])
      end

      @left_column_rotation_group = ShotGroup.new('left_column_rotation_group', [a, d, g], true)
      add_shot_group(@left_column_rotation_group)
      @center_column_rotation_group = ShotGroup.new('center_column_rotation_group', [b, e, h], true)
      add_shot_group(@center_column_rotation_group)
      @right_column_rotation_group = ShotGroup.new('right_column_rotation_group', [c, f, i], true)
      add_shot_group(@right_column_rotation_group)

      add_event_player(set_initial_targets, [g.set_state_event(1), h.set_state_event(1), i.set_state_event(1)])

      row_groups = []
      [[a,b,c], [d,e,f], [g,h,i]].map.with_index do |line_group, i|
        sg = ShotGroup.new("slot_row_#{i+1}_group", line_group, false)
        add_shot_group(sg)
        add_event_player("slot_row_#{i+1}_group_locked_complete", [row_locked_event, @rotate.stop_event])
        sg
      end

      diagonal_groups = [[a,e,i], [g,e,c]].map.with_index do |diag_group, i|
        sg = ShotGroup.new("slot_diagonal_#{i+1}_group", diag_group, false)
        add_shot_group(sg)
        add_event_player("slot_diagonal_#{i+1}_group_locked_complete", [diagonal_locked_event, @rotate.stop_event])
        sg
      end

      neighbor_pair_groups = [
        [a,b,f], [a,e,f], [a,b,i], [a,h,i],
        [d,b,c], [d,e,c], [d,e,i], [d,h,i],
        [g,b,c], [g,h,c], [g,e,f], [g,h,f]
      ].map.with_index do |neighbor_group, i|
        sg = ShotGroup.new("slot_neighborpair_#{i+1}_group", neighbor_group, false)
        add_shot_group(sg)
        add_event_player("slot_neighborpair_#{i+1}_group_locked_complete", [neighborpair_locked_event, @rotate.stop_event])
        sg
      end

      split_pair_groups = [
        [a,e,c], [a,h,c],
        [d,b,f], [d,h,f],
        [g,b,i], [g,e,i]
      ].map.with_index do |split_group, i|
        sg = ShotGroup.new("slot_splitpair_#{i+1}_group", split_group, false)
        add_shot_group(sg)
        add_event_player("slot_splitpair_#{i+1}_group_locked_complete", [splitpair_locked_event, @rotate.stop_event])
        sg
      end

      singles_groups = [[a,h,f], [d,h,c], [d,b,i], [g,b,f]].map.with_index do |single_group, i|
        sg = ShotGroup.new("slot_singles_#{i+1}_group", single_group, false)
        add_shot_group(sg)
        add_event_player("slot_singles_#{i+1}_group_locked_complete", [singles_locked_event, @rotate.stop_event])
        sg
      end
    end

    def add_variable_players!
      add_variable_player(slots_active_scored, vp_score(500, true))

      add_variable_player(singles_locked_event,      vp_score(50, true))
      add_variable_player(splitpair_locked_event,    vp_score(150, true))
      add_variable_player(neighborpair_locked_event, vp_score(250, true))
      add_variable_player(row_locked_event,          vp_score(5000, false))
      add_variable_player(diagonal_locked_event,     vp_score(10000, false))
    end

    def add_event_players!
      add_event_player(mode_start_event, [set_initial_targets])
      add_event_player(@countdown.complete_event, [fail_event])
      add_event_player(@rotate.complete_event, [
        @left_column_rotation_group.rotate_left_event,
        @center_column_rotation_group.rotate_left_event,
        @right_column_rotation_group.rotate_left_event
      ])
    end

    def fail_event;                 "mode_fail_#{name}" end

    private

    def singles_locked_event;       "slots_singles_locked" end
    def row_locked_event;           "slots_row_locked" end
    def diagonal_locked_event;      "slots_diagonal_locked" end
    def splitpair_locked_event;     "slots_splitpair_locked" end
    def neighborpair_locked_event;  "slots_neighborpair_locked" end
    def set_initial_targets;        "slots_set_initial_targets" end
    def slots_active_scored;        "slots_active_scored" end
    def custom_hash; {} end
  end
end
