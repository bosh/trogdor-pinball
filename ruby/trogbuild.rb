#! /usr/bin/env ruby

require_relative './requires'

$debug = ARGV.include? '--debug'

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
