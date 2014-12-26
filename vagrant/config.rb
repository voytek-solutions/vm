require 'json'

def getConfig
	@localConfig ||= begin
		fileName = configFile()
		JSON.parse(readfile(fileName), :symbolize_names => true)
	rescue
		localConfig = Hash.new
		localConfig[:git_checkout] = 0

		getInput("How many cores?", localConfig, :cores, 1)
		getInput("How much memory?", localConfig, :memory, 512)
		getInputNumber("Port Offset?", localConfig, :portOffset, 4000)

		# Find out if there is 'vagrant_rsa' key available.
		keyFile = File.exists?("~/.ssh/vagrant_rsa") ? "~/.ssh/vagrant_rsa" : "~/.ssh/id_rsa"
		getInput("Which ssh key to use?", localConfig, :sshKey, keyFile)

		getInput("Set the codebase location", localConfig, :code_dashboard, "~/workspace/dashboard")
		getYesNo("Do you want to copy ~/.gitconfig?", localConfig, :git_config, 'y')
		getYesNo("Do you want to copy ~/.vimrc?", localConfig, :vim_config, 'y')

		file = File.open(fileName,'w')
		file.write(JSON.dump(localConfig))
		file.close

		localConfig
	end
end

# Read a file, returning nil if it doesn't exist
def readfile(filename)
	filename = File.expand_path(filename, File.dirname(__FILE__))
	File.read(filename)
rescue
	nil
end

def getInput(prompt, config, key, default=nil)
	prompt = "#{prompt} [#{default}]" if default
	print "#{prompt}: "
	input = STDIN.gets.strip
	if input.empty? and default
		input = default
	elsif input.empty?
		raise "Field is required, try again"
	end
	config[key] = input
end

def getInputNumber(prompt, config, key, default=nil)
	prompt = "#{prompt} [#{default}]" if default
	print "#{prompt}: "
	input = STDIN.gets.strip
	if input.empty? and default
		input = default
	elsif input.empty?
		raise "Field is required, try again"
	end
	config[key] = input.to_i
end

def getYesNo(prompt, config, key, default = nil)
	yesNo = nil
	while yesNo.nil?
		if default == 'y'
			print "#{prompt} [Y/n]: "
		elsif default == 'n'
			print "#{prompt} [y/N]: "
		else
			print "#{prompt} [y/n]: "
		end

		response = STDIN.gets.downcase
		if response.strip == ''
			response = default
		end

		if response.strip == 'y'
			yesNo = true
		elsif response.strip == 'n'
			yesNo = false
		else
			print "\nPlease Enter y or n\n"
		end
	end

	config[key] = yesNo
end

##
# return full path for
def location(dir)
	dir = File.expand_path(dir)
	if !File.directory? dir
		FileUtils::mkpath(dir)
	end
	return dir
end
