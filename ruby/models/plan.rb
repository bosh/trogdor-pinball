module TrogBuild
  class Plan
    attr_reader :modes

    def initialize()
      @next_light_number = 11001
      @lights = {}
      @modes = []
    end

    def add_light(name, config = nil)
      config ||= {}
      config['number'] = consume_light_number unless config['number']
      config['platform'] = 'smart_virtual' unless config['smart_virtual']
      config['type'] = 'rgb' unless config['type']
      raise "Light #{name} already registered" if @lights[name]
      @lights[name] = config
    end

    def add_mode(mode)
      @modes << mode
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
