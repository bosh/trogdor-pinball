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
      '# ' + @top_comment + "\n# " + Time.now.to_s + "\n"
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
    end

    def show_player
      {
        "mode_#{name}_started" => {
          @example_show.name => {
            'action' => 'play'
          }
        }
      }
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
          'burnination' => achievement_hash('burnination', 1, "mode_pops_burnination_started", 'pops_burnination'),
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
        'stop_events' => "fail_#{event_template_name}",
        'complete_events' => "succeed_#{event_template_name}"
      }
    end
  end
end
