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
      @sequence_shots.each { |ss_name| add_flasher_player_hook(hooks, ss_name) }
      {'flasher_player' => hooks}
    end

    def add_flasher_player_hook(collection, ss_name)
      hook_name = hit_event_name(ss_name)
      if collection[hook_name]
        puts "Duplicate flasher hook detected - #{hook_name}"
        exit(1)
      end

      collection[hook_name] = {
        light_name(ss_name) => {
          'ms' => '400ms',
          'color' => 'purple'
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
