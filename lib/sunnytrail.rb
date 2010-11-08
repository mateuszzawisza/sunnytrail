require 'net/http'
require 'net/https'
require 'json'
require 'hashie'
require 'logger'
require 'cgi'

class Sunnytrail


  class ConfigurationError < StandardError; end

  attr_accessor :options


  # class methods

  class << self
    def configure(options = {}, &block)
      default_options = {
        :api_url     => "api.thesunnytrail.com",
        :api_key     => nil,
        :use_ssl     => true,
        :verbose     => false,
        :send_events => true,
        :log_path    => 'sunnytrail.log'
      }

      block.call(options) if block_given?
      @options = default_options.merge(options)
    end

    def options
      @options ||= {}
    end

    def add_event(args={})
      @sunny_trail ||= Sunnytrail.new
      @sunny_trail.add_event(args)
    end
  end

  # EOF class methods


  # instance methods
  def initialize(init_options={})
    @options = Sunnytrail.options.merge(init_options)
    start_logger if verbose?
    raise ConfigurationError, "API KEY not set" if @options[:api_key].nil?
  end

  def add_event(args={})
    message = args.to_json
    @logger.info("Event sent: #{message}") if verbose?
    request(message) if @options[:send_events]
  end

  def verbose?
    !!@options[:verbose]
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
    
    #CGI encode the message
    message = CGI.escape(message)

    response = api.post("/messages?apikey=#{@options[:api_key]}",
                        "message=#{message}")

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

  def start_logger
    @logger = Logger.new(@options[:log_path]) if verbose?
    @logger.formatter = proc{|s,t,p,m|"%5s [%s] (%s) %s :: %s\n" % [s, t.strftime("%Y-%m-%d %H:%M:%S"), $$, p, m]}
    @logger.info "Options set:"
    @options.each_pair do |option, value|
      @logger.info "#{option} => #{value}"
    end
    @logger.info "EOF Options\n\n"
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
