module TrogBuild
  class Shot
    attr_reader :name

    def initialize(name, profile, switch, persist_enable, show_tokens)
      @name = name
      @profile = profile
      @switch = switch
      @persist_enable = persist_enable
      @show_tokens = show_tokens || {}

      @control_events = []
      profile.states.each_with_index do |state, i|
        @control_events << {'events' => set_state_event(i), 'state' => i}
      end
    end

    def set_state_event(i)
      state = @profile.states[i]
      "set_shot_state_#{@name}_#{state['name']}"
    end

    def state_hit(i)
      state = @profile.states[i]
      "#{name}_#{state['name']}_hit"
    end

    def advance_event
      "shot_advance_#{name}"
    end

    def to_hash
      {
        'profile' => @profile.name,
        'advance_events' => advance_event,
        'control_events' => @control_events,
        'persist_enable' => @persist_enable,
        'switch' => @switch,
        'show_tokens' => @show_tokens
      }
    end
  end
end
