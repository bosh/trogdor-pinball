module TrogBuild
  class Config
    attr_accessor :dry_run

    def initialize()
      @dry_run = true
    end
  end
end
