module TrogBuild
  class Mode
    attr_reader :name, :priority, :shows

    def initialize(name, priority)
      @name = name
      @priority = priority
      @top_comment = 'This is a generated file!'
      @shows = []
    end

    def to_hash
      out = {'mode' => {}}
      mode = out['mode']

      mode['priority'] = @priority
      mode['start_events'] = 'ball_started'

      out['show_player'] = build_show_player if build_show_player

      out
    end

    def top_comment_text
      if @top_comment
        '# ' + @top_comment + "\n# " + Time.now.to_s + "\n"
      end
    end

    private

    def build_show_player
      @show_player ||= {
        "mode_#{name}_started" => {
          'generated_show_a' => {
            'action' => 'play'
          }
        }
      }
    end
  end
end
