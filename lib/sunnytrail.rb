require 'net/http'
require 'net/https'
require 'json'
require 'hashie'

class Sunnytrail


  class ConfigurationError < StandardError; end

  attr_accessor :options


  # class methods

  class << self
    def configure(options = {}, &block)
      default_options = {
        :api_url => "api.thesunnytrail.com",
        :api_key => nil,
        :use_ssl => true,
        :verbose => false,
        :send_events => true
      }

      block.call(options) if block_given?
      @options = default_options.merge(options)
    end

    def options
      @options ||= {}
    end

    def add_event(args={})
      sunny_trail = Sunnytrail.new
      sunny_trail.add_event(args)
    end
  end

  # EOF class methods

  # instance methods
  def initialize(init_options={})
    @options = Sunnytrail.options.merge(init_options)
    raise ConfigurationError, "API KEY not set" if @options[:api_key].nil?
  end

  def add_event(args={})
    request args
  end

  # EOF instance methods


  private

  def setup_call
    api = Net::HTTP.new(@options[:api_url], @options[:use_ssl] ? 443 : 80)
    api.use_ssl = true if @options[:use_ssl]
    api
  end

  def request(message)

    api = setup_call
    
    response = api.post("/messages?apikey=#{@options[:api_key]}",
                        "message=#{message.to_json}")

    case response.code.to_i
    when 200..202
      return true
    when 403
      raise "The request is invalid: #{response.body}"
    when 503
      raise "Service Unavailable"
    else
      raise "#{response.code}: #{response.message}"
    end
  end

  class Event < Hashie::Dash

    attr_writer :action, :plan
    
    property :id
    property :name
    property :email

    def action
      @action ||= Action.new
    end

    def plan
      @plan ||= Plan.new
    end

    def to_hash
      out = {}
      out["action"] = @action.nil? ? {} : @action.to_hash
      out["plan"] = @plan.nil? ? {} : @plan.to_hash
      keys.each do |k|
        out[k] = Hashie::Hash === self[k] ? self[k].to_hash : self[k]
      end
      out
    end

    def to_json
      to_hash.to_json
    end

    class Action < Hashie::Dash
      property :name
      property :created
    end

    class Plan < Hashie::Dash
      property :name
      property :price
      property :recurring
    end

  end

end
