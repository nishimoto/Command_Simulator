#!/usr/bin/ruby
def indexing(arr)
	last = arr.length-1
	arr2 = (0..last).to_a
	tarr = [arr.reverse, arr2.reverse].transpose
	Hash[*tarr.flatten]
end

def text_to_arr_2d(all_str, command_list)
	arr = []
	command = ""
	temp_arr = []

	all_str.split("\n").each do |line|
		if command_list[line]
			if temp_arr.length > 0 || command != ""
				arr.push([command, temp_arr.join("\n")])
				command = line
				temp_arr = []
			else
				command = line
			end
		else
			temp_arr.push(line)
		end
	end

	arr.push([command, temp_arr.join("\n")])

	return arr
end

def exclude_prompt(command,prompt)
	return command[prompt.length..-1]
end

def exclude_all_prompt(arr_2d)
	arr_2d.each do |arr|
		prompt = extract_prompt(arr[0])
		arr[0] = exclude_prompt(arr[0],prompt)
	end
	return arr_2d
end

def extract_prompt(command)
	$prompt_list.each do |prompt|
		if command.index(prompt) == 0
			return prompt
		end
	end
end

def suggest_setconf(arr_2d)
	# 前と比較してプロンプトが変化している場合 => beforeにflagが立つ
	arr_2d.each_cons(2) do |before_arr, after_arr|
		before_command = before_arr[0]
		after_command  = after_arr[0]

		before_prompt  = extract_prompt(before_command)
		after_prompt   = extract_prompt(after_command)

		if before_prompt != after_prompt
			before_arr.push("@prompt = '#{after_prompt}'; @#{exclude_prompt(before_command,before_prompt)}_flag = true")
		else
			before_arr.push("")
		end
	end

	# 最後のafter_arrはどうしようもないので自分で追加しておきますね…
	arr_2d[-1].push("")
	return arr_2d
end

def suggest_needconf(arr_2d)

	flag = false
	flagname = "_flag"

	default_prompt = extract_prompt(arr_2d[0][0])

	arr_2d.each do |arr|
		command, result, setconf = arr

		if flag
			arr.push("@#{flagname}")
		end

		if setconf.length > 0
			eval setconf
			prompt = extract_prompt(command)
			if @prompt != default_prompt
				flag = true
				flagname = "#{exclude_prompt(command, prompt)}_flag"
			else
				flag = false
				flagname = "_flag"
			end
		end
	end
end



############################################################
############################################################
############################################################

require "cgi"
require "csv"
require "pry"

cgi = CGI.new

# 準備
all_str = cgi["step1_1"]
# testdata
# all_str = <<EOS
# > ls
# aaa.txt bbb.txt ccc.txt
# ddd.txt eee.txt fff.txt
# > cli
# OK,I'll Change to cli mode
# # set date Time.zone.now
# OK!!
# EOS

# 実際はHTMLから取得だが、テストデータで。
command_list = cgi["step2"].split("\n")
# command_list = ["> ls", "> cli", "# set date Time.zone.now"]

# 実際はry
$prompt_list = cgi["step1_2"].split("\n")
# $prompt_list = ["> ", "# "]

command_list_indexed = indexing(command_list)

# 1行1行になっているのを,コマンドラインの行、結果の行にわける
# [command, result]
command_line_result = text_to_arr_2d(all_str, command_list_indexed)

# binding.pry

# setconfの追加
# [command, result, set_conf]
# promptが変わった行(の前の方?)に@prompt = "変更後プロンプト"と @command_flag = trueとする。
step1_arr_2d_setconf    = suggest_setconf command_line_result

# binding.pry

# need_confの追加
# promptが変わったあとの行は
# ここだけ上手くいってない気がする
step1_arr_2d_suggested = suggest_needconf step1_arr_2d_setconf

# 最後に、プロンプトを除いた形にする。
step1_arr_2d_suggested = exclude_all_prompt(step1_arr_2d_suggested)

# どうでもいいけど、firstheaderの取得
first_prompt = extract_prompt(command_list[0])

# # 2次元配列の作成
op_file = CSV.open("./data/test.csv","w")
op_file.puts ["@prompt = '#{first_prompt}';"]
step1_arr_2d_suggested.each do |arr|
	op_file.puts arr
end
op_file.close
