#! /usr/bin/env ruby

def run!
  if ARGV[0].nil? || ARGV[0].empty?
    puts 'USAGE:', 'ruby monitor/convert_pre_80_monitor_positions.rb monitor/monitor.yaml gmc/monitor/playfield.tscn 1000, 2000'
    exit(1)
  end

  puts "Monitor Converter go!"
  infile = ARGV[0]
  outfile = ARGV[1]

  target_width = ARGV[2].to_i # maybe can be replaced with lookup in tscn
  target_height = ARGV[3].to_i
  puts infile, outfile, target_width, target_height

  test_file(infile)
  test_file(outfile)

  source_data = load_infile(infile)
  converted_data = convert_dimensions(source_data, target_width, target_height)

  target_configs = load_target_file(outfile)
  # print target_configs.join("\n") #note that some are switches or lights, not strings
  update_target_configs(target_configs, converted_data)
  write_outfile(target_configs, outfile)
end

class Node
  attr_reader :name 
  def initialize(name, original)
    @name = name
    @original = original.rstrip
    @properties = {}
  end

  def add_property(instance)
    @properties[instance.name] = instance
  end

  def get_center
    puts 'Need to override get_center'
    exit(1)
  end
end

class Switch < Node
  def get_center
    #four offsets
    l = @properties['offset_left'].value.to_f
    r = @properties['offset_right'].value.to_f
    t = @properties['offset_top'].value.to_f
    b = @properties['offset_bottom'].value.to_f
    mid_x = ((l+r) / 2).round(2)
    mid_y = ((t+b) / 2).round(2)
    [mid_x, mid_y]
  end

  def set_center(x, y)
    diameter = 148 # seems to be fixed in the Control layout
    @properties['offset_left'].value   = (x - diameter/2).round(2) # center minus half diameter
    @properties['offset_right'].value  = (x + diameter/2).round(2) # center plus half diameter
    @properties['offset_top'].value    = (y - diameter/2).round(2) # center minus half diameter
    @properties['offset_bottom'].value = (y + diameter/2).round(2) # center plus half diameter
  end

  def to_s
    @original #+ ":S - " + get_center.join(",")
  end
end

class Light < Node
  def get_center
    #scale unnecessary
    position_vector = @properties['position'].value
    xy = position_vector.match(/Vector2\((.*), (.*)\)/)
    mid_x = xy.match(1).to_f
    mid_y = xy.match(2).to_f
    [mid_x, mid_y]
  end

  def set_center(x, y)
    @properties['position'].value = "Vector2(#{x.to_f.round(2)}, #{y.to_f.round(2)})"
  end

  def to_s
    @original #+ ":L" + get_center.join(",")
  end
end

class Property
  attr_reader :name, :value
  attr_writer :value
  def initialize(name, value, original, node)
    @name = name.strip
    @value = value.strip
    @original = original.rstrip
    node.add_property(self)
  end

  def to_s
    "#{@name} = #{@value}" #+ ":P"
  end
end

def write_outfile(lines, file_path)
  File.open(file_path, 'w') do |file|
    lines.each do |line|
      file.puts(line)
    end
  end
end

def update_target_configs(lines, converted_data)
  lines.each do |line|
    converted = if line.is_a? Switch
      converted_data['switch'][line.name]
    elsif line.is_a? Light
      converted_data['light'][line.name]
    else
      nil
    end

    if converted
      line.set_center(converted[0], converted[1])
    end
  end
end

PROPERTIES_OF_INTEREST = [
  'position', 'scale',
  'offset_left', 'offset_right', 'offset_top', 'offset_bottom'
]

def parse_property_line(line, node)
  info = line.match(/^([^=]+)=(.*)/)
  if info && PROPERTIES_OF_INTEREST.include?(info.match(1).strip)
    Property.new(info.match(1), info.match(2), line, node)
  else #every node should match the simple = split
    line.rstrip
  end
end

def parse_node_line(line)
  line.match(/^\[(\w+) ?(.*)/)
  node_info = $2
  parent = node_info.match(/parent="(.*?)"/)
  if parent
    name = node_info.match(/name="(.*?)"/)
    if parent.match(1) == 'lights'
      Light.new(name.match(1), line)
    elsif parent.match(1) == 'switches'
      Switch.new(name.match(1), line)
    else # not a switch or light
      line
    end
  else #every node should match parent
    line
  end
end

def parse_godot_node(line)
  line.match(/^\[(\w+)/)
  if $1
    if $1 == 'node'
      parse_node_line(line)
    else # ext_resource or whatever else
      line
    end
  else #property value line
    line
  end
end

def load_target_file(file_path)
  data = File.readlines(file_path)
  out_lines = []

  current_device = nil

  data.each do |line|
    if line.strip.length == 0
      out_lines << ""
      current_device = nil
      next
    end

    if line.start_with?('[') # node definition
      device_line = parse_godot_node(line)
      current_device = device_line
      out_lines << device_line
      next
    end

    if [Switch, Light].include? current_device.class
      property_line = parse_property_line(line, current_device)
      out_lines << property_line
    else
      out_lines << line.rstrip
    end
  end

  out_lines
end

def convert(normal, max)
  (normal * max).round(2)
end

def convert_dimensions(data, width, height)
  out = {'light' => {}, 'switch' => {}}
  data['light'].each do |(name, source_x, source_y)|
    out['light'][name] = [convert(source_x, width), convert(source_y, height)]
  end

  data['switch'].each do |(name, source_x, source_y)|
    out['switch'][name] = [convert(source_x, width), convert(source_y, height)]
  end
  out
end

def load_infile(file_path)
  data = File.readlines(file_path)
  configs = {'light' => [], 'switch' => []}

  current_section = nil
  current_device = nil
  current_x = nil
  current_y = nil

  data.each do |file_line|
    untrimmed_line = file_line.rstrip
    line = untrimmed_line.lstrip
    line_spaces = untrimmed_line.length - line.length
    # puts "#{line_spaces}, #{current_section}, #{current_device}"

    if line.start_with?('device_size:')
      current_section = current_device = current_x = current_y = nil
    elsif line_spaces == 0 && line.end_with?(':')
      current_section = line.delete_suffix(':')
      current_device = current_x = current_y = nil
    elsif line_spaces == 2 && ['light', 'switch'].include?(current_section)
      current_device = line.delete_suffix(':')
      current_x = current_y = nil
    elsif line_spaces == 4 && current_device
      source_dimension = line.split(':').last.to_f
      if line.start_with?('x:')
        current_x = source_dimension
      elsif line.start_with?('y:')
        current_y = source_dimension
      end
      if current_x && current_y
        configs[current_section].push([current_device, current_x, current_y])
        current_device = current_x = current_y = nil
      end
    end
  end

  configs
end

def test_file(file_path)
  unless File.exist?(file_path)
    puts "Error: File not found at '#{file_path}'."
    exit
  end
end

run!
