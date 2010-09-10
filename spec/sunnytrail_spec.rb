require 'sunnytrail'
require 'mock'

describe Sunnytrail do

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
    lambda {Sunnytrail.new}.should raise_error(Sunnytrail::ConfigurationError)
  end

  it "should configure properly" do
    Sunnytrail.configure :api_key => "abcdefghijklmnoprstvuxywz"
    Sunnytrail.options[:api_key].should == "abcdefghijklmnoprstvuxywz"
    sunnytrail = Sunnytrail.new
    sunnytrail.options[:api_key].should == "abcdefghijklmnoprstvuxywz"
  end

  it "should be configured" do
    Sunnytrail.options[:api_key].should == "abcdefghijklmnoprstvuxywz"
  end

  it "should override conf when specified in constructor" do
    sunnytrail = Sunnytrail.new :api_key => "thisisthenewtoken"
    sunnytrail.options[:api_key].should == "thisisthenewtoken"
  end

  it "should send event" do
    sunnytrail = Sunnytrail.new
    sunnytrail.add_event(OPTIONS_HASH).should be_true
  end


  describe Sunnytrail::Event do

    it "should translate to hash and json properly" do

      event = Sunnytrail::Event.new
      event.id = 123
      event.name = "User123"
      event.email = "user123@example.com"
      event.action.name = "Signup"
      event.action.created = TIME_NOW
      event.plan.name = "Gold"
      event.plan.price = 123.0
      event.plan.recurring = 31
      event.to_hash.should == OPTIONS_HASH
      event.to_json.should == OPTIONS_HASH.to_json
    end
  end

end
