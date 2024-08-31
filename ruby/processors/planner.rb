module TrogBuild
  class Planner
    def initialize(config)
      @config = config
    end

    def plan!
      Plan.new()
    end
  end
end
