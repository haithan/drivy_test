require_relative '../core/util'
require_relative '../core/rental'
require 'json'

util = Util.new("level4")

json_data = JSON.parse(util.read_file , symbolize_names: true)
cars_json = json_data[:cars]
rentals_json = json_data[:rentals]
    receipts = []
    rentals_json.each do |rental|
      rental = Rental.new(rental, cars_json)
      rental.calculate_price(is_deduce: true)
      rental.calculate_commission
      receipts << rental.to_action_json
    end
    { rentals: receipts }
result_data = { rentals: receipts }

util.write_file(result_data)