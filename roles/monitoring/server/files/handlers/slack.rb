#!/usr/bin/env ruby
require 'sensu-handler'
require 'json'

class Slack < Sensu::Handler
  class Notification
    def initialize(event)
      @event = event
    end

    def text
      "[#{client_name}] #{check_name} is #{check_status}."
    end

    private
      attr_reader :event

      def client_name
        event["client"]["name"]
      end

      def check_name
        event["check"]["name"]
      end

      def check_status
        case event["check"]["status"]
        when 0 then "OK"
        when 1 then "WARNING"
        when 2 then "CRITICAL"
        else        "UNKNOWN"
        end
      end
  end

  class Integration
    HOST = "hooks.slack.com"
    PORT = 443

    def initialize(token: nil, username: nil, icon: nil)
      @token, @username, @icon = token, username, icon
    end

    def post(message)
      connect do |connection|
        connection.post(path, "payload=" + payload_for(message))
      end
    end

    private
      attr_reader :token, :username, :icon

      def connect(&block)
        Net::HTTP.start(HOST, PORT, use_ssl: true, &block)
      end

      def path
        "/services/#{token}"
      end

      def payload_for(message)
        JSON.generate \
          username: username,
          icon_emoji: icon,
          text: message.text
      end
  end

  def handle
    integration.post(notification)
  end

  private
    def notification
      Notification.new(@event)
    end

    def integration
      Integration.new(token: settings["slack"]["token"], username: 'sensu', icon: ':rotating_light:')
    end
end
