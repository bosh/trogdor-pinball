module TrogBuild
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
end
