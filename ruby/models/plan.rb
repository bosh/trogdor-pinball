module TrogBuild
  class Plan
    attr_reader :modes, :config_files

    def initialize()
      @next_light_number = 8801
      @lights = {}
      @modes = []
      @config_files = []
    end

    def add_light(name, config = nil)
      config ||= {}
      config['number'] = consume_light_number unless config['number']
      config['platform'] = 'smart_virtual' unless config['platform']
      config['type'] = 'rgb' unless config['type']
      raise "Light #{name} already registered" if @lights[name]
      @lights[name] = config
    end

    def add_mode(mode)
      @modes << mode
    end

    def add_sound_hooks(sound_hooks_config)
      @config_files << sound_hooks_config
    end

    def consume_light_number
      next_number = @next_light_number
      @next_light_number += 1
      next_number
    end

    def lights
      {"lights" => @lights}
    end
  end
end
