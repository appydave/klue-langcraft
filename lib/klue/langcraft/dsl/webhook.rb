# frozen_string_literal: true

module Klue
  module Langcraft
    module DSL
      class Webhook
        def deliver(webhook_url, data)
          root_key = data.keys.first
          klue_type = root_key.to_s

          uri = URI.parse("#{webhook_url}?klue-type=#{klue_type}")
          http = Net::HTTP.new(uri.host, uri.port)
          request = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })

          payload = { klue_type: klue_type, data: data }
          request.body = payload.to_json

          response = http.request(request)

          puts "Response: #{response.code} - #{response.message}"
          puts "Endpoint: #{uri}"

          body = JSON.parse(response.body)
          puts "DSL Type: #{body['type']}"
          puts JSON.pretty_generate(body['data'])

          response
        end
      end
    end
  end
end
