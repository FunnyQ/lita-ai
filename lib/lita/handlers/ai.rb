module Lita
  module Handlers
    class Ai < Handler
      on :unhandled_message, :chat

      def self.cleverbot
        @cleverbot ||= CleverBot.new
      end

      def chat(payload)
        return unless chatting?(payload[:message])
        message = extract_aliases(payload[:message])
        reply = self.class.cleverbot.think(message.body).gsub(/\|([\da-fA-F]{4})/) {|m| [$1].pack("H*").unpack("n*").pack("U*")}
        robot.send_message(message.source, reply)
      end

      private

      def chatting?(message)
        message.command? || message.body =~ /#{aliases.join('|')}/i
      end

      def extract_aliases(message)
        body = message.body.sub(/#{aliases.join('|')}/i, '').strip
        Message.new(robot, body, message.source)
      end

      def aliases
        [robot.mention_name, robot.alias].map{|a| a unless a == ''}.compact
      end

      Lita.register_handler(self)
    end
  end
end
