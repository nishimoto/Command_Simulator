def convert_file_to_hash(filename)
	header, *arr = CSV.read(filename)
	hash = Hash.new()

	arr.each do |line_split_arr|
		command, result, set_config, need_config = line_split_arr
		hash[command] ||= Array.new()
		conf_hash = Hash.new()
		conf_hash[:need_config] = need_config
		conf_hash[:set_config]  = set_config
		conf_hash[:result]      = result
		hash[command].push(conf_hash)
	end

	return [header, hash]
end

def select_simulate_number(master_master_file_name)
	print "シュミレートしたい号機を選択してください\n"
	File.open(master_master_file_name,"r").each do |line|
		print convert_line(line)
	end

	input = Readline.readline("> ", true)
	if hash[input]
		return hash[input]
	else
		print "そんな番号無いので、もう一回選んでください\n"
	end
end

def sort_by_config_length(array)
	array.sort {|hash1, hash2| hash2[:need_config].length <=> hash1[:need_config].length }
end

def eval_extend(str)
	return true if str == ""
	return true if str.nil?
	return eval(str)
end

require "readline"
require "csv"
require "pry"

# master_file_name = select_simulate_number(master_master_file_name)
master_file_name = ARGV[0]

# main関数
header, hash = convert_file_to_hash(master_file_name)

# Global_Configを決める
# プロンプトとか、シュミレートされてない文字が入力されたときのエラー文とかを決める
# ちなみに今のところ@promptと@default_miss_resultしか変数いらない
eval(header[0])

binding.pry

# コマンドシュミレート部分
input = ""
while input != "exit"
	input = Readline.readline("#{@prompt} ", true)
	# exitの場合は抜ける,空の場合はループnext
	break if input == "exit"
	next if input == ""

	if hash[input]
		sort_by_config_length(hash[input]).each do |hash2|
			if eval_extend(hash2[:need_config])
				print hash2[:result]
				print "\n"
				eval(hash2[:set_config])
				break
			end
		end
	else
		print @default_error_output
		print "\n"
	end
end

