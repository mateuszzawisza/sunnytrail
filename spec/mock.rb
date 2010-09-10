#Sunnytrail Mock. We override request method not to sent requests to SunnyTrail

class Sunnytrail
  private

  def request(message)
    return true
  end
end
