module TrogBuild
  class PlanWriter
    def initialize(config)
      @config = config
    end

    def write!(plan)
      clean_generated_modes_manifest!
      clean_generated_modes!
      write_generated_modes_manifest!(plan)
      write_generated_modes!(plan)
    end

    private

    def clean_generated_modes_manifest!
      puts "Cleaning modes manifest" if $debug
      puts
    end

    def clean_generated_modes!
      puts "Cleaning generated mode folders" if $debug
      puts
    end

    def write_generated_modes_manifest!(plan)
      puts "Writing new mode manifest" if $debug
      puts "#config_version=6\n# This file is generated to load the other generated files"
      mode_name_list = plan.modes.map(&:name)
      puts ({'modes' => mode_name_list}.to_yaml)
      puts
    end

    def write_generated_modes!(plan)
      puts "Writing generated modes" if $debug
      plan.modes.each do |mode|
        write_generated_mode!(mode)
      end
      puts
    end

    def write_generated_mode!(mode)
      puts "Writing mode: #{mode.name}" if $debug
      puts "#config_version=6\n#{mode.top_comment_text}"
      puts mode.to_hash.to_yaml
    end
  end
end
