module TrogBuild
  class Planner
    attr_reader :plan
    def initialize(config)
      @config = config
      @plan = nil
    end

    def plan!
      @plan = Plan.new()

      add_generated_lights!
      add_example_mode!
      add_achievement_modes!
      add_slots_modes!
      plan
    end

    private

    def add_generated_lights!
      plan.add_light "generated_light_1"

      add_light_sequence "gl_ring_a", 8 do |i, config|
        lights_2ab_tag = i % 2 != 0 ? 'lights_2a' : 'lights_2b'
        config['tags'] = "lights_generated,#{lights_2ab_tag},lights_gl_ring_a"
        config['type'] = 'rgb'
        config
      end

      add_light_sequence "gl_grid", 9 do |i, config|
        lights_2ab_tag = i % 2 != 0 ? 'lights_2a' : 'lights_2b'
        config['tags'] = "lights_generated,#{lights_2ab_tag},grid_lights"
        config['type'] = 'rgb'
        config
      end

      cobra_exp_base_address = 'exp_playfield-4-'
      cobra_number = 0
      ['a','b','c','d'].each do |letter|
        add_light_sequence "gl_cobra_ring_#{letter}", 8 do |i, config|
          cobra_number += 1
          lights_2ab_tag = i % 2 != 0 ? 'lights_2a' : 'lights_2b'
          config['tags'] = "lights_generated,#{lights_2ab_tag},lights_rings,lights_pf,lights_cobra_ring_#{letter}"
          config['type'] = 'rgb'
          config['platform'] = "fast"
          config['number'] = "exp_playfield-3-#{cobra_number}"
          config
        end
      end

    end

    def add_light_sequence(name, count)
      count.times do |i|
        number = i + 1
        config = yield(number, {})
        plan.add_light "#{name}_#{number}", config
      end
    end

    def add_example_mode!
      plan.add_mode ExampleMode.new("generated_example", 1310)
    end

    def add_achievement_modes!
      plan.add_mode AchievementMode.new("generated_achievements", 1090)
    end

    def add_slots_modes!
      plan.add_mode SlotsMode.new("generated_slots", 1020)
    end
  end
end
