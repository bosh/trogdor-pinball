module TrogBuild
  class ShotGroup
    attr_reader :name

    def initialize(name, shots, allow_rotation)
      @name = name
      @shot_names = shots.map(&:name)
      @allow_rotation = allow_rotation
    end

    def rotate_left_event
      "#{name}_rotate_left"
    end

    def rotate_right_event
      "#{name}_rotate_right"
    end

    def to_hash
      base = {
        'shots' => @shot_names
      }
      base['rotate_left_events'] = rotate_left_event if @allow_rotation
      base['rotate_right_events'] = rotate_right_event if @allow_rotation
      base
    end
  end
end
