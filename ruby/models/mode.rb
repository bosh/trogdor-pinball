module TrogBuild
  class Mode
    SHOW_PLAYER = 'show_player'
    attr_reader :name, :priority, :shows

    def initialize(name, priority)
      @name = name
      @priority = priority
      @shows = []
      @top_comment = custom_top_comment
      @start_events = generate_start_events
      add_shows!
    end

    def to_hash
      out = base_hash

      out[Mode::SHOW_PLAYER] = show_player if show_player
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

    def add_shows!
    end
    def add_show(show)
      @shows << show
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
      'start_generated_mode_' + name
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
    end

    def show_player
      {
        "mode_#{name}_started" => {
          @example_show.name => {'action' => 'play' },
          @blue_orb_ring_show.name => {'action' => 'play' }
        }
      }
    end

    private

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
end
