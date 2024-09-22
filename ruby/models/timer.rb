module TrogBuild
  class Timer
    attr_reader :name
    def initialize(name, start_value, end_value, tick_interval, is_countdown, start_running, restart_on_complete)
      @name = name
      @is_countdown = is_countdown
      @start_value = start_value
      @end_value = end_value
      @tick_interval = tick_interval
      @start_running = start_running
      @restart_on_complete = restart_on_complete
    end

    def start_event
      "timer_#{name}_start"
    end
    def stop_event
      "timer_#{name}_stop"
    end
    def reset_event
      "timer_#{name}_reset"
    end

    def complete_event
      "timer_#{name}_complete"
    end

    def stopped_event
      "timer_#{name}_stopped"
    end

    def to_hash
      {
        'start_value' => @start_value,
        'end_value' => @end_value,
        'direction' => @is_countdown ? 'down' : 'up',
        'tick_interval' => @tick_interval,
        'start_running' => @start_running,
        'restart_on_complete' => @restart_on_complete,
        'control_events' => [
          {'action' => 'start', 'event' => start_event},
          {'action' => 'stop', 'event' => stop_event},
          {'action' => 'reset', 'event' => reset_event},
        ]
      }
    end
  end
end
