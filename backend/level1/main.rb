require 'json'
require 'date'

class Calculate
  def initialize(json_data)
    data = JSON.parse(json_data , symbolize_names: true)
    @cars = data[:cars]
    @rentals = data[:rentals]
  end

  def to_receipt
    receipts = []
    @rentals.each do |rental|
      receipt = {
        id: rental[:id],
        price: calculate_pricing(rental)
      }
      receipts << receipt
    end
    { rentals: receipts }
  end
  
  def calculate_pricing(rental)
    target_car = @cars.select { |car| car[:id] == rental[:car_id] }.first
    pricing_by_time = target_car[:price_per_day] * rental_period(rental[:start_date], rental[:end_date])
    pricing_by_range = target_car[:price_per_km] * rental[:distance]
    total_price = pricing_by_time + pricing_by_range
  end
  
  def rental_period(start_date, end_date)
    converted_date(end_date) - converted_date(start_date) + 1
  end
  
  def converted_date(date_str)
    Date.parse(date_str).mjd
  end
end


json_data = File.read('data/input.json')

result = Calculate.new(json_data).to_receipt

output_file = File.new('data/result_output.json', 'w')
output_file.puts(JSON.pretty_generate(result))
output_file.close




