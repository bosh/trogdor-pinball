module TrogBuild
  class PlanWriter
    PROJECT_ROOT = "#{__FILE__}/../../.."
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

    def mode_manifest_path
      "#{PROJECT_ROOT}/config/generated_modes.yaml"
    end

    def mode_path(name)
      "#{PROJECT_ROOT}/modes/#{name}"
    end

    def clean_generated_modes_manifest!
      puts "Cleaning modes manifest" if $debug
      File.delete(mode_manifest_path) if File.exist?(mode_manifest_path)
    end

    def clean_generated_modes!
      puts "Cleaning generated mode folders" if $debug
      found_modes = Dir.glob("#{PROJECT_ROOT}/modes/generated_*")
      found_modes.each do |path|
        FileUtils.remove_dir(path)
      end
    end

    def write_generated_modes_manifest!(plan)
      puts "Writing new mode manifest" if $debug

      mode_name_list = plan.modes.map(&:name)
      File.open(mode_manifest_path, 'w') do |file|
        file.write("#config_version=6\n# This file is generated to load the other generated files")
        file.write({'modes' => mode_name_list}.to_yaml)
        file.write("\n")
      end
    end

    def write_generated_modes!(plan)
      puts "Writing generated modes (#{plan.modes.length})" if $debug
      plan.modes.each do |mode|
        FileUtils.mkdir_p("#{mode_path(mode.name)}/config")
        write_generated_mode!(mode)
      end
    end

    def write_generated_mode!(mode)
      puts "Writing mode: #{mode.name}" if $debug

      File.open("#{mode_path(mode.name)}/config/#{mode.name}.yaml", 'w') do |file|
        file.write "#config_version=6\n#{mode.top_comment_text}"
        file.write mode.to_hash.to_yaml
        file.write("\n")
      end

      FileUtils.mkdir("#{mode_path(mode.name)}/shows") if mode.shows.any?
      mode.shows.each do |show|
        File.open("#{mode_path(mode.name)}/shows/#{show.name}.yaml", 'w') do |file|
          file.write show.top_comment_text
          file.write show.to_a.to_yaml
          file.write("\n")
        end
      end
    end
  end
end
