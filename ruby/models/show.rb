module TrogBuild
  class Show
    attr_reader :name

    def initialize(name, top_comment)
      @name = name
      @top_comment = top_comment
      @steps = []
    end

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
      "#show_version=6\n# " + @top_comment + "\n\n"
    end
  end
end
