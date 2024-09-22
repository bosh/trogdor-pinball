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
      @tick_options = []
    end

    def add_tick_option(rate_name, speed)
      @tick_options << [rate_name, speed]
    end

    def start_event;    "timer_#{name}_start" end
    def stop_event;     "timer_#{name}_stop" end
    def reset_event;    "timer_#{name}_reset" end
    def complete_event; "timer_#{name}_complete" end
    def stopped_event;  "timer_#{name}_stopped" end
    def set_tick_interval_event(rate_name); "timer_#{name}_set_tick_interval_#{rate_name}" end

    def generate_control_events
      base = [
        control_event('start', start_event),
        control_event('stop', stop_event),
        control_event('reset', reset_event),
      ]

      @tick_options.each do |(rate_name, speed)|
        speed_float = speed.to_i / 1000.0
        base << control_event('set_tick_interval', set_tick_interval_event(rate_name), {'value' => speed_float})
      end

      base
    end

    def control_event(action, event_name, extra = {})
      {'event' => event_name, 'action' => action}.merge(extra)
    end

    def to_hash
      {
        'start_value' => @start_value,
        'end_value' => @end_value,
        'direction' => @is_countdown ? 'down' : 'up',
        'tick_interval' => @tick_interval,
        'start_running' => @start_running,
        'restart_on_complete' => @restart_on_complete,
        'control_events' => generate_control_events
      }
    end
  end
end
