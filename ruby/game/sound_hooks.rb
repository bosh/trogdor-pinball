module TrogBuild
  class SoundHooksMode < Mode
    def custom_top_comment; 'Sound hooks because ducking is wonky on windows' end
    def generate_start_events; 'ball_started' end

    # Pools are sound resources from the mpf config side,
    # but are actually godot-specific files that just point to real
    # sound resources (which may have their own direct resource declaration or not)
    POOLS = %w(
      pop_pool
      burnination_pop_hit_pool
      burnination_pop_up_pool
      multiplier_added_pool
      rollover_lit_pool
      rollover_unlit_pool
      sling_pool
      sling_combo_pool
      ball_intros_pool
      not_enough_credits_pool
      ball_end_good_pool
      ball_end_average_pool
      ball_end_poor_pool
      tilt_warning_pool
    )

    # Sound resources are actual files that want to be played directly
    # mpf doesnt care about file extension, so we leave that off
    SOUND_RESOURCES = %w(
      cash
      theme_70s
      theme_chiptune
      theme_heavy_metal
      theme_instrumental_heavy
      theme_main
      at_max_players
      burnination_background
      burnination_mode_song
      burnination_rollover_on_target
      cancel
      cant_incdec_more
      click_bad
      click_good
      decrement
      high_voltage_disabled
      high_voltage_enabled
      increment
      ball_at_launcher
      bootup
      extra_ball_earned
      game_reset
      game_start
      mpf
      skill_shot_1_hit
      skill_shot_2_hit
      skill_shot_3_hit
      status_menu
      tilted
      videlectrix
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

    HOOKS = POOLS + SOUND_RESOURCES

    def custom_hash
      out = {'sound_player' => {}}
      sp = out['sound_player']
      HOOKS.each { |hook| add_sound_hook(sp, hook) }
      out
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

    def add_sound_hook(collection, sound_name, bus='effects')
      play_event_name = 'dj_' + sound_name
      if collection[play_event_name]
        puts "Duplicate sound hook detected - #{play_event_name}"
        exit(1)
      end
      collection[play_event_name] = {
        sound_name => {'ducking' => ducking(bus)}
      }
    end
  end
end
