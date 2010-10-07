#Sunnytrail Mock. We override request method not to sent requests to SunnyTrail


class Net::HTTP
  def post(*args)
    Net::HTTPResponse.new "HTTP/1.0", 200, "OK"
  end
end
