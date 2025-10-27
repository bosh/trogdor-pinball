module TrogBuild
  class SlotsMode < Mode
    def custom_top_comment; 'Main slots mode' end
    def slow_tick;'650ms' end
    def medium_tick;'500ms' end
    def fast_tick;'375ms' end

    # The shows are here for convenience, and not really used in the slots mode behaviors
    def add_shows!
      slot_grid_stop_show = Show.new('slots_stop', 'Should allow falling through to attract base show')
      slot_grid_stop_show.add_step('800ms', {grid_lights: 'stop'})
      add_show(slot_grid_stop_show)

      spiral_in_show = Show.new('slots_spiral_in', 'Wakka wakka')
      [1,2,3,6,9,8,7,4,5,nil].each do |i|
        step_lights = {grid_lights: 'off'}
        step_lights["gl_grid_#{i}"] = 'red' if i
        spiral_in_show.add_step('100ms', step_lights)
      end
      add_show(spiral_in_show)

      spiral_out_show = Show.new('slots_spiral_out', 'akkaW akkaW')
      [5,4,7,8,9,6,3,2,1,nil].each do |i|
        step_lights = {grid_lights: 'off'}
        step_lights["gl_grid_#{i}"] = 'purple' if i
        spiral_out_show.add_step('100ms', step_lights)
      end
      add_show(spiral_out_show)

      out_in_in_out_show = Show.new('slots_out_in_in_out_show', 'Some flashing')
      [:out, :in, :in, :out].each do |type|
        if type == :out
          out_in_in_out_show.add_step('200ms', {grid_lights: 'red', gl_grid_5: 'off'})
        elsif type == :in
          out_in_in_out_show.add_step('200ms', {grid_lights: 'off', gl_grid_5: 'red'})
        else
          out_in_in_out_show.add_step('100ms', {grid_lights: 'off'})
        end
      end
      add_show(out_in_in_out_show)
    end

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
      @diag_1 = [a, e, i].freeze
      @diag_2 = [g, e, c].freeze
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
        add_event_player("slot_row_#{num}_group_locked_complete", [row_locked_event, "slots_confirm_row_#{num}"])
        # Rest of row locked complete handling is done via complex generated completion handlers
        sg
      end

      # Both diagonals report success and stop rotation
      @diagonal_groups = [@diag_1, @diag_2].map.with_index do |diag_group, i|
        num = i + 1
        sg = ShotGroup.new("slot_diagonal_#{num}_group", diag_group, false)
        add_shot_group(sg)

        add_event_player("slot_diagonal_#{num}_group_locked_complete", [
          @countdown.restart_event,
          @rotate.stop_event,
          diagonal_locked_event,
          'slots_celebrate_diagonal',
          clear_all_targets,
          @rotate.restart_event,
          slots_target_bank_full_reset,
          "slots_set_active_diagonal_#{num}|500ms"
        ])

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

        add_event_player("slot_neighborpair_#{num}_group_locked_complete", [
          @countdown.stop_event,
          neighborpair_locked_event,
          'slots_celebrate_pair',
          slots_target_bank_full_reset,
          "#{controller_stop_event}|500ms"
        ])
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
        add_event_player("slot_splitpair_#{num}_group_locked_complete", [
          @countdown.stop_event,
          splitpair_locked_event,
          'slots_celebrate_split_pair',
          # split pair does not warrant a reset on exit
          "#{controller_stop_event}|500ms"
        ])
        sg
      end

      # Single report locked completion and stop rotation
      @singles_groups = [[a,h,f], [d,h,c], [d,b,i], [g,b,f]].map.with_index do |single_group, i|
        num = i + 1
        sg = ShotGroup.new("slot_singles_#{num}_group", single_group, false)
        add_shot_group(sg)
        add_event_player("slot_singles_#{num}_group_locked_complete", [
          @countdown.stop_event,
          singles_locked_event,
          'slots_celebrate_single',
          # single does not warrant a reset on exit
          "#{controller_stop_event}|500ms"
        ])
        sg
      end

      generate_refresh_interval_hooks(grid_shots)
    end

    def add_variable_players!
      # Every first slot hit should give some points
      add_variable_player(slots_active_scored, vp_score(50, true))

      # Every singles and pairs give small points with multiplier
      add_variable_player(singles_locked_event,      vp_score(100, true))
      add_variable_player(splitpair_locked_event,    vp_score(150, true))
      add_variable_player(neighborpair_locked_event, vp_score(200, true))
      # Row and diagonal locking gives big points with no multiplier
      add_variable_player(row_locked_event,          vp_score(5000, false))
      add_variable_player(diagonal_locked_event,     vp_score(10000, false))
    end

    def add_event_players!
      add_event_player(mode_start_event, [ensure_initial_targets, slots_target_bank_full_reset, refresh_rotation_event])
      add_event_player(@countdown.complete_event, [controller_stop_event])

      add_event_player(@rotate.complete_event, [
        @left_column_rotation_group.rotate_left_event,
        @center_column_rotation_group.rotate_left_event,
        @right_column_rotation_group.rotate_left_event
      ])

      generate_initial_state_setup
    end

    private

    def controller_stop_event;      "slots_manager_stop" end # Per slots controller state machine
    def slots_target_bank_full_reset; "slots_target_bank_full_reset" end # Per config in future.yaml
    def refresh_rotation_event;     "slots_refresh_rotation" end
    def singles_locked_event;       "slots_singles_locked" end
    def row_locked_event;           "slots_row_locked" end
    def diagonal_locked_event;      "slots_diagonal_locked" end
    def splitpair_locked_event;     "slots_splitpair_locked" end
    def neighborpair_locked_event;  "slots_neighborpair_locked" end
    def ensure_initial_targets;     "slots_ensure_initial_targets" end
    def slots_active_scored;        "slots_active_scored" end
    def clear_all_targets;          "clear_all_targets" end
    def custom_hash; {} end

    def generate_initial_state_setup
      # Simple mass setting management
      add_event_player('slots_unset_row_1',           @row_1.map {|s| s.set_state_event(0) })
      add_event_player('slots_unset_row_2',           @row_2.map {|s| s.set_state_event(0) })
      add_event_player('slots_unset_row_3',           @row_3.map {|s| s.set_state_event(0) })

      add_event_player('slots_set_active_row_1',      @row_1.map {|s| s.set_state_event(1) })
      add_event_player('slots_set_active_row_2',      @row_2.map {|s| s.set_state_event(1) })
      add_event_player('slots_set_active_row_3',      @row_3.map {|s| s.set_state_event(1) })
      add_event_player('slots_set_active_diagonal_1', @diag_1.map {|s| s.set_state_event(1) })
      add_event_player('slots_set_active_diagonal_2', @diag_2.map {|s| s.set_state_event(1) })

      add_event_player('slots_confirm_row_1',         @row_1.map {|s| s.set_state_event(3) })
      add_event_player('slots_confirm_row_2',         @row_2.map {|s| s.set_state_event(3) })
      add_event_player('slots_confirm_row_3',         @row_3.map {|s| s.set_state_event(3) })

      # The actual reset on start
      add_event_player(clear_all_targets, ['slots_unset_row_1', 'slots_unset_row_2', 'slots_unset_row_3'])
      add_event_player(ensure_initial_targets, [clear_all_targets, 'slots_set_active_row_3', slots_target_bank_full_reset])

      add_row_completion_handler(@row_groups[2], [@row_1, @row_2])
      add_row_completion_handler(@row_groups[1], [@row_1, @row_3])
      add_row_completion_handler(@row_groups[0], [@row_2, @row_3])
    end

    def add_row_completion_handler(row_shot_group, other_rows_shots)
      # These handlers decide which row should be marked as the target for the next round.
      # This could maybe be replaced with a player var for each row being complete.
      # Right now we just check shot[0] in each row, because a finished row should be the same across [0-2]
      # --Adding row down tracking to a player var also allows speed checking to defer to that

      # Completing with others both incomplete
      add_event_player("#{row_shot_group.name}_locked_complete{device.shots.#{other_rows_shots[0][0].name}.state < 2 and device.shots.#{other_rows_shots[1][0].name}.state < 2}",
        [@rotate.stop_event] + #pause for processing
        other_rows_shots[1].map {|s| s.set_state_event(1) } + #mark row 2 active
        other_rows_shots[0].map {|s| s.set_state_event(0) } + #mark row 1 inactive
        [@rotate.restart_event, slots_target_bank_full_reset]
      )

      # Completing with next complete, last incomplete
      add_event_player("#{row_shot_group.name}_locked_complete{device.shots.#{other_rows_shots[0][0].name}.state < 2 and device.shots.#{other_rows_shots[1][0].name}.state >= 2}",
        [@rotate.stop_event] + #pause because no reason to rotate on last row
        other_rows_shots[0].map {|s| s.set_state_event(1) } +
        [slots_target_bank_full_reset]
      )
      # Completing with next incomplete, last complete
      add_event_player("#{row_shot_group.name}_locked_complete{device.shots.#{other_rows_shots[0][0].name}.state >= 2 and device.shots.#{other_rows_shots[1][0].name}.state < 2}",
        [@rotate.stop_event] + #pause because no reason to rotate on last row
        other_rows_shots[1].map {|s| s.set_state_event(1) } +
        [slots_target_bank_full_reset]
      )

      # Completing with both others complete
      add_event_player("#{row_shot_group.name}_locked_complete{device.shots.#{other_rows_shots[0][0].name}.state >= 2 and device.shots.#{other_rows_shots[1][0].name}.state >= 2}", [
        @rotate.stop_event,
        @countdown.stop_event,
        'slots_party_time',
        "#{slots_target_bank_full_reset}|1400ms",
        "#{controller_stop_event}|1500ms",
        # TODO this need a better reward -- multiball and/or achievement?
      ])
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
