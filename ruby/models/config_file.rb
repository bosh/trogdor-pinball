module TrogBuild
  class ConfigFile
    attr_reader :name
    def initialize(name)
      @name = name
      after_initialize
    end

    def after_initialize
      #Stub for subclasses
    end
  end
end
