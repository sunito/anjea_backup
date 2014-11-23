class NoIniFileError < StandardError
end

def is_head? line
  match_data = /(\[)([\w-]*)(\])/.match line
  match_data
end

def get_category line
  match_data = /(\[)([\w-]*)(\])/.match line
  match_data.captures[1]
end

def get_kv line
  match_data = /([A-Za-z0-9]*) *= *([A-Za-z0-9\/ .\-_]*)/.match line
  match_data.captures
end

def read_ini_file filename
  ini_objs = []
  begin
    file_contents = File.readlines(filename)
  rescue Errno::ENOENT  
    raise NoIniFileError, "#{filename} config file error"
  end
  ini_obj = {}
  file_contents.each do |line|
    next if(line.strip.empty? || line.start_with?("#"))
    if is_head? line
      ini_objs << ini_obj if !ini_obj.empty?
      ini_obj = {}
      ini_obj[:name] = get_category line
      next
    end
    kv = get_kv line
    ini_obj[kv[0]] = kv[1]
  end
  ini_objs << ini_obj
  ini_objs
end

