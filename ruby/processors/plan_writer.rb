module TrogBuild
  class PlanWriter
    def initialize(config)
      @config = config
    end

    def write!(plan)
      clean_generated_modes_manifest!
      clean_generated_modes!
      write_generated_modes_manifest!
      write_generated_modes!
    end

    private

    def clean_generated_modes_manifest!
      puts "Cleaning modes manifest" if $debug
    end

    def clean_generated_modes!
      puts "Cleaning generated mode folders" if $debug
    end

    def write_generated_modes_manifest!
      puts "Writing new mode manifest" if $debug
    end

    def write_generated_modes!
      puts "Writing generated modes" if $debug
    end
  end
end
