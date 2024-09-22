module TrogBuild
  class SlotsMode < Mode
    def custom_top_comment; 'Main slots mode' end

    def add_timers!
      @countdown = Timer.new('slots_countdown', 30, 0, '1000ms', true, true, false)
      add_timer(@countdown)
      @rotate = Timer.new('slots_rotate', 1, 0, '400ms', true, true, true)
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

      a = Shot.new('slots_a', slot_square, 's_drop_bank_left', true,   {'light' => 'gl_grid_1'})
      b = Shot.new('slots_b', slot_square, 's_drop_bank_center', true, {'light' => 'gl_grid_2'})
      c = Shot.new('slots_c', slot_square, 's_drop_bank_right', true,  {'light' => 'gl_grid_3'})
      d = Shot.new('slots_d', slot_square, 's_drop_bank_left', true,   {'light' => 'gl_grid_4'})
      e = Shot.new('slots_e', slot_square, 's_drop_bank_center', true, {'light' => 'gl_grid_5'})
      f = Shot.new('slots_f', slot_square, 's_drop_bank_right', true,  {'light' => 'gl_grid_6'})
      g = Shot.new('slots_g', slot_square, 's_drop_bank_left', true,   {'light' => 'gl_grid_7'})
      h = Shot.new('slots_h', slot_square, 's_drop_bank_center', true, {'light' => 'gl_grid_8'})
      i = Shot.new('slots_i', slot_square, 's_drop_bank_right', true,  {'light' => 'gl_grid_9'})
      [a, b, c, d, e, f, g, h, i].each do |s|
        add_shot(s)
        add_event_player(s.state_hit(1), [s.set_state_event(2), slots_active_scored])
      end

      @left_column_rotation_group = ShotGroup.new('left_column_rotation_group', [a, d, g].map(&:name))
      add_shot_group(@left_column_rotation_group)
      @center_column_rotation_group = ShotGroup.new('center_column_rotation_group', [b, e, h].map(&:name))
      add_shot_group(@center_column_rotation_group)
      @right_column_rotation_group = ShotGroup.new('right_column_rotation_group', [c, f, i].map(&:name))
      add_shot_group(@right_column_rotation_group)

      add_event_player(set_initial_targets, [g.set_state_event(1), h.set_state_event(1), i.set_state_event(1)])
    end

    def add_variable_players!
      add_variable_player(slots_active_scored, {'score' => 'current_player.playfield_multiplier * 1000'})
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

    def set_initial_targets
      'slots_set_initial_targets'
    end

    def slots_active_scored
      'slots_active_scored'
    end

    def fail_event
      "mode_fail_#{name}"
    end

    def custom_hash
      {}
    end
  end
end
