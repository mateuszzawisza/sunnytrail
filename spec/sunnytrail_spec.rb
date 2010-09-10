require 'sunnytrail'
require 'mock'

describe SunnyTrail do

  before :all do
      TIME_NOW = Time.now.to_i
      OPTIONS_HASH = {:id => 123,
              :email => "user123@example.com",
              :name => "User123",
              :action => {
                          :name => "Signup",
                          :created => TIME_NOW
                         },
              :plan => {
                        :name => "Gold",
                        :price => 123.0,
                        :recurring => 31
                       }
             }

  end

  it "should raise exception if not configured" do
    lambda {SunnyTrail.new}.should raise_error(SunnyTrail::ConfigurationError)
  end

  it "should configure properly" do
    SunnyTrail.configure :api_key => "abcdefghijklmnoprstvuxywz"
    SunnyTrail.options[:api_key].should == "abcdefghijklmnoprstvuxywz"
    sunnytrail = SunnyTrail.new
    sunnytrail.options[:api_key].should == "abcdefghijklmnoprstvuxywz"
  end

  it "should be configured" do
    SunnyTrail.options[:api_key].should == "abcdefghijklmnoprstvuxywz"
  end

  it "should override conf when specified in constructor" do
    sunnytrail = SunnyTrail.new :api_key => "thisisthenewtoken"
    sunnytrail.options[:api_key].should == "thisisthenewtoken"
  end

  it "should send event" do
    sunnytrail = SunnyTrail.new
    sunnytrail.add_event(OPTIONS_HASH).should be_true
  end


  describe SunnyTrail::Event do

    it "should translate to hash and json properly" do

      event = SunnyTrail::Event.new
      event.id = 123
      event.name = "User123"
      event.email = "user123@example.com"
      event.action.name = "Signup"
      event.action.created = TIME_NOW
      event.plan.name = "Gold"
      event.plan.price = 123.0
      event.plan.recurring = 31
      event.to_hash.should == OPTIONS_HASH
      json = event.to_json.should == "{\"plan\":{\"price\":123.0,\"recurring\":31,\"name\":\"Gold\"},\"email\":\"user123@example.com\",\"action\":{\"created\":#{TIME_NOW},\"name\":\"Signup\"},\"name\":\"User123\",\"id\":123}"
    end
  end

end
