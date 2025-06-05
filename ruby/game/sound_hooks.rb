module TrogBuild
  class SoundHooksConfig < ConfigFile
    # Pools are sound resources from the mpf config side,
    # but are actually godot-specific files that just point to real
    # sound resources (which may have their own direct resource declaration or not)
    # Sound resources are actual files that want to be played directly
    # mpf doesnt care about file extension, so we leave that off

    DEFAULT_BUS = 'effects'

    EFFECTS_HOOKS = %w(
      pop_pool
      burnination_pop_hit_pool
      multiplier_added_pool
      bonus_multiplier_added_pool
      rollover_lit_pool
      rollover_unlit_pool
      sling_pool
      sling_combo_pool
      not_enough_credits_pool
      cash
      at_max_players
      burnination_pop_up_1
      burnination_pop_up_2
      burnination_pop_up_3
      burnination_pop_up_4
      burnination_pop_up_5
      burnination_rollover_on_target
      cancel
      cant_incdec_more
      click_bad
      click_good
      decrement
      high_voltage_disabled
      high_voltage_enabled
      increment
    )

    MUSIC_HOOKS = %w(
      attract_music_pool
      theme_70s
      theme_chiptune
      theme_heavy_metal
      theme_instrumental_heavy
      theme_instrumental_steel
      theme_motown
      theme_music_box
      theme_main
      burnination_mode_song
      burnination_background
      extra_ball_earned
      game_reset
      mpf
      videlectrix
      bootup
      status_menu
      tilted
      music_stop
    )
    MUSIC_HOOKS_TO_STOP = %w(
      burnination_background
      burnination_mode_song
    )

    COMPLETION_EVENTS = {
      'ball_end_zero' => 'dj_end_quip_complete',
      'ball_end_poor_pool' => 'dj_end_quip_complete',
      'ball_end_average_pool' => 'dj_end_quip_complete',
      'ball_end_good_pool' => 'dj_end_quip_complete',
      'ball_end_amazing' => 'dj_end_quip_complete',
      'theme_70s' => 'music_track_finished',
      'theme_chiptune' => 'music_track_finished',
      'theme_heavy_metal' => 'music_track_finished',
      'theme_instrumental_heavy' => 'music_track_finished',
      'theme_instrumental_steel' => 'music_track_finished',
      'theme_motown' => 'music_track_finished',
      'theme_music_box' => 'music_track_finished',
      'theme_main' => 'special_music_finished',
      'burnination_mode_song' => 'special_music_finished',
      'attract_music_pool' => 'music_track_finished'
    }

    VOICE_HOOKS = %w(
      ball_intros_pool
      ball_at_launcher
      game_start
      game_over

      ball_end_good_pool
      ball_end_average_pool
      ball_end_poor_pool
      tilt_warning_pool
      skill_shot_1_hit
      skill_shot_2_hit
      skill_shot_3_hit
      ball_end_amazing
      ball_end_zero
      ball_save_grace
      ball_save_sb
      ball_search_fail
      ball_search_start
      ball_search_success
      burnination_pop_completed
      credit_added
      new_high_score
      orbit_looped
      spinner_complete_high
    )

    def to_hash
      hooks = {}
      EFFECTS_HOOKS.each { |hook| add_sound_hook(hooks, hook, 'effects') }
      MUSIC_HOOKS.each { |hook| add_sound_hook(hooks, hook, 'music') }
      MUSIC_HOOKS_TO_STOP.each { |hook| add_stop_sound_hook(hooks, hook, 'music')}
      VOICE_HOOKS.each { |hook| add_sound_hook(hooks, hook, 'voice') }
      {'sound_player' => hooks}
    end

    def ducking(bus)
      {
        'bus' => bus,
        'attack' => 0,
        'attenuation' => 0,
        'release_point' => 0,
        'release' => '0s'
      }
    end

    def play_event_name(sound_name)
      'dj_' + sound_name
    end

    def stop_event_name(sound_name)
      'dj_stop_' + sound_name
    end

    def add_linux_sound_hook(collection, sound_name, bus, action = 'play')
      record = {sound_name => {'bus' => bus}}
      record[sound_name]['action'] = action if action != 'play'
      register_name = action == 'play' ? play_event_name(sound_name) : stop_event_name(sound_name)
      record[sound_name]['events_when_stopped'] = COMPLETION_EVENTS[sound_name] if COMPLETION_EVENTS[sound_name]
      if record == {sound_name => {'bus' => DEFAULT_BUS}} # if the record is inlineable with default bus
        collection[register_name] = sound_name
      else
        collection[register_name] = record
      end
    end

    # def add_windows_sound_hook(collection, sound_name, bus, action = 'play')
    #   record = {sound_name => {'bus' => bus, 'ducking' => ducking(bus)}}
    #   record[sound_name]['action'] = action if action != 'play'
    #   register_name = action == 'play' ? play_event_name(sound_name) : stop_event_name(sound_name)
    #   record[sound_name]['events_when_stopped'] = COMPLETION_EVENTS[sound_name] if COMPLETION_EVENTS[sound_name]
    #   collection[register_name] = record
    # end

    def add_sound_hook(collection, sound_name, bus='effects')
      if collection[play_event_name(sound_name)]
        puts "Duplicate sound hook detected - #{play_event_name(sound_name)}"
        exit(1)
      end
      # if $platform == PLATFORM_WINDOWS
      #   add_windows_sound_hook(collection, sound_name, bus)
      # else
        add_linux_sound_hook(collection, sound_name, bus)
      # end
    end

    def add_stop_sound_hook(collection, sound_name, bus='effects')
      if collection[stop_event_name(sound_name)]
        puts "Duplicate sound hook detected - #{stop_event_name(sound_name)}"
        exit(1)
      end
      # if $platform == PLATFORM_WINDOWS
      #   add_windows_sound_hook(collection, sound_name, bus, 'stop')
      # else
        add_linux_sound_hook(collection, sound_name, bus, 'stop')
      # end
    end
  end
end
