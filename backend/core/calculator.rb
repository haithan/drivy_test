require 'json'
require 'date'

class Calculator

  DEDUCE_RATE = [
    { value: 1, rate: 10 },
    { value: 4, rate: 30 },
    { value: 10, rate: 50 }
  ].freeze

  def initialize(json_data)
    data = JSON.parse(json_data , symbolize_names: true)
    @cars = data[:cars]
    @rentals = data[:rentals]
  end

  def to_receipt(is_deduce = false)
    receipts = []
    @rentals.each do |rental|
      receipt = {
        id: rental[:id],
        price: calculate_pricing(rental, is_deduce)
      }
      receipts << receipt
    end
    { rentals: receipts }
  end
  
  def calculate_pricing(rental, is_deduce)
    target_car = @cars.select { |car| car[:id] == rental[:car_id] }.first
    period = rental_period(rental[:start_date], rental[:end_date])
    pricing_by_time = calculate_with_time(target_car, period)
    pricing_by_range = calculate_with_range(target_car, rental)
    total_price = total_price(is_deduce, pricing_by_time, pricing_by_range, target_car[:price_per_day], period)
  end

  def calculate_with_time(target_car, period)
    target_car[:price_per_day] * period
  end

  def calculate_with_range(target_car, rental)
    target_car[:price_per_km] * rental[:distance]
  end

  private
  
  def rental_period(start_date, end_date)
    converted_date(end_date) - converted_date(start_date) + 1
  end
  
  def converted_date(date_str)
    Date.parse(date_str).mjd
  end

  def total_price(is_deduce, pricing_by_time, pricing_by_range, price_per_day, period)
    total = pricing_by_time + pricing_by_range
    if is_deduce
      price_after_deduce(total , period, price_per_day)
    end
  end

  def price_after_deduce(price, period, price_per_day)
    price - deduce_price(period, price_per_day)
  end

  def deduce_price(period, price_per_day)
    price = 0
    previous_rate = 0
    previous_value = 0
    DEDUCE_RATE.reverse_each do |e|
      next if e[:value] > period
      actual_day = period - e[:value]
      period = period - actual_day
      price += (price_per_day * (e[:rate].to_f/100) * actual_day)
    end
    price
  end
end