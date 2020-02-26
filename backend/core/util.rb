
class Util
  def initialize(level)
    @level = level
  end
  
  def read_file
    File.read("../#{@level}/data/input.json")
  end
  
  def write_file(result_data)
    output_file = File.new("../#{@level}/data/result_output.json", 'w')
    output_file.puts(JSON.pretty_generate(result_data))
    output_file.close
  end
end
