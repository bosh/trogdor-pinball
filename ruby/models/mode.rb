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
      @stop_events = generate_stop_events
      add_timers!
      add_shots!
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
          'start_events' => @start_events,
          'stop_events' => @stop_events
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
    def vp_score(value, use_pf_multiplier)
      if use_pf_multiplier
        {'score' => "#{value} * current_player.playfield_multiplier"}
      else
        {'score' => value}
      end
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
      'mode_start_' + name
    end

    def default_stop_events #Default command to stop, likely to be used outside of mode itself
      'mode_stop_' + name + ', ball_will_end'
    end
    def generate_stop_events #For overriding
      default_stop_events
    end

    def mode_start_event #not used to start the mode, used to hook onto started processing
      "mode_#{name}_started"
    end

    def top_comment_text
      '# ' + @top_comment + "\n\n"
    end
  end
end
