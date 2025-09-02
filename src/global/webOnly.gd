class_name WebOnly;
extends Node;

static func upload_file():
	var uploader = FileUploader.new();
	uploader.upload_file();

static func download_file(file_name: String, file_content: PackedByteArray):
	var downloader = FileDownloader.new();
	downloader.download_file(file_name, file_content);
