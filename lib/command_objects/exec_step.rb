require 'mutations'

module FBPi
  # Excutes a single step in "The Real World(tm)". This command will be called
  # multiple times by a single schedule object when it is executed at a
  # prescribed time.
  class ExecStep < Mutations::Command
    class UnsafeCommand < Exception; end

    required do
      duck :step, methods: [:message_type, :x, :y, :z, :pin, :value, :mode]
      duck :bot, methods: [:commands, :current_position]
    end

    def execute
      start = Time.now
      self.send(message_key)
      finish = Time.now
      puts "Executed #{message_key} after #{(finish - start) * 1000.0} ms"
    rescue UnsafeCommand; unknown
    end

    def message_key
      msg = step.message_type.to_s
      raise UnsafeCommand,
        "Unknown sequence step '#{msg}'" if !Step::COMMANDS.include?(msg)
      raise UnsafeCommand,
        "Step '#{msg}' is allowed, but not yet implemented" if !respond_to?(msg)
      msg
    end

    def move_relative
      bot.commands.move_relative(x: (step.x || 0),
                                 y: (step.y || 0),
                                 z: (step.z || 0))
    end

    def move_absolute
      bot.commands.move_absolute(x: step.x || bot.current_position.x,
                                 y: step.y || bot.current_position.y,
                                 z: step.z || bot.current_position.z)
    end

    def pin_write
      bot.commands.write_pin(pin: step.pin, value: step.value, mode: step.mode)
    end


    def send_message
      SendMessage.run! message: step.value, bot: bot
    end

    def if_statement
      try_sync # Ensure we have latests sequences before calling sub sequences.
      params = {
        lhs:      bot.template_variables[step.variable].to_s,
        rhs:      step.value.to_s,
        operator: step.operator.to_s,
        bot:      bot,
        sequence: Sequence.find_by(id_on_web_app: step.sub_sequence_id)
      }
      IfStatement.run!(params)
    end

    def unknown
      bot.log("Unknown message #{step.message_type}")
    end

    def read_pin
      ReadPin.run!(bot: bot, pin: step.pin)
    end

    def wait
      bot.commands.wait(step.value.to_f.round.to_i)
    end

    # Attempts to grab latest sequences. Doesn't crash if the network is down.
    def try_sync
      begin
        SyncBot.run!(bot: bot)
      rescue
        puts 'WARN: Could not sync sequences.'
      end
    end
  end
end
