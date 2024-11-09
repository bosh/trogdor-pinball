module TrogBuild
  class SoundHooksMode < Mode
    def custom_top_comment; 'Sound hooks because ducking is wonky on windows' end
    def generate_start_events; 'ball_started' end

    def custom_hash
      out = {'sound_player' => {}}
      sp = out['sound_player']
      add_sound_hook(sp, 'cash')
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
