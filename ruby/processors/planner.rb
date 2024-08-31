module TrogBuild
  class Planner
    def initialize(config)
      @config = config
    end

    def plan!
      plan = Plan.new()
      mode = Mode.new("generated_example", 131)
      show = Show.new("generated_show_a")
      mode.shows << show
      plan.modes << mode
      plan
    end
  end
end
