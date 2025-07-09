module TrogBuild
  class AchievementMode < Mode
    def custom_top_comment; 'Majesty Achievements!' end
    def generate_start_events; 'ball_started' end

    def initialize(*args)
      super
      @achievements = [
        achievement('burnination',        1, 'burnination_controller'),
        achievement('power_puncher',      2, 'achievement_pp'), #slings and pops
        achievement('capture_capturerer', 3, 'achievement_qq'), #vuks and capture diverter
        achievement('ramp_rider',         4, 'achievement_rr'),
        achievement('spinner_spinner',    5, 'achievement_ss'),
        achievement('target_targeter',    6, 'achievement_tt'),
      ]
    end

    def add_shows!
      @rainbow_show = Show.new('majesty_rainbow_loop', '6 majesty lights spin twice')
      6.times do |i|
        @rainbow_show.add_step('150ms', rainbow_step(i))
      end

      add_show(@rainbow_show)
    end

    def rainbow_step(i)
      colors = %w(green yellow orange red purple blue)
      (1..6).inject({'lights_gi' => colors[i%6]}) do |memo, light_number|
        memo["l_majesty_#{light_number}"] = colors[(light_number+i) % 6]
        memo
      end
    end

    def show_player
      {
        "celebrate_achievement" => {
          @rainbow_show.name => {
            'action' => 'play',
            'loops' => 2
          }
        }
      }
    end

    def custom_hash
      @achievements.inject({'achievements' => {}}) do |out, a|
        out['achievements'].merge!({a.name => a.to_hash})
        out
      end
    end

    def achievement(name, majesty_number, custom_name=nil)
      if custom_name
        Achievement.new(name, majesty_number, "#{custom_name}_begin", "#{custom_name}_fail", "#{custom_name}_complete")
      else
        Achievement.new(name, majesty_number)
      end
    end
  end

  class Achievement
    attr_reader :name
    def initialize(name, majesty_number, start_events=nil, stop_events=nil, complete_events=nil)
      @name = name
      @light = "l_majesty_#{majesty_number}"
      @start_events = start_events || "mode_start_achievement_#{name}"
      @stop_events = stop_events || "mode_fail_achievement_#{name}"
      @complete_events = complete_events || "mode_complete_achievement_#{name}"
    end

    def to_hash
      {
        'start_enabled' => true,
        'show_tokens' => {'light' => @light},
        'show_when_started' => nil,
        'show_when_completed' => 'on',
        'restart_after_stop_possible' => true,
        'events_when_completed' => 'celebrate_achievement',
        'start_events' => 'mode_generated_achievements_started',
        'stop_events' => nil,
        'complete_events' => @complete_events
      }
    end
  end
end
