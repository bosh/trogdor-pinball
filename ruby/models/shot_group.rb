module TrogBuild
  class ShotGroup
    attr_reader :name

    def initialize(name, shot_names)
      @name = name
      @shot_names = shot_names
    end

    def rotate_left_event
      "#{name}_rotate_left"
    end

    def rotate_right_event
      "#{name}_rotate_right"
    end

    def to_hash
      {
        'shots' => @shot_names,
        'rotate_left_events' => rotate_left_event,
        'rotate_right_events' => rotate_right_event
      }
    end
  end
end
