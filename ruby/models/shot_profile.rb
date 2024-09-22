module TrogBuild
  class ShotProfile
    attr_reader :name, :states

    def initialize(name, advance_on_hit)
      @name = name
      @advance_on_hit = advance_on_hit
      @states = []
      @state_names_to_not_rotate = nil
    end

    def add_state(state_name, show, show_tokens)
      state_hash = {'name' => state_name}
      state_hash['show'] = show if show
      state_hash['show_tokens'] = show_tokens if show_tokens
      @states << state_hash
    end

    def set_state_names_to_not_rotate(names)
      @state_names_to_not_rotate = names
    end

    def to_hash
      base = {
        'advance_on_hit' => @advance_on_hit,
        'states' => @states
      }
      base['state_names_to_not_rotate'] = @state_names_to_not_rotate if @state_names_to_not_rotate
      base
    end
  end
end
