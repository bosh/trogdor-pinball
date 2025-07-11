module TrogBuild
  class DivertersConfig < ConfigFile
    def to_hash
      diverter_definitions = {}
      @diverters.each { |name, definition| add_diverter_combinations(diverter_definitions, name, definition) }
      {'diverters' => diverter_definitions}
    end

    private

    def after_initialize
      @diverters = {}
      add_diverter!('right_controlled_ball_gate', 'c_gate_right', '3s', 's_left_orbit_outer')
      add_diverter!('right_controlled_ball_gate_alternative_profile', 'c_gate_right', '6s', 's_left_orbit_outer')
      add_diverter!('left_controlled_ball_gate', 'c_gate_left', '3s', 's_right_orbit_outer')
      add_diverter!('saver_post', 'c_saver_post', 'settings.saver_post_time') #setting only works with fork that handles activation_time eval
      add_diverter!('right_outlane_post', 'c_right_outlane_post', '3s', 's_right_outer_lane')
      add_diverter!('right_outlane_post_ramp_save', 'c_right_outlane_post', '8000ms', nil, {active: 'bd_plunger', inactive: 'bd_trough'})
    end

    def add_diverter!(diverter_name, activation_coil_name, activation_time, activation_switches = nil, targets={})
      config = diverter_default_configuration(diverter_name, activation_coil_name, activation_time)
      config['activation_switches'] = activation_switches if activation_switches
      config['targets_when_active'] = targets[:active] if targets && targets[:active]
      config['targets_when_inactive'] = targets[:inactive] if targets && targets[:inactive]
      @diverters["div_#{diverter_name}"] = config
    end

    def diverter_default_configuration(diverter_name, activation_coil_name, activation_time)
      {
        'activation_coil' => activation_coil_name,
        'type' => 'hold',
        'activation_time' => activation_time,
        'enable_events' => "enable_#{diverter_name}",
        'disable_events' => "disable_#{diverter_name},ball_ending",
        'activate_events' => "activate_#{diverter_name}",
        'deactivate_events' => "deactivate_#{diverter_name},disable_#{diverter_name},ball_ending"
      }
    end

    def add_diverter_combinations(collection, name, definition)
      if collection[name]
        puts "Duplicate diverter definition detected - #{name}"
        exit(1)
      end
      collection[name] = definition
    end
  end
end
