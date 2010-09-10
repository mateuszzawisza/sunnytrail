#SunnyTrail Mock. We override request method not to sent requests to SunnyTrail

class SunnyTrail
  private

  def request(message)
    return true
  end
end
