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
      {}
    end

    def base_hash
      out = {'mode' => {}}
      mode = out['mode']

      mode['priority'] = @priority
      out['mode']['start_events'] = @start_events
      out
    end

    def add_shows!
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

      @shows << @example_show
    end

    def to_hash
      out = base_hash

      out[Mode::SHOW_PLAYER] = {
        "mode_#{name}_started" => {
          @example_show.name => {
            'action' => 'play'
          }
        }
      }

      out
    end

  end
end
