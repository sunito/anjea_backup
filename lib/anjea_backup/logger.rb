module AnjeaBackup
  module Logger
    def now_with_minutes
      DateTime.now.strftime("%Y-%m-%d-%H-%M")
    end

    def log item, msg
      if item
        puts "[#{item.name}] #{now_with_minutes} - #{msg}"
      else
        puts "#{now_with_minutes} - #{msg}"
      end
    end
  end
end

