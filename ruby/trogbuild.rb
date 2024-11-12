#! /usr/bin/env ruby

require_relative './requires'

PLATFORM_WINDOWS = :windows
PLATFORM_LINUX = :linux
def detect_platform
  if RUBY_PLATFORM == 'x64-mingw-ucrt'
    PLATFORM_WINDOWS
  else
    PLATFORM_LINUX
  end
end

$debug = ARGV.include? '--debug'
$platform = detect_platform

module TrogBuild
  def self.generate!
    config = CliParser.build_config(ARGV)
    planner = Planner.new(config)

    plan = planner.plan!

    if config.dry_run
      puts 'Dry run complete'
      exit(0)
    else
      plan_writer = PlanWriter.new(config)
      plan_writer.write!(plan)
    end
  end
end

TrogBuild.generate!
