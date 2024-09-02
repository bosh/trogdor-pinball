module TrogBuild
  class Show
    attr_reader :name

    def initialize(name)
      @name = name
      @top_comment = custom_top_comment
      @steps = []
      add_steps!
    end

    def custom_top_comment; 'This is a generated show!' end # Override me!
    def add_steps!; end # Override me!

    def to_a
      @steps
    end

    def add_step(duration, lights)
      step = {
        'duration' => duration.to_s
      }

      if lights && lights.any?
        step['lights'] = {}
        lights.each do |k,v|
          step['lights'][k.to_s] = v
        end
      end

      @steps << step
      step
    end

    def top_comment_text
      "#show_version=6\n# " + @top_comment + "\n# " + Time.now.to_s + "\n"
    end
  end

  class ExampleShow < Show
    def custom_top_comment; 'This is the example show!' end

    def add_steps!
      add_step('334ms', {vlight_for_generated_example_mode: 'purple'})
      add_step('666ms', {vlight_for_generated_example_mode: 'red'})
    end
  end

end
