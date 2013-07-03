require "contactually/version"
require "json"

module Contactually
  class API
    def initialize(api_key)
      @api_key = api_key
    end

    def call(method, args)
      parsed_response = make_call(method, args)
      parsed_response
    end

    def method_missing(method, *args)
      call(method, args)
    end

    private
    def param_fields(args)
      params = {}
      params = args.first.merge(params) if args.first
      params
    end

    def make_call(method, args={})
      http_method, contactually_method = get_methods(method)
      uri = build_uri(contactually_method, args)
      response = Curl.send(http_method.to_sym, uri, JSON.dump(param_fields(args))) do |curl|
        curl.headers['Accept'] = 'application/json'
        curl.headers['Content-Type'] = 'application/json'
      end
      JSON.load("[#{response.body_str}]").first
    end

    def build_uri(contactually_method, args={})
      #return "https://www.contactually.com/api/v1/#{contactually_method}/#{args[:id]}.json" if args[:id]
      "https://www.contactually.com/api/v1/#{contactually_method}.json?api_key=#{@api_key}"
    end

    def get_methods(method)
      methods = method.to_s.split("_", 2)
    end

  end
end
