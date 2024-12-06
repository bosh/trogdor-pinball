module TrogBuild
  class DivertersConfig < ConfigFile
    DIVERTERS = [
    ]

    def to_hash
      diverter_definitions = {}
      # DIVERTERS.each { |d| add_diverter_combinations(diverter_definitions, d) }
      {'diverters' => diverter_definitions}
    end

    private

    def add_diverter_combinations(collection, name)

    end
  end
end
