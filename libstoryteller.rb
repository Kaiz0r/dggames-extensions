
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
    choices = @data[@cursor][:choices]
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
  
  def processCmdLn(line)
    line = line.strip
    self.dbg "Command: "+line
    if line.start_with? "set variable" or line.start_with? "set var " then
      d = line.split(" ")[2..-1]
      key = d[0]
      val = d[1]
      @variables[key] = val
      self.dbg "Set: #{key} #{val}"
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
      else
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
       #if line.start_with? ":" then #command - MOVE THIS, dont process commands at this part, process during the runtime when its used
       ## self.processCmdLn(line[1..-1])
       # els
        if line.strip.start_with? "-" or line.strip.start_with? "*" then
          @data[inblock][:choices].append ({
            body: line.strip()[1..-1].split(">")[0].strip(),
            cmd: line.strip()[1..-1].split(">")[1].strip()
          })
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
