class_name WebOnly;
extends Node;

const JS_FUNCTION_DOWNLOAD_FILE = """
	const blob = new Blob(['$content'], { type: "text/plain" });
	const url = URL.createObjectURL(blob);
	const a = document.createElement("a");
	a.href = url;
	a.download = '$filename';
	a.click();
	URL.revokeObjectURL(url);
"""

static func download_file(file_name: String, file_content: String):
	var evaluation = JS_FUNCTION_DOWNLOAD_FILE.replace("$filename", file_name).replace("$content", file_content);
	JavaScriptBridge.eval(evaluation);
