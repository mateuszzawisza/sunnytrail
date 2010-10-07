require 'sunnytrail'
require 'mock'

describe Sunnytrail do

  before :all do
      TIME_NOW = Time.now.to_i
      OPTIONS_HASH = {"id" => 123,
              "email" => "user123@example.com",
              "name" => "User123",
              "action" => {
                          "name" => "Signup",
                          "created" => TIME_NOW
                         },
              "plan" => {
                        "name" => "Gold",
                        "price" => 123.0,
                        "recurring" => 31
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
    Sunnytrail.options[:api_key].should == "abcdefghijklmnoprstvuxywz"
  end

  it "should override conf when specified in block" do
    Sunnytrail.configure do |config|
      config[:api_key] = "evennewertoken"
      config[:use_ssl] = false
    end
    Sunnytrail.options[:api_key].should == "evennewertoken"
    Sunnytrail.options[:use_ssl].should be_false
    Sunnytrail.options[:use_ssl] = true
  end

  it "should send event" do
    sunnytrail = Sunnytrail.new 
    sunnytrail.add_event(OPTIONS_HASH).should be_true
  end

  it "should not send event if send_events set to false" do
    sunnytrail = Sunnytrail.new :send_events => false
    sunnytrail.add_event(OPTIONS_HASH).should be_nil
  end

  it "should create log file when in verbose mode" do 
    sunnytrail = Sunnytrail.new(:verbose => true)
    sunnytrail.add_event(OPTIONS_HASH).should be_true
    File.exist?("sunnytrail.log").should be_true

    sunnytrail = Sunnytrail.new(:verbose => true,
                                :log_path => "sunnylogger.log")
    sunnytrail.add_event(OPTIONS_HASH).should be_true
    File.exist?("sunnylogger.log").should be_true

    File.delete("sunnytrail.log")
    File.delete("sunnylogger.log")

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
      JSON.parse(event.to_json).should == OPTIONS_HASH
    end

    it "should set up and clear action and plan attributes properly" do 
      event = Sunnytrail::Event.new
      event.action.name = "signup"
      event.plan.name = "Basic"
      event.action.name.should == "signup"
      event.plan.name.should == "Basic"
      event.action = nil
      event.plan = nil
      event.action.name.should be_nil 
      event.plan.name.should be_nil
    end

    it "should add empty plan and action node to hash when they are not specified" do
      event = Sunnytrail::Event.new
      hash = event.to_hash
      hash["action"].should == {}
      hash["plan"].should == {}
    end
  end


end
