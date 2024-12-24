module TrogBuild
  class DivertersConfig < ConfigFile
    DIVERTERS = {
        'div_right_controlled_ball_gate' => {
          'activation_coil' => 'c_gate_right',
          'type' => 'hold',
          'activation_time' => '3s',
          'enable_events' => 'enable_lift_right_cbg',
          'disable_events' => 'disable_lift_right_cbg, ball_ending',
          'activation_switches' => 's_left_orbit',
          'activate_events' => 'activate_right_cbg',
          'deactivate_events' => 'deactivate_right_cbg, disable_lift_right_cbg, ball_ending'
        },
        'div_right_controlled_ball_gate_alternative_profile' => {
          'activation_coil' => 'c_gate_right',
          'type' => 'hold',
          'activation_time' => '5s',
          'enable_events' => 'enable_lift_right_cbg_alt',
          'disable_events' => 'disable_lift_right_cbg_alt, ball_ending',
          'activation_switches' => 's_left_orbit, s_start', #Allow start as well for user control
          'activate_events' => 'activate_right_cbg_alt',
          'deactivate_events' => 'deactivate_right_cbg_alt, disable_lift_right_cbg_alt, ball_ending'
        },
        'div_left_controlled_ball_gate' => {
          'activation_coil' => 'c_gate_left',
          'type' => 'hold',
          'activation_time' => '3s',
          'enable_events' => 'enable_lift_left_cbg',
          'disable_events' => 'disable_lift_left_cbg, ball_ending',
          'activation_switches' => 's_right_orbit',
          'activate_events' => 'activate_left_cbg',
          'deactivate_events' => 'deactivate_left_cbg'
        },
        'div_saver_post' => {
          'activation_coil' => 'c_saver_post',
          'type' => 'hold',
          'activation_time' => '10s',
          'enable_events' => 'enable_saver_post',
          'disable_events' => 'disable_saver_post, ball_ending',
          'activate_events' => 'activate_saver_post',
          'deactivate_events' => 'deactivate_saver_post, disable_saver_post, ball_ending'
        }
      }

    def to_hash
      diverter_definitions = {}
      DIVERTERS.each { |name, definition| add_diverter_combinations(diverter_definitions, name, definition) }
      {'diverters' => diverter_definitions}
    end

    private

    def add_diverter_combinations(collection, name, definition)
      if collection[name]
        puts "Duplicate diverter definition detected - #{name}"
        exit(1)
      end
      collection[name] = definition
    end
  end
end
