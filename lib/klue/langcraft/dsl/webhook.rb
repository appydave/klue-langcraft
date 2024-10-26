# frozen_string_literal: true

require 'net/http'
require 'json'
require 'uri'

module Klue
  module Langcraft
    module DSL
      # Webhook class for handling HTTP POST requests to specified URLs.
      # This class is responsible for sending processed data to external services
      # via webhooks, handling the delivery process, and logging the results.
      class Webhook
        def deliver(webhook_url, data)
          klue_type = extract_klue_type(data)
          uri = build_uri(webhook_url, klue_type)
          response = send_request(uri, build_payload(klue_type, data))
          log_response(response, uri)
          response
        end

        private

        def extract_klue_type(data)
          data.keys.first.to_s
        end

        def build_uri(webhook_url, klue_type)
          URI.parse("#{webhook_url}?klue-type=#{klue_type}")
        end

        def build_payload(klue_type, data)
          { klue_type: klue_type, data: data }
        end

        def send_request(uri, payload)
          http = Net::HTTP.new(uri.host, uri.port)
          request = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })
          request.body = payload.to_json
          http.request(request)
        end

        def log_response(response, uri)
          puts "Response: #{response.code} - #{response.message}"
          puts "Endpoint: #{uri}"
          log_response_body(response)
        end

        def log_response_body(response)
          body = JSON.parse(response.body)
          puts "DSL Type: #{body['type']}"
          # puts JSON.pretty_generate(body['data'])
        end
      end
    end
  end
end
