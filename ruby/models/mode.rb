module TrogBuild
  class Mode
    SHOW_PLAYER = 'show_player'
    TIMERS = 'timers'
    EVENT_PLAYER = 'event_player'
    VARIABLE_PLAYER = 'variable_player'
    SHOTS = 'shots'
    SHOT_PROFILES = 'shot_profiles'
    SHOT_GROUPS = 'shot_groups'
    attr_reader :name, :priority, :shows

    def initialize(name, priority)
      @name = name
      @priority = priority
      @shot_profiles = {}
      @shot_groups = {}
      @shots = {}
      @shows = []
      @timers = {}
      @event_player = {}
      @variable_player = {}
      @top_comment = custom_top_comment
      @start_events = generate_start_events
      add_shots!
      add_timers!
      add_shows!
      add_event_players!
    end

    def to_hash
      out = base_hash

      out[Mode::SHOW_PLAYER] = show_player if show_player
      out[Mode::TIMERS] = @timers unless @timers.empty?
      out[Mode::EVENT_PLAYER] = @event_player unless @event_player.empty?
      out[Mode::VARIABLE_PLAYER] = @variable_player unless @variable_player.empty?
      out[Mode::SHOT_PROFILES] = @shot_profiles unless @shot_profiles.empty?
      out[Mode::SHOTS] = @shots unless @shots.empty?
      out[Mode::SHOT_GROUPS] = @shot_groups unless @shot_groups.empty?
      out.merge!(custom_hash)

      out
    end

    def base_hash
      {
        'mode' => {
          'priority' => @priority,
          'start_events' => @start_events
        }
      }
    end

    def add_shots!; end
    def add_shot(shot)
      @shots[shot.name] = shot.to_hash
    end
    def add_shot_profile(shot_profile)
      @shot_profiles[shot_profile.name] = shot_profile.to_hash
    end
    def add_shot_group(shot_group)
      @shot_groups[shot_group.name] = shot_group.to_hash
    end

    def add_shows!; end
    def add_show(show)
      @shows << show
    end

    def add_timers!; end
    def add_timer(timer)
      @timers[timer.name] = timer.to_hash
    end

    def add_event_players!; end
    def add_event_player(event_name, triggered_events)
      @event_player[event_name] = triggered_events
    end

    def add_variable_players!; end
    def add_variable_player(event_name, variable_hash)
      @variable_player[event_name] = variable_hash
    end

    def show_player
    end

    def custom_hash
      {}
    end

    def custom_top_comment
      'This is a generated file!'
    end

    def generate_start_events
      'start_mode_' + name
    end

    def mode_start_event
      "mode_#{name}_started"
    end

    def top_comment_text
      '# ' + @top_comment + "\n\n"
    end
  end

  class ExampleMode < Mode
    def custom_top_comment; 'This is the example mode!' end
    def generate_start_events; 'ball_started' end

    def add_shows!
      @example_show = Show.new('example_show_a', 'This is the example show!')
      @example_show.add_step('334ms', {vlight_for_generated_example_mode: 'purple'})
      @example_show.add_step('666ms', {vlight_for_generated_example_mode: 'red'})
      add_show(@example_show)

      s = '240ms'
      @blue_orb_ring_show = Show.new('blue_orb_g_ring_a', 'Generated ring show on generated ring')
      16.times {|i| @blue_orb_ring_show.add_step(s, blue_orb_step(i, 'gl_ring_a'))}
      16.times {|i| @blue_orb_ring_show.add_step(s, blue_orb_step(16-i, 'gl_ring_a'))}

      add_show(@blue_orb_ring_show)

      @speedup_spin_show = Show.new('speedup_spin_show', 'Single light ring spin with increasing speed')
      (8*SPEEDUP_SPEEDS.length).times {|i| @speedup_spin_show.add_step(speedup_spin_speed(i), speedup_spin_step(i))}

      add_show(@speedup_spin_show)
    end

    def show_player
      {
        "mode_#{name}_started" => {
          @example_show.name => {'action' => 'play' },
          # @blue_orb_ring_show.name => {'action' => 'play' },
          @speedup_spin_show.name => {'action' => 'play', 'show_tokens' => {'color' => 'teal', 'ring_prefix' => 'gl_ring_a'}}
        }
      }
    end

    private

    SPEEDUP_SPEEDS = [150, 100, 50, 25, 15, 10, 25, 100].map{|i| "#{i}ms"}
    def speedup_spin_speed(i)
      idx = (i/8.0).floor
      SPEEDUP_SPEEDS[idx]
    end

    def speedup_spin_step(i)
      on_light = (i%8)+1
      off_light = ((i-1)%8)+1
      {
        "(ring_prefix)_#{on_light}" => '(color)',
        "(ring_prefix)_#{off_light}" => 'off'
      }
    end


    def blue_orb_step(i, ring_name)
      out = {"lights_#{ring_name}" => 'off'}
      (1..8).each do |light_number|
        out["#{ring_name}_#{light_number}"] = blueness(i, light_number)
      end
      out
    end

    LIGHT_SCORE_MAP = {
              7 => 1, 6 => 1,
      8 => 2,                 5 => 2,
      1 => 3,                 4 => 3,
              2 => 4, 3 => 4
    }

    def blueness(step_number, light_number)
      light_score = LIGHT_SCORE_MAP[light_number]
      out_score = (light_score * (step_number/6.0)).floor
      blue(out_score)
    end

    BLUES = ['000011', '000022', '111133', '111144', '111155', '222266', '222277', '222288', '333399', '3333aa', '3333bb', '4444cc', '4444dd', '5555ee', '6666ff']
    def blue(score)
      BLUES[score]
    end
  end

  class AchievementMode < Mode
    def custom_top_comment; 'Majesty Achievements!' end
    def generate_start_events; 'ball_started' end

    def add_shows!
      @rainbow_show = Show.new('majesty_rainbow_loop', '6 majesty lights spin twice')
      6.times do |i|
        @rainbow_show.add_step('150ms', rainbow_step(i))
      end

      add_show(@rainbow_show)
    end

    def rainbow_step(i)
      colors = %w(green yellow orange red purple blue)
      (1..6).inject({}) do |memo, light_number|
        memo["l_majesty_#{light_number}"] = colors[(light_number+i) % 6]
        memo
      end
    end

    def show_player
      {
        "celebrate_achievement" => {
          @rainbow_show.name => {
            'action' => 'play',
            'loops' => 2
          }
        }
      }
    end

    def custom_hash
      {
        'achievements' => {
          'burnination' => achievement_hash('burnination', 1, 'mode_start_pops_burnination', 'pops_burnination'),
          'a2' => achievement_hash('a2', 2, nil, 'a2'),
          'a3' => achievement_hash('a3', 3, nil, 'a3'),
          'a4' => achievement_hash('a4', 4, nil, 'a4'),
          'a5' => achievement_hash('a5', 5, nil, 'a5'),
          'a6' => achievement_hash('a6', 6, nil, 'a6')
        }
      }
    end

    def achievement_hash(name, majesty_number, start_events, event_template_name)
      {
        'start_enabled' => true,
        'show_tokens' => {
          'light' => "l_majesty_#{majesty_number}"
        },
        'show_when_started' => 'flash',
        'show_when_completed' => 'on',
        'restart_after_stop_possible' => true,
        'events_when_completed' => 'celebrate_achievement',
        'start_events' => start_events || "start_achievement_#{name}",
        'stop_events' => "mode_fail_#{event_template_name}",
        'complete_events' => "mode_complete_#{event_template_name}"
      }
    end
  end

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
