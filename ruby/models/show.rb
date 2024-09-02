module TrogBuild
  class Show
    attr_reader :name

    def initialize(name)
      @name = name
      @top_comment = custom_top_comment
    end

    def custom_top_comment; 'This is a generated show!' end

    def to_a
      []
    end

    def top_comment_text
      "#show_version=6\n# " + @top_comment + "\n# " + Time.now.to_s + "\n"
    end
  end

  class ExampleShow < Show
    def custom_top_comment; 'This is the example show!' end

    def to_a
      out = []
      out << {
        'duration' => '334ms',
        'lights' => {
          'vlight_for_generated_example_mode' => 'off'
        }
      }
      out << {
        'duration' => '666ms',
        'lights' => {
          'vlight_for_generated_example_mode' => 'green'
        }
      }
      out
    end
  end
end
