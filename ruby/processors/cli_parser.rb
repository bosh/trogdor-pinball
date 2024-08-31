module TrogBuild
  class CliParser
    EXAMPLE_CLI_OPTIONS =   ['-e', '--example']
    WRITE_OPTIONS =         ['-x', '--write', '--execute']
    DEBUG_OPTIONS =         ['--debug']

    def self.build_config(argv)
      config = Config.new()

      puts "------", argv.inspect, argv.size, "------" if $debug
      argv.each do |cli_option|
        option_key, option_value = cli_option.split('=')
        puts option_key, '=', option_value, '' if $debug

        if EXAMPLE_CLI_OPTIONS.include? option_key
          puts 'Got example option value:', option_value
        elsif WRITE_OPTIONS.include? option_key
          config.dry_run = false
        elsif DEBUG_OPTIONS.include? option_key
          #do nothing because this is handled by a global elsewhere

        else #unrecognized
          puts "Unrecognized option: #{option_key}"
          puts "with value: #{option_value}" if option_value
        end
      end

      config
    end
  end
end
