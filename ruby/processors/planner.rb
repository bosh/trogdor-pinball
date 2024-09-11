module TrogBuild
  class Planner
    attr_reader :plan
    def initialize(config)
      @config = config
      @plan = nil
    end

    def plan!
      @plan = Plan.new()

      add_generated_lights!
      add_example_mode!
      add_achievement_modes!
      plan
    end

    private

    def add_generated_lights!
      plan.add_light "generated_light_1"

      add_light_sequence "gl_ring_a", 8 do |i, config|
        lights_ab_tag = i % 2 != 0 ? 'lights_a' : 'lights_b'
        config['tags'] = "lights_generated,#{lights_ab_tag},lights_gl_ring_a"
        config['type'] = 'rgb'
        config
      end
    end

    def add_light_sequence(name, count)
      count.times do |i|
        number = i + 1
        config = yield(number, {})
        plan.add_light "#{name}_#{number}", config
      end
    end

    def add_example_mode!
      plan.add_mode ExampleMode.new("generated_example", 131)
    end

    def add_achievement_modes!
      plan.add_mode AchievementMode.new("generated_achievements", 109)
    end
  end
end
