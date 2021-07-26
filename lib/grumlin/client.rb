# frozen_string_literal: true

module Grumlin
  class Client
    def initialize(url, task: Async::Task.current)
      @task = task
      @transport = Transport.new(url)
      reset!
    end

    def connect
      response_queue = @transport.connect
      @request_dispatcher = RequestDispatcher.new
      @task.async { response_task(response_queue) }
    end

    def disconnect
      @transport.disconnect
      reset!
    end

    def requests
      @request_dispatcher.requests
    end

    # TODO: support yielding
    def write(*args, request_id: SecureRandom.uuid)
      request = to_query(request_id, args)
      @transport.write(request)
      begin
        msg, response = @request_dispatcher.add_request(request).wait
        return response.flat_map { |item| Typing.cast(item) } if msg == :result

        raise response
      rescue Async::Stop
        retry if ongoing_request?(request_id)
        raise UnknownRequestStoppedError, "#{request_id} is not in the ongoing requests list"
      end
    end

    def inspect
      "<#{self.class} url=#{@transport.url}>"
    end

    alias to_s inspect

    private

    def to_query(request_id, message)
      {
        requestId: request_id,
        op: "bytecode",
        processor: "traversal",
        args: {
          gremlin: Typing.to_bytecode(Translator.to_bytecode_query(message)),
          aliases: { g: :g }
        }
      }
    end

    def reset!
      @request_dispatcher = nil
      @response_queue = nil
    end

    def response_task(queue)
      queue.each do |response|
        @request_dispatcher.add_response(response)
      end
    end

    def ongoing_request?(request_id)
      @request_dispatcher.requests.key?(request_id)
    end
  end
end
