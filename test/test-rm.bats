#!/usr/bin/env bats

# Directory for testing

setup(){

	# get the containing directory of this file
	DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd)"
	# get the parent dir
	DIR=$(dirname "$DIR")
	# make executable rmSecure/ visible to PATH
	PATH="$DIR:$PATH" 

	# temp trash directory
	export sauvegarde_rm=$(mktemp -d /tmp/rm_saved.XXXXXX)
	mkdir -p "$sauvegarde_rm"

}

# Cleanup after tests
teardown() {
	/bin/rm -rf "$sauvegarde_rm"
# 	run /bin/rm -rf 20*
}

# Load the rm secure function
load_rm_function() {
	source rm-secure.sh
}

# date of the deleted file format YYYY_MM_DD_XXhXXm
date_file() {
	echo $(date +%Y_%m_%d_%Hh%Mm)
}

@test "trash folder is created if it doesn't exist" {
	load_rm_function
	# test if folder exist
	[ -d "$sauvegarde_rm" ]
}

@test "File is moved to trash" {
	load_rm_function

	echo "trash dir : $sauvegarde_rm"
	run echo "Hello World!" >> testfile.txt

	run rm testfile.txt && snap=$(date_file)
	[ $status -eq 0 ]
	# test file exist
 [ -e  "${sauvegarde_rm}/${snap}_testfile.txt" ]

}

@test "File is listed in the trash" {
	load_rm_function
	echo "file deleted">> testfile.txt
	run rm testfile.txt && snap=$(date_file) 
	[ $status -eq 0 ]

	# list files in the trash
	run rm -l
	[ $status -eq 0 ]

	# get the deleted file_name
	file_name=(${snap}_testfile.txt) 
	# check if file_name is in the list of files in the trash
	echo "$output" | grep -q "$file_name"
	[ $? -eq 0 ]

}

@test "File is restored from the trash" {
	load_rm_function
	local testfile="2024_11_28_02h26m_testfile.txt"
	touch "${sauvegarde_rm}$testfile"
	[ -f "${sauvegarde_rm}$testfile" ]

	# restore file
	run rm -s "$testfile" 
	[ $status -eq 0 ]

	# check if file was restored
	[ -e "$testfile" ]

}

@test "no matching file to restore" {
	# should return an error
	run rm -s non_non_existent_file.txt
	[ "$status" -ne 0 ]
	# no file should be restored
	[ ! -e "./non_non_existent_file.txt" ]

}

@test "multiple matching files" {
	load_rm_function
	# test files
	local one_testfile="2005_11_28_05h55m_testfile1.txt"
	local two_testfile="2011_11_28_07h05m_testfile2.txt"

	# put files in trash directory
	run touch "${sauvegarde_rm}${one_testfile}"
	run touch "${sauvegarde_rm}${two_testfile}"

	# restore file(s)
	run rm -s testfile1.txt testfile2.txt
	[ $status -eq 0 ]
	

	# check if the files are moved from the trash
	[ ! -e "${sauvegarde_rm}${one_testfile}" ]  
	[ ! -e "${sauvegarde_rm}${two_testfile}" ]

	#  check files are restored
	[ -e "$one_testfile" ]  
	[ -e "$two_testfile" ]

}

@test "Trash is emptied with e option" {
	load_rm_function
	# put files in the trash
	echo "Hello, World rm-secure">>"${sauvegarde_rm}hello.txt"
	local one_testfile="2005_11_28_05h55m_testfile1.txt"
	local two_testfile="2011_11_28_07h05m_testfile2.txt"
	run touch "${sauvegarde_rm}${one_testfile}"
	run touch "${sauvegarde_rm}${two_testfile}"

	# empty trash
	run rm -e
	# test no output don't count . and .. directory
	[ ! "$(ls -A ${sauvegarde_rm})" ]

}

# @test "Files older than retention period are deleted" {
# 	load_rm_function
# 	echo "expire">>testfile.txt
# 	# delete
# 	rm testfile.txt && snap=$(date_file) 
# 	# get the deleted file
# 	file_name=(${snap}_testfile.txt) 

# 	sleep 2 # to simulate retention period

# 	find "$sauvegarde_rm" -type f -mtime +0 -exec /bin/rm -rf {} \;
# 	# check if deleted
# 	[ ! -f "${sauvegarde_rm}${file_name}" ]
# }
