module TrogBuild
  class SlotsMode < Mode
    def custom_top_comment; 'Main slots mode' end
    def slow_tick;'650ms' end
    def medium_tick;'500ms' end
    def fast_tick;'375ms' end

    def add_timers!
      @countdown = Timer.new('slots_countdown', 6, 0, '5000ms', true, true, false) #30s with a 5s checkin to reduce spam
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
      slot_square.add_state('confirmed', 'on_color', {'color' => 'green'})
      slot_square.set_state_names_to_not_rotate('locked, confirmed')

      add_shot_profile(slot_square)

      center = 's_drop_bank_center'
      left = 's_drop_bank_left'
      right = 's_drop_bank_right'
      a = @a = Shot.new('slots_a', slot_square, left,   true, {'light' => 'gl_grid_1'})
      b = @b = Shot.new('slots_b', slot_square, center, true, {'light' => 'gl_grid_2'})
      c = @c = Shot.new('slots_c', slot_square, right,  true, {'light' => 'gl_grid_3'})
      d = @d = Shot.new('slots_d', slot_square, left,   true, {'light' => 'gl_grid_4'})
      e = @e = Shot.new('slots_e', slot_square, center, true, {'light' => 'gl_grid_5'})
      f = @f = Shot.new('slots_f', slot_square, right,  true, {'light' => 'gl_grid_6'})
      g = @g = Shot.new('slots_g', slot_square, left,   true, {'light' => 'gl_grid_7'})
      h = @h = Shot.new('slots_h', slot_square, center, true, {'light' => 'gl_grid_8'})
      i = @i = Shot.new('slots_i', slot_square, right,  true, {'light' => 'gl_grid_9'})
      @row_1 = [a, b, c].freeze
      @row_2 = [d, e, f].freeze
      @row_3 = [g, h, i].freeze
      grid_shots = [a, b, c, d, e, f, g, h, i].freeze

      grid_shots.each do |s|
        add_shot(s)
        add_event_player(s.state_hit(1), [s.set_state_event(2), slots_active_scored, refresh_rotation_event])
      end

      @left_column_rotation_group = ShotGroup.new('left_column_rotation_group', [a, d, g], true)
      add_shot_group(@left_column_rotation_group)
      @center_column_rotation_group = ShotGroup.new('center_column_rotation_group', [b, e, h], true)
      add_shot_group(@center_column_rotation_group)
      @right_column_rotation_group = ShotGroup.new('right_column_rotation_group', [c, f, i], true)
      add_shot_group(@right_column_rotation_group)

      # Each row gets a shot group that upgrades a locked set to a confirmed set
      @row_groups = [@row_1, @row_2, @row_3].map.with_index do |line_group, i|
        num = i + 1
        sg = ShotGroup.new("slot_row_#{num}_group", line_group, false)
        add_shot_group(sg)
        add_event_player("slot_row_#{num}_group_locked_complete", [row_locked_event, "slots_confirm_row_#{num}", @rotate.stop_event])
        sg
      end

      # Both diagonals report success and stop rotation
      @diagonal_groups = [[a,e,i], [g,e,c]].map.with_index do |diag_group, i|
        num = i + 1
        sg = ShotGroup.new("slot_diagonal_#{num}_group", diag_group, false)
        add_shot_group(sg)
        add_event_player("slot_diagonal_#{num}_group_locked_complete", [diagonal_locked_event, @rotate.stop_event])
        sg
      end

      # Neighbor pairs report locked completion and stop rotation
      @neighbor_pair_groups = [
        [a,b,f], [a,e,f], [a,b,i], [a,h,i],
        [d,b,c], [d,e,c], [d,e,i], [d,h,i],
        [g,b,c], [g,h,c], [g,e,f], [g,h,f]
      ].map.with_index do |neighbor_group, i|
        num = i + 1
        sg = ShotGroup.new("slot_neighborpair_#{num}_group", neighbor_group, false)
        add_shot_group(sg)
        add_event_player("slot_neighborpair_#{num}_group_locked_complete", [neighborpair_locked_event, @rotate.stop_event])
        sg
      end

      # Split pairs report locked completion and stop rotation
      @split_pair_groups = [
        [a,e,c], [a,h,c],
        [d,b,f], [d,h,f],
        [g,b,i], [g,e,i]
      ].map.with_index do |split_group, i|
        num = i + 1
        sg = ShotGroup.new("slot_splitpair_#{num}_group", split_group, false)
        add_shot_group(sg)
        add_event_player("slot_splitpair_#{num}_group_locked_complete", [splitpair_locked_event, @rotate.stop_event])
        sg
      end

      # Single report locked completion and stop rotation
      @singles_groups = [[a,h,f], [d,h,c], [d,b,i], [g,b,f]].map.with_index do |single_group, i|
        num = i + 1
        sg = ShotGroup.new("slot_singles_#{num}_group", single_group, false)
        add_shot_group(sg)
        add_event_player("slot_singles_#{num}_group_locked_complete", [singles_locked_event, @rotate.stop_event])
        sg
      end

      generate_refresh_interval_hooks(grid_shots)
    end

    def add_variable_players!
      # Every first slot hit should give some points
      add_variable_player(slots_active_scored, vp_score(25, true))

      # Every singles and pairs give small points with multiplier
      add_variable_player(singles_locked_event,      vp_score(75, true))
      add_variable_player(splitpair_locked_event,    vp_score(125, true))
      add_variable_player(neighborpair_locked_event, vp_score(200, true))
      # Row and diagonal locking gives big points with no multiplier
      add_variable_player(row_locked_event,          vp_score(5000, false))
      add_variable_player(diagonal_locked_event,     vp_score(10000, false))
    end

    def add_event_players!
      add_event_player(mode_start_event, [ensure_initial_targets, refresh_rotation_event])
      add_event_player(@countdown.complete_event, [fail_event])
      add_event_player(fail_event, [@stop_events])

      add_event_player(@rotate.complete_event, [
        @left_column_rotation_group.rotate_left_event,
        @center_column_rotation_group.rotate_left_event,
        @right_column_rotation_group.rotate_left_event
      ])

      generate_initial_state_setup
    end

    def fail_event;                 "mode_fail_#{name}" end

    private

    def refresh_rotation_event;     "slots_refresh_rotation" end
    def singles_locked_event;       "slots_singles_locked" end
    def row_locked_event;           "slots_row_locked" end
    def diagonal_locked_event;      "slots_diagonal_locked" end
    def splitpair_locked_event;     "slots_splitpair_locked" end
    def neighborpair_locked_event;  "slots_neighborpair_locked" end
    def ensure_initial_targets;     "slots_ensure_initial_targets" end
    def slots_active_scored;        "slots_active_scored" end
    def custom_hash; {} end

    def generate_initial_state_setup
      # Simple mass setting management
      add_event_player('slots_unset_row_1', @row_1.map {|s| s.set_state_event(0) })
      add_event_player('slots_unset_row_2', @row_2.map {|s| s.set_state_event(0) })
      add_event_player('slots_unset_row_3', @row_3.map {|s| s.set_state_event(0) })
      add_event_player('slots_set_active_row_1', @row_1.map {|s| s.set_state_event(1) })
      add_event_player('slots_set_active_row_2', @row_2.map {|s| s.set_state_event(1) })
      add_event_player('slots_set_active_row_3', @row_3.map {|s| s.set_state_event(1) })
      add_event_player('slots_confirm_row_1', @row_1.map {|s| s.set_state_event(3) })
      add_event_player('slots_confirm_row_2', @row_2.map {|s| s.set_state_event(3) })
      add_event_player('slots_confirm_row_3', @row_3.map {|s| s.set_state_event(3) })

      # The actual reset on start
      add_event_player(ensure_initial_targets, ['slots_unset_row_1', 'slots_unset_row_2', 'slots_set_active_row_3'])

      add_row_completion_handler(@row_groups[2], [@row_1, @row_2])
      add_row_completion_handler(@row_groups[1], [@row_1, @row_3])
      add_row_completion_handler(@row_groups[0], [@row_2, @row_3])
    end

    def add_row_completion_handler(row_shot_group, other_rows_shots)
      # Completing with others both incomplete
      add_event_player("#{row_shot_group.name}_locked_complete{device.shots.#{other_rows_shots[0][0].name}.state < 2 and device.shots.#{other_rows_shots[1][0].name}.state < 2}",
        [@rotate.stop_event] + #pause for processing
        other_rows_shots[1].map {|s| s.set_state_event(1) } + #mark row 2 active
        other_rows_shots[0].map {|s| s.set_state_event(0) } + #mark row 1 inactive
        [@rotate.restart_event]
      )

      # Completing with one complete, other incomplete
      add_event_player("#{row_shot_group.name}_locked_complete{device.shots.#{other_rows_shots[0][0].name}.state < 2 and device.shots.#{other_rows_shots[1][0].name}.state >= 2}",
        [@rotate.stop_event] + #pause because no reason to rotate on last row
        other_rows_shots[0].map {|s| s.set_state_event(1) }
      )
      # Completing with one complete, other incomplete
      add_event_player("#{row_shot_group.name}_locked_complete{device.shots.#{other_rows_shots[0][0].name}.state >= 2 and device.shots.#{other_rows_shots[1][0].name}.state < 2}",
        [@rotate.stop_event] + #pause because no reason to rotate on last row
        other_rows_shots[1].map {|s| s.set_state_event(1) }
      )

      # Completing with both others complete
      add_event_player("#{row_shot_group.name}_locked_complete{device.shots.#{other_rows_shots[0][0].name}.state >= 2 and device.shots.#{other_rows_shots[1][0].name}.state >= 2}",
        [@rotate.stop_event, @countdown.stop_event, 'party_time']
      )
    end

    def generate_refresh_interval_hooks(grid_shots)
      # 0 = set tick slow
      all_shots_unlocked = grid_shots.map {|s| "device.shots.#{s.name}.state != 2"}.join(' and ')
      add_event_player("#{refresh_rotation_event}{#{all_shots_unlocked}}", @rotate.set_tick_interval_event('slow'))

      # 1 = set tick medium
      grid_shots.each do |shot|
        other_shots = grid_shots - [shot]

        other_shots_unlocked = other_shots.map {|s| "device.shots.#{s.name}.state != 2"}.join(' and ')
        refresh_hook_name = "#{refresh_rotation_event}{device.shots.#{shot.name}.state == 2 and #{other_shots_unlocked}}"
        add_event_player(refresh_hook_name, @rotate.set_tick_interval_event('medium'))
      end

      # 2 = set tick fast
      grid_shot_pairs = generate_pairs(grid_shots) #Overkill since there shouldnt be two locked in any column anyway
      grid_shot_pairs.each do |shots|
        other_shots = grid_shots - shots

        other_shots_unlocked = other_shots.map {|s| "device.shots.#{s.name}.state != 2"}.join(' and ')
        refresh_hook_name = "#{refresh_rotation_event}{device.shots.#{shots[0].name}.state == 2 and device.shots.#{shots[1].name}.state == 2 and #{other_shots_unlocked}}"
        add_event_player(refresh_hook_name, @rotate.set_tick_interval_event('fast'))
      end
    end

    def generate_pairs(list)
      out = []
      count = list.size
      (0...count).each do |i|
        ((i+1)...count).each do |j|
          out << [list[i], list[j]]
        end
      end

      out
    end

  end
end
