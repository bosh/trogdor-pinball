module TrogBuild
  class PlanWriter
    PROJECT_ROOT = File.expand_path(File.join(__FILE__, "..", "..", ".."))
    def initialize(config)
      @config = config
    end

    def write!(plan)
      clean_generated_lights!
      clean_generated_config_files!(plan)
      clean_generated_modes!
      write_generated_lights!(plan)
      write_generated_config_files!(plan)
      write_generated_modes!(plan)
    end

    private

    def generated_lights_path
      File.join(PROJECT_ROOT, "config/lights/generated_lights.yaml")
    end

    def mode_manifest_path
      config_file_path("generated_modes.yaml")
    end

    def config_manifest_path
      config_file_path("generated_configs.yaml")
    end

    def diverter_manifest_path
      config_file_path("generated_diverters.yaml")
    end

    def config_file_path(name)
      File.join(PROJECT_ROOT, "config", name)
    end

    def mode_path(name)
      File.join(PROJECT_ROOT, "modes", name)
    end

    def clean_generated_lights!
      puts "Cleaning generated lights" if $debug
      File.delete(generated_lights_path) if File.exist?(generated_lights_path)
    end

    def clean_generated_config_files!(plan)
      clean_generated_modes_manifest!
      clean_generated_configs_manifest!
      clean_generated_diverters_manifest!
      plan.config_files.each do |cf|
        File.delete(config_file_path(cf.name)) if File.exist?(config_file_path(cf.name))
      end
    end

    def clean_generated_modes_manifest!
      puts "Cleaning modes manifest" if $debug
      File.delete(mode_manifest_path) if File.exist?(mode_manifest_path)
    end

    def clean_generated_configs_manifest!
      puts "Cleaning configs manifest" if $debug
      File.delete(config_manifest_path) if File.exist?(config_manifest_path)
    end

    def clean_generated_diverters_manifest!
      puts "Cleaning generated diverters" if $debug
      File.delete(diverter_manifest_path) if File.exist?(diverter_manifest_path)
    end

    def clean_generated_modes!
      puts "Cleaning generated mode folders" if $debug
      found_modes = Dir.glob("#{PROJECT_ROOT}/modes/generated_*")
      found_modes.each do |path|
        FileUtils.remove_dir(path)
      end
    end

    def write_generated_lights!(plan)
      puts "Writing generated lights" if $debug
      File.open(generated_lights_path, 'w') do |file|
        file.write("#config_version=6\n# Generated lights!\n\n")
        write_lights(plan, file)
      end
    end

    def write_lights(plan, file)
      file.write(plan.lights.to_yaml)
    end

    def write_generated_config_files!(plan)
      write_generated_modes_manifest!(plan)
      write_generated_configs_manifest!(plan)
      write_generated_diverters!(plan)

      plan.config_files.each do |cf|
        puts "Writing new config file #{cf.name}" if $debug
        File.open(config_file_path(cf.name), 'w') do |file|
          file.write("#config_version=6\n")
          file.write(cf.to_hash.to_yaml)
          file.write("\n")
        end
      end
    end

    def write_generated_diverters!(plan)
      puts "Writing new generated diverters" if $debug

      diverter_definitions = {'foo' => {'bar' => 'baz'}}
      File.open(diverter_manifest_path, 'w') do |file|
        file.write("#config_version=6\n# This file is generated to allow arbitrary diverter rules\n")
        file.write({'diverters' => diverter_definitions}.to_yaml)
        file.write("\n")
      end
    end

    def write_generated_configs_manifest!(plan)
      puts "Writing new config manifest" if $debug

      config_name_list = plan.config_files.map(&:name)
      File.open(config_manifest_path, 'w') do |file|
        file.write("#config_version=6\n# This file is generated to load the other generated config files\n")
        file.write({'config' => config_name_list}.to_yaml)
        file.write("\n")
      end
    end

    def write_generated_modes_manifest!(plan)
      puts "Writing new mode manifest" if $debug

      mode_name_list = plan.modes.map(&:name)
      File.open(mode_manifest_path, 'w') do |file|
        file.write("#config_version=6\n# This file is generated to load the other generated files\n")
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
