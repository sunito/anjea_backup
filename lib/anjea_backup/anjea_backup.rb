require 'date'
require 'fileutils'
require 'pathname'
require_relative 'inifile'

module AnjeaBackup
  class Backup
    include AnjeaBackup::Logger

    def initialize
      read_system_conf
      setup_dirs
      if !lock!
        log_err "Aborting, anjea already running.  Delete #{@lock_file} if not."
        exit 2
      end
      read_backups_conf
    end
  
    def backup
      yyyymmdd = now_with_minutes

      # TODO work in a tmp work dir
      @backup_items.each do |item|
        last_backup  = File.join(@last, item.name)
        today_backup = create_now_backup_path(yyyymmdd, item)
        work_dir     = File.join(@partial, item.name, yyyymmdd)
        FileUtils.mkdir_p work_dir
  
        source = item.ssh_url ? "-e \"ssh -i #{item.ssh_key}\" #{item.ssh_url}"
                              : item.src_dir
  
        rsync_cmd = "rsync -avz "\
          "--delete --relative --stats "\
          "--log-file #{log_file_for(yyyymmdd, item)} "\
          "--link-dest #{last_backup} "\
          "#{source} #{today_backup}"
      
        log item, "rsync start"
        if system(rsync_cmd)
          log item, "rsync finished"
          # 'finish', move partial to backup-dest
          link_last_backup today_backup, last_backup
          log item, "linked"
        else
          # TODO Move this one into quarantaine/incomplete!
          log_err item, "rsync failed?"
        end
      end
      self
    end
  
    def cleanup
      now = DateTime.now
      @backup_items.each do |item|
        puts "[#{item.name}] backups:"
        puts "-- #{item.description} --"
        ages = Dir.glob("#{@destination}/[^c]*/#{item.name}").map do |dir|
          date_dir = Pathname.new(dir).parent.basename.to_s
          dtdiff = 0
          begin
            stamp = DateTime.strptime(date_dir, "%Y-%m-%d-%H")
            dtdiff = now - stamp
          rescue
            STDERR.puts "Do not understand timestamp in #{dir}"
          end
          [dtdiff, dir]
        end
        ages.sort.each do |age,dir|
          puts "(#{(age*24).to_i}) #{dir}"
        end
        puts
      end
    end
  
    def to_vault
    end
  
    private
  
    def setup_dirs
      begin
        FileUtils.mkdir_p @destination if !File.directory? @destination
        FileUtils.mkdir_p @vault       if !File.directory? @vault
        FileUtils.mkdir_p @log         if !File.directory? @log
        FileUtils.mkdir_p @last        if !File.directory? @last
        FileUtils.mkdir_p @partial     if !File.directory? @partial
        FileUtils.mkdir_p @failed      if !File.directory? @failed
      rescue Errno::EACCES => e
        log_err "ERROR: Could not create a needed directory:"
        log_err "#{e.message}"
        log_err "Exiting on error."
        exit 5
      end
    end
  
    def log_err item=nil, msg
      log_msg = (!item.nil?) ? "[#{item.name}] #{now_with_minutes} - #{msg}"
        : "#{now_with_minutes} - #{msg}"
      STDERR.puts log_msg
    end
  
    def lock!
      File.new(@lock_file, 'w').flock(File::LOCK_NB | File::LOCK_EX)
    end
  
    def link_last_backup today_backup, last_backup
      FileUtils.rm_f last_backup
      FileUtils.ln_s(today_backup, last_backup, :force => true)
    end
  
    def read_backups_conf
      @backup_items = read_ini_file('backups.conf').map {|group| BackupItem.new group }
    end
  
    def read_system_conf
      system_conf = read_ini_file 'anjea.conf'
  
      @destination = system_conf[0]['dst']
      @vault       = system_conf[0]['vault']
      @log         = system_conf[0]['log']
      @last        = File.join(@destination, 'current')
      @failed      = File.join(@destination, 'failed')
      @partial     = File.join(@destination, 'partial')
      @lock_file   = system_conf[0]['lock']
      # rescue from malformed config
    end
  
    def log_file_for yyyymmdd, item
      FileUtils.mkdir_p File.join(@log, item.name)
      File.join(@log, item.name, "#{yyyymmdd}.log")
    end
  
    def create_now_backup_path yyyymmdd, item
      today_backup = File.join(@destination, yyyymmdd, item.name)
      FileUtils.mkdir_p today_backup
      today_backup
    end
  
  end
end
