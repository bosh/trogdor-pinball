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
      plan
    end

    def add_example_mode!
      mode = ExampleMode.new("generated_example", 131)
      plan.modes << mode
    end
  end
end
