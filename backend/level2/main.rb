require_relative '../core/util'
require_relative '../core/calculator'

util = Util.new("level2")

json_data = util.read_file
result_data = Calculator.new(json_data).to_receipt(is_deduce: true)

util.write_file(result_data)