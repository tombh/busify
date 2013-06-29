class PlannerController < WebsocketRails::BaseController
  def initialize_session
    # perform application setup here
  end

  def plan
    puts message
    # extract from/to from message
    PlannerWorker.perform_async(message) do |msg|
      if msg[Sidekiq::TASK_COMPLETE_SIG]
        send_message :complete, true, :namespace => 'plan'
        puts msg
      else
        puts msg
        send_message :update, msg, :namespace => 'plan'
      end
    end

    puts "outside"
  end
end