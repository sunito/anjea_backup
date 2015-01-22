module AnjeaBackup
  class BackupItem
    attr_accessor :name
    attr_accessor :description
    attr_accessor :src_dir
    attr_accessor :ssh_url
    attr_accessor :ssh_key
  
    def initialize hash
      @name        = hash[:name]
      @description = hash['description']
      @src_dir     = hash['src']
      if hash['host'] && hash['user'] && hash['key']
        @ssh_url = "#{hash['user']}@#{hash['host']}:#{@src_dir}"
        @ssh_key = hash['key']
      end
    end
  end
end
