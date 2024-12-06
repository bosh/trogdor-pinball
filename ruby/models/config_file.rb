module TrogBuild
  class ConfigFile
    attr_reader :name
    def initialize(name)
      @name = name
    end
  end
end
