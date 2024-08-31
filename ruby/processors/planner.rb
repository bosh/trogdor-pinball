module TrogBuild
  class Planner
    def initialize(config)
      @config = config
    end

    def plan!
      plan = Plan.new()
      plan.modes << Mode.new("generated_example_2", 131)
      plan
    end
  end
end
