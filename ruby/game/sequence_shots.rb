module TrogBuild
  class SequenceShotsConfig < ConfigFile
    attr_reader :sequence_shots

    def after_initialize
      @sequence_shots = %w(
        ss_elbow_downwards
        ss_elbow_upwards
        ss_horseshoe_clockwise
        ss_horseshoe_widdershins
        ss_left_orbit_open
        ss_left_orbit_closed
        ss_right_orbit_open
        ss_right_orbit_closed
        ss_right_ramp_summit
        ss_right_ramp_travel
        ss_right_outlane_escape
        ss_s_ramp_summit
        ss_s_ramp_travel
        ss_subway_travel
      )
    end

    def to_hash
      hooks = {}
      @sequence_shots.each { |ss_name| add_show_player_hook(hooks, ss_name) }
      {'show_player' => hooks}
    end

    def add_show_player_hook(collection, ss_name)
      hook_name = hit_event_name(ss_name)
      if collection[hook_name]
        puts "Duplicate show hook detected - #{hook_name}"
        exit(1)
      end

      collection[hook_name] = {
        'one_hundred_ms_flash' => {
          'loops' => 5,
          'key' => "#{ss_name}_hook",
          'show_tokens' => {
            'light' => light_name(ss_name),
            'color' => 'purple'
          }
        }
      }
    end

    def hit_event_name(ss_name)
      "#{ss_name}_hit"
    end

    def light_name(ss_name)
      "gl_#{ss_name}"
    end
  end
end
