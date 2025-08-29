#! /usr/bin/env ruby

def run!
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

  #switch icon width = 148
  #lights just use position and centering, so a little easier.
end

def convert(normal, max)
  (normal * max).round(2)
end

def convert_dimensions(data, width, height)
  out = {'light' => {}, 'switch' => {}}
  data['light'].each do |(name, source_x, source_y)|
    out['light'][name] = [convert(source_x, width), convert(source_y, width)]
  end

  data['switch'].each do |(name, source_x, source_y)|
    out['switch'][name] = [convert(source_x, width), convert(source_y, width)]
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
    puts "#{line_spaces}, #{current_section}, #{current_device}"

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
