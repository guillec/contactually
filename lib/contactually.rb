require "contactually/version"
require "json"

module Contactually
  class API

    ReturnValue = Struct.new(:code, :body)

    HTTP_ACTIONS = %w(get post put delete).freeze
    METHODS      = %w(contacts notes groupings).freeze

    attr_reader :http_action, :contactually_method

    def initialize(api_key, headers = {})
      @api_key = api_key

      # The Contactually API recommends passing in a User-Agent header unique to
      # the client application as a best practice
      # (see: http://developers.contactually.com/docs/):
      #
      #     Contactually::API.new(
      #         { "YOUR_CONTACTUALLY_API_KEY", :user_agent => "YOUR_APP_NAME" }
      #     )
      #
      @headers = headers
    end

    def call(method, params)
      if (parsed_response = make_call(method, params))
        parsed_response
      else
        false
      end
    end

    def method_missing(method, *args)
      call(method, args.try(:first) || {})
    end

    private

    def param_fields(params)
      return params.to_json unless %w(get delete).include?(http_action)
      params
    end

    def make_call(composite, params = {})
      unless get_methods(composite)
        return ReturnValue.new(400, "Bad action/method '#{composite}'")
      end
      uri      = build_uri(contactually_method, params)
      response = Curl.send(http_action.to_sym, uri, param_fields(params)) do |curl|
        @headers.each do |header_name, header_value|
          curl.headers[header_name.to_s.titleize.gsub(" ", "-")] = header_value
        end
        curl.headers['Accept']       = 'application/json'
        curl.headers['Content-Type'] = 'application/json'
      end

      if [200, 201, 202].include?(response.response_code)
        return ReturnValue.new(
          response.response_code,
          JSON.load("[#{response.body_str}]").first
        )
      end
      ReturnValue.new(response.response_code, response.body_str)
    rescue => e
      ReturnValue.new(500, "Could not complete call, #{e.message}")
    end

    def build_uri(contactually_method, args = {})
      id_arg = args.has_key?(:id) ? "/#{args["id"]}" : ""
      "https://www.contactually.com/api/v1/#{contactually_method}#{id_arg}.json?api_key=#{@api_key}"
    end

    def get_methods(composite)
      http_action, contactually_method = composite.to_s.split("_", 2)
      return false unless HTTP_ACTIONS.include?(http_action)
      return false unless METHODS.include?(contactually_method)
      [@http_action = http_action, @contactually_method = contactually_method]
    end

  end
end
