// Step1.打った行を取得する
function get_Command () {
	var all = document.getElementById('step1.1');
	var prompt = document.getElementsByClassName('step1.2');

	var arr = all.split("\n")
	var command_line_arr = [];
	for (var i = 0; i < arr.length-1; i++) {
		if (arr[i].indexOf(prompt) == 0) {
			command_line_arr.prototype.push(arr[i]);
		}
	};

	var step2 = document.getElementById('step2');
	for (var i = 0; i < command_line_arr.length-1; i++) {
		step2.なんとか += command_line_arr[i]+"\n"
	};
}

// Step2.previewを作成する
function make_preview () {
	var all = document.getElementById('step1.1');
	var command_lines = document.getElementById('step2');
	var command_line_arr = command_lines.split("\n")

	

	var step2 = document.getElementById('step2');
	for (var i = 0; i < command_line_arr.length-1; i++) {
		step2.なんとか += command_line_arr[i]+"\n"
	};
}
