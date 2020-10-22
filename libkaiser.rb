class CBase
    HEADER = "\033[95m"
	OKBLUE = "\033[94m"
	OKGREEN = "\033[92m"
	WARN = "\033[93m"
	FAIL = "\033[91m"
	BOLD = "\033[1m"
	UDNERLINE = "\033[4m"
	FEND = "\033[0m"
	NC = "\x1b[0m"
end

class Format
    BOLD = "\x1b[1m"
    DIM = "\x1b[2m"
    ITALIC = "\x1b[3m"
    UNDERLINED = "\x1b[4m"
    BLINK = "\x1b[5m"
    REVERSE = "\x1b[7m"
    HIDDEN = "\x1b[8m"
    # Reset part
    RESET = "\x1b[0m"
    RESET_BOLD = "\x1b[21m"
    RESET_DIM = "\x1b[22m"
    RESET_ITALIC = "\x1b[23m"
    RESET_UNDERLINED = "\x1b[24"
    RESET_BLINK = "\x1b[25m"
    RESET_REVERSE = "\x1b[27m"
    RESET_HIDDEN = "\x1b[28m"
end

class Colours
    # Foreground
    F_DEFAULT = "\x1b[39m"
    F_BLACK = "\x1b[30m"
    F_RED = "\x1b[31m"
    F_GREEN = "\x1b[32m"
    F_YELLOW = "\x1b[33m"
    F_BLUE = "\x1b[34m"
    F_MAGENTA = "\x1b[35m"
    F_CYAN = "\x1b[36m"
    F_LIGHTGRAY = "\x1b[37m"
    F_DARKGRAY = "\x1b[90m"
    F_LIGHTRED = "\x1b[91m"
    F_LIGHTGREEN = "\x1b[92m"
    F_LIGHTYELLOW = "\x1b[93m"
    F_LIGHTBLUE = "\x1b[94m"
    F_LIGHTMAGENTA = "\x1b[95m"
    F_LIGHTCYAN = "\x1b[96m"
    F_WHITE = "\x1b[97m"
    # Background
    B_DEFAULT = "\x1b[49m"
    B_BLACK = "\x1b[40m"
    B_RED = "\x1b[41m"
    B_GREEN = "\x1b[42m"
    B_YELLOW = "\x1b[43m"
    B_BLUE = "\x1b[44m"
    B_MAGENTA = "\x1b[45m"
    B_CYAN = "\x1b[46m"
    B_LIGHTGRAY = "\x1b[47m"
    B_DARKGRAY = "\x1b[100m"
    B_LIGHTRED = "\x1b[101m"
    B_LIGHTGREEN = "\x1b[102m"
    B_LIGHTYELLOW = "\x1b[103m"
    B_LIGHTBLUE = "\x1b[104m"
    B_LIGHTMAGENTA = "\x1b[105m"
    B_LIGHTCYAN = "\x1b[106m"
    B_WHITE = "\x1b[107m"
end

class Array
  def to_sentence(options = {})
    default_connectors = {
      :words_connector     => ', ',
      :two_words_connector => ' and ',
      :last_word_connector => ', and '
    }

    options = default_connectors.merge!(options)

    case length
    when 0
      ''
    when 1
      self[0].to_s.dup
    when 2
      "#{self[0]}#{options[:two_words_connector]}#{self[1]}"
    else
      "#{self[0...-1].join(options[:words_connector])}#{options[:last_word_connector]}#{self[-1]}"
    end
  end
end

class String
	def tokenize
		self.
		split(/\s(?=(?:[^'"]|'[^']*'|"[^"]*")*$)/).
		select {|s| not s.empty? }.
		map {|s| s.gsub(/(^ +)|( +$)|(^["']+)|(["']+$)/,'')}
	end
	def greplace from, to
		while self.include? from
			self[from] = to
		end
	end
	def wrap wrapper
		"#{wrapper}#{self}#{wrapper}"
	end
	def valid_float?
		# The double negation turns this into an actual boolean true - if you're 
		# okay with "truthy" values (like 0.0), you can remove it.
		Float(self) rescue false
	end
	def is_i?
		/\A[-+]?\d+\z/ === self
	end
end

class Integer
	def humanize
		num = self.to_s
		if num == "11" then #stupid stupid english language
			"11th"
		elsif num == "12" then #why cant english follow logic pls
			"12th"
		elsif num == "13" then #why are 11 12 and 13 said differently for no arbitrary reason
			"14th"
		elsif num == "0" then #Accounting for 0
			"None"
		elsif num.end_with?("1") then
			"#{num}st"
		elsif num.end_with?("2") then
			"#{num}nd"
		elsif num.end_with?("3") then
			"#{num}rd"
		else
			"#{num}th"
		end
	end

    def percentageOf whole
        (100 * self / whole)
    end
    
	def zerospace
		if self < 10
			"0#{self}"
		else
			self
		end
	end
end

def humanizeInt(num)
	if num.is_a? Integer
		num = num.to_s
	end
	
	if num == "0" then
		"None"
	elsif num.end_with?("1") then
		"#{num}st"
	elsif num.end_with?("2") then
		"#{num}nd"
	elsif num.end_with?("3") then
		"#{num}rd"
	else
		"#{num}th"
	end
end


def printk(message, timestamp: true, tag: '')
	msg = ""
	if timestamp == true
		time = Time.new
		msg << "#{time.day.zerospace}/#{time.month.zerospace}/#{time.year} #{time.hour.zerospace}:#{time.min.zerospace}:#{time.sec.zerospace} | "
	end
	
	case tag
	when "info"
		msg << "[ #{Colours::F_WHITE}INFO#{Format::RESET} ] #{message}"
	when "error"
		msg << "[ #{Colours::F_RED}ERROR#{Format::RESET} ] #{Colours::F_RED}#{message}#{Format::RESET}"
	when "warn"
		msg << "[ #{Colours::F_RED}WARN#{Format::RESET} ] #{message}"
	when "say"
		msg << "[ #{Colours::F_BLUE}SAY#{Format::RESET} ] #{message}"
	else
		msg << "#{message}"
	end
	
	puts msg
end
