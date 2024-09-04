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

    def add_generated_lights!
      plan.add_light "generated_light_1"
    end

    def add_example_mode!
      plan.add_mode ExampleMode.new("generated_example", 131)
    end

    def add_achievement_modes!
      plan.add_mode AchievementMode.new("generated_achievements", 109)
    end
  end
end
