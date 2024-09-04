module TrogBuild
  class Plan
    attr_reader :modes

    def initialize()
      @lights = {}
      @modes = []
    end

    def add_light(name, config = nil)
      config ||= {}
      config['number'] = nil unless config['number']
      config['type'] = 'rgb' unless config['type']
      raise "Light #{name} already registered" if @lights[name]
      @lights[name] = config
    end

    def add_mode(mode)
      @modes << mode
    end

    def lights
      {"lights" => @lights}
    end
  end
end
