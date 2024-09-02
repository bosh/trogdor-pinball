module TrogBuild
  class Planner
    attr_reader :plan
    def initialize(config)
      @config = config
      @plan = nil
    end

    def plan!
      @plan = Plan.new()

      add_example_mode!
      add_achievement_modes!
      plan
    end

    def add_mode(mode)
      plan.modes << mode
    end

    def add_example_mode!
      add_mode ExampleMode.new("generated_example", 131)
    end

    def add_achievement_modes!
      add_mode AchievementMode.new("generated_achievements", 109)
    end
  end
end
