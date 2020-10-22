$datadir = ARGV[0]
require_relative $datadir+"/libkaiser"
require_relative $datadir+"/libstoryteller"
$stage = ""
$day = 0
$week = 0
$month = 0
$year = 0
$jobs = {}
$sceneManager = nil
ARGV.delete(ARGV[0])

def figlet(s)
  system("figlet -c -k '"+s+"'")
end

class Player
  def initialize
    @job = nil
    @gender = ""
    @age = 0
    @name = ""
    @money = 1000   
  end

  attr_accessor :name
  attr_accessor :job
  attr_accessor :money
  attr_accessor :age
  attr_accessor :gender
end

$p = Player.new

class Event
  def dothis
    puts "Default nothing."
  end
  
  def to_s
    "Default Generic Event"
  end
end

class Job < Event
  def dothis
    case $p.job # add a default case for custom jobs added by extensions
    when :office
      puts "Office work."
    else
      puts "Custom job...?"
    end
  end
  
  def to_s
    "Job"
  end
end

class JobCenter < Event 
  def to_s
    "Job Center"
  end
end

class Shopping < Event 
  def to_s
    "Shopping"
  end
end

class Club < Event 
  def to_s
    "Club"
  end
end

class Wait < Event 
  def dothis
    puts "You do nothing, time passes."
  end
  def to_s
    "Wait"
  end
end

$options = {
  morning: [Wait.new],
  daytime: [JobCenter.new, Shopping.new, Wait.new],
  evening: [Club.new, Wait.new],
  night:  [Wait.new]
}


def parseScene(name) #Handle idea of script files syntax to automatically handle arbitrary scenes
end

def dosomething
  for item in $options[$stage]
    puts "* #{item}"
  end
  print "What do you do? "
  todo = gets.chomp

  if todo == ".me"
    puts "#{$p.name} (#{$p.age} yr old #{$p.gender})"
    dosomething
  end
  if todo.is_i?
    $options[$stage][todo.to_i].dothis
    print "Press enter to continue..."
    gets
    return
  end
  for item in $options[$stage]
    if item.to_s.downcase == todo.downcase
      item.dothis
      print "Press enter to continue..."
      gets
      return
    end
  end

  puts "What?"
  dosomething
end

def planning
  $stage = :morning
  figlet "MORNING"
  puts "You wake up. You can..."
  
  dosomething
  
  $stage = :daytime
  figlet "DAYTIME"
  puts "Today, you can..."
  dosomething

  $stage = :evening
  figlet "EVENING"
  puts "It's evening. You can..."
  dosomething

  $stage = :night
  figlet "NIGHT"
  puts "It's late night. You can..."
  dosomething
  
  #TODO handle day incrementing
  planning
end

def main
  $sceneManager = Storyteller.new $datadir+"/stscenes/"
  puts $sceneManager.tagged "test"
  $sceneManager.cursor = "createwwcharacter.start"
  while not $sceneManager.ended?
    $sceneManager.doScene
  end
  $p.name = $sceneManager.getv("name")
  $p.age = $sceneManager.getv("age")
  $p.gender = $sceneManager.getv("gender")
  planning
end
main
