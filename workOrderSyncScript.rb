require 'uri'
require 'net/http'
require 'openssl'
require 'pry'

class SyncWorkOrder
  attr_reader :wo

  def get_work_order
    puts 'What is your WO number?'
    @wo = gets.chomp
    validate_work_order(wo)
  end

  def validate_work_order(workOrder)
    if workOrder.length == 9 && workOrder.delete('W').to_i != 0
      prep_for_get_call(workOrder)
    elsif workOrder.length < 9 && workOrder.length > 1
      puts 'It looks like you are missing a digit, please verify work order number'
    elsif workOrder.length >= 1
      puts 'Please make sure you entered a correct work order'
    end
  end

  def prep_for_get_call(workOrder)
    Array(0...10).each do |missingDigit|
      completeWorkOrder = "#{workOrder}-#{missingDigit}"
      make_call(completeWorkOrder)
    end
  end

  def make_call(completeWorkOrder)
    url = URI("https://console.cloud-elements.com/elements/api-v2/hubs/fsa/jobs/%7Bid%7D?id=#{completeWorkOrder}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request['accept'] = 'application/json'
    request['authorization'] = '{userTokensWillBeEnteredHere}'
    request['elements-session'] = 'true'
    request['cache-control'] = 'no-cache'

    response = http.request(request)
    puts completeWorkOrder
    #
    # if response.code == 200
    #   # we will use this response to check if we have
    #   # an actual work order
    # elsif response.code != 200
    #   # we will probably go through the loop again, until the index is over
    #   # or we get an actual 200 response
  end

  def starter
    get_work_order
  end
end

SyncWorkOrder.new.starter
