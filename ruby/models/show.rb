module TrogBuild
  class Show
    attr_reader :name

    def initialize(name)
      @name = name
      @top_comment = 'This is a generated show!'
    end

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

    def top_comment_text
      if @top_comment
        "#show_version=6\n# " + @top_comment + "\n# " + Time.now.to_s + "\n"
      end
    end
  end
end
