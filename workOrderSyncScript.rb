require 'net/http'
require 'uri'

class SyncWorkOrder

  def get_work_order
    puts 'Please enter Cloud Element User token'
    @userToken = gets.chomp
    puts 'Please enter Cloud Element Organization token'
    @organizationToken = gets.chomp
    puts 'Please enter Cloud Element E-Emphasys 2.0 Element Instance token'
    @elementToken = gets.chomp
    puts 'What is your WO number?'
    wo = gets.chomp
    validateWorkOrder(wo)
  end

  def validateWorkOrder(workOrder)
    if workOrder.length == 9 && workOrder.delete('W').to_i != 0
      preForGetCall(workOrder)
    elsif workOrder.length < 9 && workOrder.length > 1
      puts 'It looks like you are missing a digit, please verify work order number'
    elsif workOrder.length >= 1
      puts 'Please make sure you entered a correct work order'
    end
  end

  def preForGetCall(workOrder)
    Array(0...10).each do |missingDigit|
      completeWorkOrder = "#{workOrder}-#{missingDigit}"
      performGetCall(completeWorkOrder)
    end
  end

  def performGetCall(completeWorkOrder)
    url = URI("https://console.cloud-elements.com/elements/api-v2/hubs/fsa/jobs/%7Bid%7D?id=#{completeWorkOrder}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request['accept'] = 'application/json'
    request['authorization'] = "User #{@userToken}, Organization #{@organizationToken}, Element #{@elementToken}"
    request['elements-session'] = 'true'
    request['cache-control'] = 'no-cache'

    checkResponseStatus(http.request(request))
  end

  def checkResponseStatus(response)
    if response.code.to_i == 200
      parsedBody = JSON.parse(response.read_body)
      validateParsedBody(parsedBody)
    end
  end

  def validateParsedBody(parsedBody)
    buildPayloadForPostRequest(parsedBody) if parsedBody.values.pop['contactId'].length.between?(8, 10)
  end

  def buildPayloadForPostRequest(parsedBody)
    payload = {
       "events":[
          {
             "objectType":"jobs",
             "objectId":"#{parsedBody.values.pop["uuid"]}",
             "date":"2017-03-22T04:38:35Z",
             "eventType":"UNKNOWN",
             "elementKey":"eemphasys2"
          }
       ],
       "instance_id":399028
    }

    makePostCallToFormulaInstance(payload)
  end

  def makePostCallToFormulaInstance(payload)
    url = URI('https://console.cloud-elements.com/elements/api-v2/formulas/instances/3647/executions')

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(url)
    request['accept'] = 'application/json'
    request['authorization'] = "User #{@userToken}, Organization #{@organizationToken}"
    request['content-type'] = 'application/json'
    request['cache-control'] = 'no-cache'
    request.body = payload.to_json

    response = http.request(request)
    puts response.read_body
  end

  def starter
    get_work_order
  end
end

SyncWorkOrder.new.starter
