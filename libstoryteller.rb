
class Storyteller
  def initialize(path, debug = false)
    @data = {}
    @variables = {}
    @path = path
    @debug = debug
    @cursor = ""
    @scenes = []
    @endscene = false
    #@host = host
    self.refresh
  end

  def ended?
    @endscene
  end
  
  def output ln
    puts ln
  end

  def waitForInput
    puts("---")
    choices = []
    for maybe in @data[@cursor][:choices]
      line = maybe[:body]
      if line.start_with? "?any "
        check = line.split("then")[0][5..-1].strip
        allgood = false
        for ic in check.split(" and ")
          if self.checkif ic.strip
            allgood = true
          end
        end
        if allgood
          choices.append({body: line.split("then")[1].strip, cmd: maybe[:cmd] })
        end
      elsif line.start_with? "?all "
        check = line.split("then")[0][5..-1].strip
        allgood = true
        for ic in check.split(" and ")
          if not self.checkif ic.strip
            allgood = false
          end
        end
 
        if allgood
          choices.append({body: line.split("then")[1].strip, cmd: maybe[:cmd] })
        end
        
      elsif line.start_with? "?"
        check = line.split("then")[0][1..-1].strip

        if self.checkif check
          choices.append({body: line.split("then")[1].strip, cmd: maybe[:cmd] })
        end
      else
        choices.append maybe        
      end


    end
    i = 0
    for opt in choices
      self.output "#{i}. #{opt[:body]}"
      i += 1
    end

    print "> "
    todo = gets.chomp

    if todo.is_i?
      for c in choices[todo.to_i][:cmd].split(";")
        self.processCmdLn c
      end
      #gets
      return
    end
    for item in choices
      if item[:body].to_s.downcase.include? (todo.downcase)
        for c in item[:cmd].split(";")
          self.processCmdLn c.strip
        end
        #gets
        return
      end
    end
  end

  def checkif(line)
    var = ""
    if line.start_with? "random" then
      srand
      rs = line.split(",")[1].to_i
      re = line.split(",")[2].to_i
      var = rand(rs..re)
    else
      var = self.getv(line.split(" ")[0])      
    end

    ch = line.split(" ")[1]
    val = line.split(" ")[2]
    if val.start_with? "$"
      val = self.getv(val.sub!("$", ""))
    end

    if val == "nil" or val == "null" or val == "none"
      val = nil
    end

    case ch
    when "under", "<"
      if var.to_i < val.to_i
        return true
      end
    when "over", ">"
      if var.to_i > val.to_i
        return true
      end
    when "<="
      if var.to_i <= val.to_i
        return true
      end
    when ">="
      if var.to_i >= val.to_i
        return true
      end
    when "is", "=", "=="
      ##puts "#{var} == #{val}"
      if var == val
        return true
      end
    when "isnt", "not", "!="
      if var != val
        return true
      end
    end
    return false
  end
  
  def processCmdLn(line)
    line = line.strip
    self.dbg "Command: "+line
    if line.start_with? "set variable" or line.start_with? "set var " then
      d = line.split(" ")[2..-1]
      key = d[0]
      val = d[1]
      @variables[key] = val
      self.dbg "Set: #{key} #{val}"
    elsif line.start_with? "if" then
      l = line.split("then")[0].split(" ")[1..-1].join(" ").strip
      c = line.split("then")[1].strip
      if self.checkif(l) then self.processCmdLn(c) end
    elsif line.start_with? "any" then
      l = line.split("then")[0][4..-1]
      allgood = false
      for ic in l.split(" and ")
        if self.checkif(ic.strip)
          allgood = true
        end
      end
      c = line.split("then")[1].strip
      if allgood then self.processCmdLn(c) end
    elsif line.start_with? "all" then
      l = line.split("then")[0][4..-1]
      allgood = true
      for ic in l.split(" and ")
        if not self.checkif(ic.strip)
          allgood = false
        end
      end
      c = line.split("then")[1].strip
      if allgood then self.processCmdLn(c) end
    elsif line.start_with? "output" then
      self.output self.insertVars(line.split(" ")[1..-1].join(" "))
    elsif line == "end" then
        @endscene = true
    elsif line.start_with? "goto" then
      f = @cursor.split(".")[0]
      @cursor = "#{f}.#{line.split(' ')[1..-1].join(' ')}"
    elsif line.start_with? "move to" then
      @cursor = "#{line.split(' ')[2]}.start"
    elsif line.start_with? "input" then
      #puts "Wait for input.... #{line.split(" ")[1]}"
      print("?>")
      @variables[line.split(" ")[1]] = gets.chomp
    end
  end

  def cursor
    @cursor
  end
  def cursor=(c)
    @cursor = c
  end

  def insertVars(ln)
    s = ln.dup
    @variables.each do |key, var|
      if s.include? "$#{key}"
        s.gsub!("$#{key}", @variables[key])
      end
    end

    return s
  end
  
  def doScene
    #self.dbg "Processing..."
    #@cursor = "#{d}.start"
    sc = @data[@cursor]
    #puts sc
    if sc == nil
      @endscene = true
      self.output "Scene #{@cursor} invalid, exiting."
      return
    end
    for line in sc[:text]
      if line.start_with? ":"
        self.processCmdLn line[1..-1]
      elsif line != "\n" and line != ""
        self.output self.insertVars(line)
      end
    end
    self.waitForInput
  end
  
  def dbg(ln)
    if @debug then
      puts "[DEBUG] "+ln
    end
  end

  def getBlock(scene, block="start")
    @data["#{scene}.#{block}"]
  end

  def setv(key, val)
    @variables[key] = val
  end

  def getv(key)
    @variables[key]
  end

  def focus(scene)
    @cursor = "#{scene}.start"
    @endscene = false
  end
  def tags(scene)
    @data["#{scene}._tags"]
  end
  
  def tagged(tag)
    valid = []
    for scene in @scenes
      s = self.tags scene
      if s.include? tag
        valid.append scene
      end
    end
    return valid
  end
  def hastags(*tag)
    valid = []
    for scene in @scenes
      s = self.tags scene
      
      if s != nil and s.contains_all? tag
        valid.append scene
      end
    end
    return valid
  end  
  def parseFile(file)
    inblock = ""
    arr = IO.readlines(@path+file)
    self.dbg "Parsing lines in file..."
    for fullln in arr
      line = fullln.strip
      if inblock == "" then
        if line.start_with? "#tags"
          @data["#{file.split('.')[0]}._tags"] = []
          for t in line.split(" ")[1..-1]
            @data["#{file.split('.')[0]}._tags"].append t
          end
        end
        if line.end_with? "{" then
          inblock = "#{file.split('.')[0]}.#{line[0..-2]}"
          @data[inblock] = {text: [], choices: []}
          self.dbg "Entering block "+inblock
        end          
      else
        if line.strip.start_with? "-" or line.strip.start_with? "*" then
          @data[inblock][:choices].append ({
            body: line.strip()[1..-1].split(">")[0].strip(),
            cmd: line.strip()[1..-1].split(">")[1].strip()
          })
          self.dbg "Choice added #{line.strip[1..-1].strip()}"
        elsif line.strip.start_with? "?" then
          check = line.split("then")[0][1..-1].strip
          cmd = line.split("then")[1].strip
          puts "Checking :#{check}: for :#{cmd}:"

          if self.checkif check
           @data[inblock][:choices].append ({
             body: cmd.strip().split(">")[0].strip(),
             cmd: cmd.strip().split(">")[1].strip()
           })           
          end

          self.dbg "Choice added #{line.strip[1..-1].strip()}"
        elsif line == "}" then
          inblock = ""
        else
          @data[inblock][:text].append line
        end
      end
    end
  end
  
  def refresh
    Dir.foreach(@path) do |entry|
      if entry.end_with? ".scene"
        self.dbg "Entering #{entry.split('.')[0]}"
        @scenes.append entry.split('.')[0]
        self.parseFile entry
      end
    end
  end
end
