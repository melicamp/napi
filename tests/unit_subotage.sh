#!/bin/bash

################################################################################

#  Copyright (C) 2014 Tomasz Wisniewski aka 
#       DAGON <tomasz.wisni3wski@gmail.com>
#
#  http://github.com/dagon666
#  http://pcarduino.blogspot.co.ul
# 
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.

################################################################################

#
# source common unit lib
#
. lib/unit_common.sh

#
# source the code of the original script
#
. "$g_install_path/subotage.sh" 2>&1 > /dev/null

################################################################################

#
# tests env setup
#
oneTimeSetUp() {
	_prepare_env
    cp -rv "$g_assets_path/napi_test_files/subtitles" "$g_assets_path/$g_ut_root/"
}


#
# tests env tear down
#
oneTimeTearDown() {
	_purge_env
}

################################################################################

test_check_format_microdvd() {
	local tmp=$(mktemp test.XXXXXXXX)
	local match=''
	_save_subotage_globs

	echo "junk" > "$tmp"
	echo "{123}{456}first line" >> "$tmp"
	echo "{123}{456}second line" >> "$tmp"

	match=$(check_format_microdvd "$tmp")
	assertEquals "checking the first line" "microdvd 2" "$match"

	echo "junk" > "$tmp"
	echo "junk" >> "$tmp"
	echo "junk" >> "$tmp"
	echo "junk" >> "$tmp"
	match=$(check_format_microdvd "$tmp")
	assertEquals "checking the first line" "not_detected" "$match"

	match=$(check_format_microdvd "$g_assets_path/$g_ut_root/subtitles/1_microdvd.txt")
	assertEquals "checking the first line and fps from real file" "microdvd 1 23.976" "$match"

	match=$(check_format_microdvd "$g_assets_path/$g_ut_root/subtitles/2_microdvd.txt")
	assertEquals "checking the first line" "microdvd 1" "$match"

	match=$(check_format_microdvd "$g_assets_path/$g_ut_root/subtitles/3_microdvd.txt")
	assertEquals "checking the first line" "microdvd 1 23.976" "$match"

	# try with other formats to make sure it doesn't catch any
	match=$(check_format_microdvd "$g_assets_path/$g_ut_root/subtitles/2_newline_subrip.txt")
	assertEquals "checking subrip no detection" "not_detected" "$match"
	match=$(check_format_microdvd "$g_assets_path/$g_ut_root/subtitles/1_tmplayer.txt")
	assertEquals "checking tmplayer no detection" "not_detected" "$match"
	match=$(check_format_microdvd "$g_assets_path/$g_ut_root/subtitles/1_subviewer2.sub")
	assertEquals "checking subviewer2 no detection" "not_detected" "$match"
	match=$(check_format_microdvd "$g_assets_path/$g_ut_root/subtitles/1_mpl2.txt")
	assertEquals "checking mpl2 no detection" "not_detected" "$match"

	unlink "$tmp"
	_restore_subotage_globs
	return 0
}


test_check_format_mpl2() {
	local tmp=$(mktemp test.XXXXXXXX)
	local match=''
	_save_subotage_globs

	echo "junk" > "$tmp"
	echo "[123][456]first line" >> "$tmp"
	echo "[123][456]second line" >> "$tmp"

	match=$(check_format_mpl2 "$tmp")
	assertEquals "checking the first line" "mpl2 2" "$match"

	echo "junk" > "$tmp"
	echo "junk" >> "$tmp"
	echo "junk" >> "$tmp"
	echo "junk" >> "$tmp"
	match=$(check_format_mpl2 "$tmp")
	assertEquals "checking the first line" "not_detected" "$match"

	match=$(check_format_mpl2 "$g_assets_path/$g_ut_root/subtitles/1_mpl2.txt")
	assertEquals "checking the first line and fps from real file" "mpl2 1" "$match"

	match=$(check_format_mpl2 "$g_assets_path/$g_ut_root/subtitles/2_mpl2.txt")
	assertEquals "checking the first line 2_mpl2.txt" "mpl2 1" "$match"

	# try with other formats to make sure it doesn't catch any
	match=$(check_format_mpl2 "$g_assets_path/$g_ut_root/subtitles/2_newline_subrip.txt")
	assertEquals "checking subrip no detection" "not_detected" "$match"
	match=$(check_format_mpl2 "$g_assets_path/$g_ut_root/subtitles/1_tmplayer.txt")
	assertEquals "checking tmplayer no detection" "not_detected" "$match"
	match=$(check_format_mpl2 "$g_assets_path/$g_ut_root/subtitles/1_subviewer2.sub")
	assertEquals "checking subviewer2 no detection" "not_detected" "$match"
	match=$(check_format_mpl2 "$g_assets_path/$g_ut_root/subtitles/1_microdvd.txt")
	assertEquals "checking microdvd no detection" "not_detected" "$match"

	unlink "$tmp"
	_restore_subotage_globs
	return 0

}


test_check_format_subrip() {
	local tmp=$(mktemp test.XXXXXXXX)
	local match=''
	_save_subotage_globs

	echo "junk" > "$tmp"
	echo "junk" >> "$tmp"
	echo "1 00:00:02,123 --> 00:00:12,234" >> "$tmp"
	echo "some subs line" >> "$tmp"

	match=$(check_format_subrip "$tmp")
	assertEquals "checking the first line" "subrip 3 inline" "$match"

	echo "junk" > "$tmp"
	echo "junk" >> "$tmp"
	echo "junk" >> "$tmp"
	echo "junk" >> "$tmp"
	match=$(check_format_subrip "$tmp")
	assertEquals "check not detecting junk" "not_detected" "$match"

	match=$(check_format_subrip "$g_assets_path/$g_ut_root/subtitles/1_inline_subrip.txt")
	assertEquals "checking the first line from real file" "subrip 1 inline" "$match"

	match=$(check_format_subrip "$g_assets_path/$g_ut_root/subtitles/2_newline_subrip.txt")
	assertEquals "checking the first line (newline)" "subrip 1 newline" "$match"

	match=$(check_format_subrip "$g_assets_path/$g_ut_root/subtitles/3_subrip.txt")
	assertEquals "checking the first line (newline)" "subrip 5 newline" "$match"

	# try with other formats to make sure it doesn't catch any
	match=$(check_format_subrip "$g_assets_path/$g_ut_root/subtitles/1_microdvd.txt")
	assertEquals "checking microdvd no detection" "not_detected" "$match"
	match=$(check_format_subrip "$g_assets_path/$g_ut_root/subtitles/1_tmplayer.txt")
	assertEquals "checking tmplayer no detection" "not_detected" "$match"
	match=$(check_format_subrip "$g_assets_path/$g_ut_root/subtitles/1_subviewer2.sub")
	assertEquals "checking subviewer2 no detection" "not_detected" "$match"
	match=$(check_format_subrip "$g_assets_path/$g_ut_root/subtitles/1_mpl2.txt")
	assertEquals "checking mpl2 no detection" "not_detected" "$match"

	unlink "$tmp"
	_restore_subotage_globs
	return 0
}


test_check_format_subviewer2() {
	local tmp=$(mktemp test.XXXXXXXX)
	local match=''
	_save_subotage_globs

	echo "junk" > "$tmp"
	echo "junk" >> "$tmp"
	echo "00:00:02.123,00:00:12.234" >> "$tmp"
	echo "some subs line" >> "$tmp"

	match=$(check_format_subviewer2 "$tmp")
	assertEquals "checking the first line" "subviewer2 3 0" "$match"

	echo "junk" > "$tmp"
	echo "junk" >> "$tmp"
	echo "junk" >> "$tmp"
	echo "junk" >> "$tmp"
	match=$(check_format_subviewer2 "$tmp")
	assertEquals "check not detecting junk" "not_detected" "$match"

	match=$(check_format_subviewer2 "$g_assets_path/$g_ut_root/subtitles/1_subviewer2.sub")
	assertEquals "checking the first line from real file" "subviewer2 11 1" "$match"

	# try with other formats to make sure it doesn't catch any
	match=$(check_format_subviewer2 "$g_assets_path/$g_ut_root/subtitles/1_microdvd.txt")
	assertEquals "checking microdvd no detection" "not_detected" "$match"
	match=$(check_format_subviewer2 "$g_assets_path/$g_ut_root/subtitles/1_tmplayer.txt")
	assertEquals "checking tmplayer no detection" "not_detected" "$match"
	match=$(check_format_subviewer2 "$g_assets_path/$g_ut_root/subtitles/1_inline_subrip.txt")
	assertEquals "checking subrip no detection" "not_detected" "$match"
	match=$(check_format_subviewer2 "$g_assets_path/$g_ut_root/subtitles/2_newline_subrip.txt")
	assertEquals "checking subrip newline no detection" "not_detected" "$match"
	match=$(check_format_subviewer2 "$g_assets_path/$g_ut_root/subtitles/1_mpl2.txt")
	assertEquals "checking mpl2 no detection" "not_detected" "$match"

	unlink "$tmp"
	_restore_subotage_globs
	return 0

}

test_check_format_tmplayer() {
	local tmp=$(mktemp test.XXXXXXXX)
	local match=''
	_save_subotage_globs

	echo "junk" > "$tmp"
	echo "junk" >> "$tmp"
	echo "00:00:02=line of subs" >> "$tmp"
	echo "00:02:02=line of subs" >> "$tmp"

	match=$(check_format_tmplayer "$tmp")
	assertEquals "checking the first line" "tmplayer 3 2 0 =" "$match"

	echo "junk" > "$tmp"
	echo "junk" >> "$tmp"
	echo "0:00:02:line of subs" >> "$tmp"
	echo "0:02:02:line of subs" >> "$tmp"

	match=$(check_format_tmplayer "$tmp")
	assertEquals "checking the first line" "tmplayer 3 1 0 :" "$match"

	echo "junk" > "$tmp"
	echo "junk" >> "$tmp"
	echo "junk" >> "$tmp"
	echo "junk" >> "$tmp"
	match=$(check_format_tmplayer "$tmp")
	assertEquals "check not detecting junk" "not_detected" "$match"

	match=$(check_format_tmplayer "$g_assets_path/$g_ut_root/subtitles/1_tmplayer.txt")
	assertEquals "checking the first line from real file" "tmplayer 1 2 0 :" "$match"

	match=$(check_format_tmplayer "$g_assets_path/$g_ut_root/subtitles/2_tmplayer.txt")
	assertEquals "checking the first line from real file" "tmplayer 1 1 0 :" "$match"

	match=$(check_format_tmplayer "$g_assets_path/$g_ut_root/subtitles/3_tmplayer.txt")
	assertEquals "checking the first line from real file" "tmplayer 1 2 1 :" "$match"

	match=$(check_format_tmplayer "$g_assets_path/$g_ut_root/subtitles/4_tmplayer.txt")
	assertEquals "checking the first line from real file" "tmplayer 1 2 1 =" "$match"

	# # try with other formats to make sure it doesn't catch any
	match=$(check_format_tmplayer "$g_assets_path/$g_ut_root/subtitles/1_microdvd.txt")
	assertEquals "checking microdvd no detection" "not_detected" "$match"
	match=$(check_format_tmplayer "$g_assets_path/$g_ut_root/subtitles/1_inline_subrip.txt")
	assertEquals "checking subrip no detection" "not_detected" "$match"
	match=$(check_format_tmplayer "$g_assets_path/$g_ut_root/subtitles/1_mpl2.txt")
	assertEquals "checking mpl2 no detection" "not_detected" "$match"

	# not checking subviewer2 and newline subrip
	# because I know that this detector conflict with those
	# that's why it is being placed as last

	unlink "$tmp"
	_restore_subotage_globs
	return 0
}


test_read_format_subviewer2() {
	local tmp=$(mktemp test.XXXXXXXX)
	local out=$(mktemp output.XXXXXXXX)
	local data=''
	declare -a adata=()
	_save_subotage_globs

	echo "00:00:02.123,00:00:12.234" > "$tmp"
	echo "some subs line" >> "$tmp"
	echo "" >> "$tmp"
	echo "00:00:03.123,00:00:10.234" >> "$tmp"
	echo "some subs line2" >> "$tmp"

	g_inf[$___DETAILS]="subviewer2 1 0"
	read_format_subviewer2 "$tmp" "$out"

	data=$(head -n 1 "$out" | tail -n 1)
	assertEquals 'check for file type' "secs" "$data"

	data=$(head -n 2 "$out" | tail -n 1)
	adata=( $data )
	assertEquals 'check counter' 1 "${adata[0]}"
	assertEquals 'check start_time' "2.123" "${adata[1]}"
	assertEquals 'check end_time' "12.234" "${adata[2]}"
	assertEquals 'check content' "some" "${adata[3]}"

	# now let's try with a real file
	g_inf[$___DETAILS]="subviewer2 11 1"
	read_format_subviewer2 "$g_assets_path/$g_ut_root/subtitles/1_subviewer2.sub" "$out"

	data=$(head -n 2 "$out" | tail -n 1)
	adata=( $data )
	assertEquals 'check counter' 1 "${adata[0]}"
	assertEquals 'check start_time' "60.1" "${adata[1]}"
	assertEquals 'check end_time' "120.2" "${adata[2]}"
	assertEquals 'check content' "Oh," "${adata[3]}"

	unlink "$tmp"
	unlink "$out"
	_restore_subotage_globs
	return 0
}


test_read_format_tmplayer() {
	local tmp=$(mktemp test.XXXXXXXX)
	local out=$(mktemp output.XXXXXXXX)
	local data=''
	declare -a adata=()
	_save_subotage_globs

	echo "00:10:12=line1" > "$tmp"
	echo "00:10:20=line2" >> "$tmp"

	g_inf[$___DETAILS]="tmplayer 1 2 0 ="
	read_format_tmplayer "$tmp" "$out"

	data=$(head -n 1 "$out" | tail -n 1)
	assertEquals 'check for file type' "hms" "$data"

	data=$(head -n 2 "$out" | tail -n 1)
	adata=( $data )
	assertEquals 'check counter' 1 "${adata[0]}"
	assertEquals 'check start_time' "00:10:12" "${adata[1]}"
	assertEquals 'check end_time' "00:10:15" "${adata[2]}"
	assertEquals 'check content' "line1" "${adata[3]}"

	declare -a file_details=( "tmplayer 1 2 0 :" \
		"tmplayer 1 1 0 :" \
		"tmplayer 1 2 1 :" \
		"tmplayer 1 2 1 =" )

	local idx=1

	# now let's try with real files
	for i in "${file_details[@]}"; do
		g_inf[$___DETAILS]="$i"
		read_format_tmplayer "$g_assets_path/$g_ut_root/subtitles/${idx}_tmplayer.txt" "$out"

		data=$(head -n 2 "$out" | tail -n 1)
		adata=( $data )
		assertEquals 'check counter' 1 "${adata[0]}"
		assertEquals 'check start_time' "00:03:46" "${adata[1]}"
		assertEquals 'check end_time' "00:03:49" "${adata[2]}"
		assertEquals 'check content' "Nic.|Od" "${adata[3]}"

		idx=$(( idx + 1 ))
	done

	unlink "$tmp"
	unlink "$out"
	_restore_subotage_globs
	return 0

}


test_read_format_microdvd() {
	local tmp=$(mktemp test.XXXXXXXX)
	local out=$(mktemp output.XXXXXXXX)
	local data=''
	declare -a adata=()
	_save_subotage_globs

	echo "{100}{200}line1" > "$tmp"
	echo "{100}{200}line2" >> "$tmp"

	g_inf[$___DETAILS]="microdvd 1"
	g_inf[$___FPS]="25"
	read_format_microdvd "$tmp" "$out"

	data=$(head -n 1 "$out" | tail -n 1)
	assertEquals 'check for file type' "secs" "$data"

	data=$(head -n 2 "$out" | tail -n 1)
	adata=( $data )
	assertEquals 'check counter' 1 "${adata[0]}"
	assertEquals 'check start_time' "4" "${adata[1]}"
	assertEquals 'check end_time' "8" "${adata[2]}"
	assertEquals 'check content' "line1" "${adata[3]}"

	declare -a file_starts=( "padding" \
		"1" \
		"1219" \
		"1" )

	declare -a file_ends=( "padding" \
		"1" \
		"1421" \
		"72"
			)

	declare -a file_data=( "padding" \
		"23.976" \
		"prawie" \
		"movie"
		)

	g_inf[$___DETAILS]="microdvd 1"

	# now let's try with real files
	for i in {1..3}; do
		g_inf[$___FPS]=1
		read_format_microdvd "$g_assets_path/$g_ut_root/subtitles/${i}_microdvd.txt" "$out"

		data=$(head -n 2 "$out" | tail -n 1 | strip_newline)
		adata=( $data )
		assertEquals 'check counter' 1 "${adata[0]}"
		assertEquals 'check start_time' "${file_starts[$i]}" "${adata[1]}"
		assertEquals 'check end_time' "${file_ends[$i]}" "${adata[2]}"
		assertEquals 'check content' "${file_data[$i]}" "${adata[3]}"
	done

	unlink "$tmp"
	unlink "$out"
	_restore_subotage_globs
	return 0
}


test_read_format_mpl2() {
	local tmp=$(mktemp test.XXXXXXXX)
	local out=$(mktemp output.XXXXXXXX)
	local data=''
	declare -a adata=()
	_save_subotage_globs

	echo "[100][200]line1" > "$tmp"
	echo "[100][200]line2" >> "$tmp"

	g_inf[$___DETAILS]="mpl2 1"
	read_format_mpl2 "$tmp" "$out"

	data=$(head -n 1 "$out" | tail -n 1)
	assertEquals 'check for file type' "secs" "$data"

	data=$(head -n 2 "$out" | tail -n 1)
	adata=( $data )
	assertEquals 'check counter' 1 "${adata[0]}"
	assertEquals 'check start_time' "10" "${adata[1]}"
	assertEquals 'check end_time' "20" "${adata[2]}"
	assertEquals 'check content' "line1" "${adata[3]}"

	declare -a file_starts=( "padding" \
		"100" \
		"46.1" )

	declare -a file_ends=( "padding" \
		"104.8" \
		"51" )

	declare -a file_data=( "padding" \
		"Aktualny" \
		"/Zaledwie" )

	g_inf[$___DETAILS]="mpl2 1"

	# now let's try with real files
	for i in {1..2}; do
		read_format_mpl2 "$g_assets_path/$g_ut_root/subtitles/${i}_mpl2.txt" "$out"

		data=$(head -n 2 "$out" | tail -n 1 | strip_newline)
		adata=( $data )
		assertEquals 'check counter' 1 "${adata[0]}"
		assertEquals 'check start_time' "${file_starts[$i]}" "${adata[1]}"
		assertEquals 'check end_time' "${file_ends[$i]}" "${adata[2]}"
		assertEquals 'check content' "${file_data[$i]}" "${adata[3]}"
	done

	unlink "$tmp"
	unlink "$out"
	_restore_subotage_globs
	return 0
}


test_read_format_subrip() {
	local tmp=$(mktemp test.XXXXXXXX)
	local out=$(mktemp output.XXXXXXXX)
	local data=''
	declare -a adata=()
	_save_subotage_globs

	echo "1 00:00:02,123 --> 00:00:12,234" > "$tmp"
	echo "some subs line" >> "$tmp"

	g_inf[$___DETAILS]="subrip 1 inline"
	read_format_subrip "$tmp" "$out"

	data=$(head -n 1 "$out" | tail -n 1)
	assertEquals 'check for file type' "hmsms" "$data"

	data=$(head -n 2 "$out" | tail -n 1)
	adata=( $data )
	assertEquals 'check counter' 1 "${adata[0]}"
	assertEquals 'check start_time' "00:00:02.123" "${adata[1]}"
	assertEquals 'check end_time' "00:00:12.234" "${adata[2]}"
	assertEquals 'check content' "some" "${adata[3]}"

	# now let's try with real files
	g_inf[$___DETAILS]="subrip 1 inline"
	read_format_subrip "$g_assets_path/$g_ut_root/subtitles/1_inline_subrip.txt" "$out"

	data=$(head -n 2 "$out" | tail -n 1 | strip_newline)
	adata=( $data )
	assertEquals 'inline check counter' 1 "${adata[0]}"
	assertEquals 'inline check start_time' "00:00:49.216" "${adata[1]}"
	assertEquals 'inline check end_time' "00:00:53.720" "${adata[2]}"
	assertEquals 'inline check content' "Panie" "${adata[3]}"

	g_inf[$___DETAILS]="subrip 1 newline"
	read_format_subrip "$g_assets_path/$g_ut_root/subtitles/2_newline_subrip.txt" "$out"

	data=$(head -n 2 "$out" | tail -n 1 | strip_newline)
	adata=( $data )
	assertEquals 'newline check counter' 1 "${adata[0]}"
	assertEquals 'newline check start_time' "00:00:49.216" "${adata[1]}"
	assertEquals 'newline check end_time' "00:00:53.720" "${adata[2]}"
	assertEquals 'newline check content' "Panie" "${adata[3]}"

	g_inf[$___DETAILS]="subrip 5 newline"
	read_format_subrip "$g_assets_path/$g_ut_root/subtitles/3_subrip.txt" "$out"
    
	data=$(head -n 2 "$out" | tail -n 1 | strip_newline)
	adata=( $data )
	assertEquals 'offset check counter' 1 "${adata[0]}"
	assertEquals 'offset check start_time' "00:00:56.556" "${adata[1]}"
	assertEquals 'offset check end_time' "00:01:02.062" "${adata[2]}"
	assertEquals 'offset check content' "Pod" "${adata[3]}"

	unlink "$tmp"
	unlink "$out"
	_restore_subotage_globs
	return 0
}


test_write_format_microdvd() {
	local tmp=$(mktemp tmp.XXXXXXXX)
	local out=$(mktemp out.XXXXXXXX)
	local status=0
	local data=''

	_save_subotage_globs

	echo "junk" > "$tmp"
	echo "junk" >> "$tmp"

	g_outf[$___FPS]=25
	write_format_microdvd "$tmp" "$out" 2>&1 > /dev/null
	status=$?
	assertEquals "checking return value" "$RET_FAIL" "$status"

	echo "secs" > "$tmp"
	echo "1 10 20 line1" >> "$tmp"
	echo "2 22 25 line2" >> "$tmp"

	write_format_microdvd "$tmp" "$out"
	status=$?
	assertEquals "checking return value" "$RET_OK" "$status"

	data=$(head -n 1 "$out" | tail -n 1 | strip_newline | grep -c "{250}{500}line1")
	assertTrue "checking output 1" "[ \"$data\" -ge 1 ]"

	data=$(head -n 2 "$out" | tail -n 1 | strip_newline | grep -c "{550}{625}line2")
	assertTrue "checking output 2" "[ \"$data\" -ge 1 ]"

	echo "hms" > "$tmp"
	echo "1 00:00:10 00:00:20 line1" >> "$tmp"
	echo "2 00:00:22 00:00:25 line2" >> "$tmp"

	write_format_microdvd "$tmp" "$out"
	status=$?
	assertEquals "checking return value" "$RET_OK" "$status"

	data=$(head -n 1 "$out" | tail -n 1 | strip_newline | grep -c "{250}{500}line1")
	assertTrue "checking output 3" "[ \"$data\" -ge 1 ]"

	data=$(head -n 2 "$out" | tail -n 1 | strip_newline | grep -c "{550}{625}line2")
	assertTrue "checking output 4" "[ \"$data\" -ge 1 ]"

	echo "hmsms" > "$tmp"
	echo "1 00:00:10.5 00:00:20.5 line1" >> "$tmp"
	echo "2 00:00:22.5 00:00:25.5 line2" >> "$tmp"

	g_outf[$___FPS]=30
	write_format_microdvd "$tmp" "$out"
	status=$?
	assertEquals "checking return value" "$RET_OK" "$status"

	data=$(head -n 1 "$out" | tail -n 1 | strip_newline | grep -c "{315}{615}line1")
	assertTrue "checking output 5" "[ \"$data\" -ge 1 ]"

	data=$(head -n 2 "$out" | tail -n 1 | strip_newline | grep -c "{675}{765}line2")
	assertTrue "checking output 6" "[ \"$data\" -ge 1 ]"

	unlink "$tmp"
	unlink "$out"
	_restore_subotage_globs
	return 0
}


test_write_format_mpl2() {
	local tmp=$(mktemp tmp.XXXXXXXX)
	local out=$(mktemp out.XXXXXXXX)
	local status=0
	local data=''

	_save_subotage_globs

	echo "junk" > "$tmp"
	echo "junk" >> "$tmp"

	write_format_mpl2 "$tmp" "$out" 2>&1 > /dev/null
	status=$?
	assertEquals "checking return value" "$RET_FAIL" "$status"

	echo "secs" > "$tmp"
	echo "1 10 20 line1" >> "$tmp"
	echo "2 22 25 line2" >> "$tmp"

	write_format_mpl2 "$tmp" "$out"
	status=$?
	assertEquals "checking return value" "$RET_OK" "$status"

	data=$(head -n 1 "$out" | tail -n 1 | strip_newline | grep -c "\[100\]\[200\]line1")
	assertTrue "mpl2 checking output 1" "[ \"$data\" -ge 1 ]"

	data=$(head -n 2 "$out" | tail -n 1 | strip_newline | grep -c "\[220\]\[250\]line2")
	assertTrue "mpl2 checking output 2" "[ \"$data\" -ge 1 ]"

	echo "hms" > "$tmp"
	echo "1 00:00:10 00:00:20 line1" >> "$tmp"
	echo "2 00:00:22 00:00:25 line2" >> "$tmp"

	write_format_mpl2 "$tmp" "$out"
	status=$?
	assertEquals "mpl2 checking return value" "$RET_OK" "$status"

	data=$(head -n 1 "$out" | tail -n 1 | strip_newline | grep -c "\[100\]\[200\]line1")
	assertTrue "mpl2 checking output 3" "[ \"$data\" -ge 1 ]"

	data=$(head -n 2 "$out" | tail -n 1 | strip_newline | grep -c "\[220\]\[250\]line2")
	assertTrue "mpl2 checking output 4" "[ \"$data\" -ge 1 ]"

	echo "hmsms" > "$tmp"
	echo "1 00:00:10.5 00:00:20.5 line1" >> "$tmp"
	echo "2 00:00:22.5 00:00:25.5 line2" >> "$tmp"

	write_format_mpl2 "$tmp" "$out"
	status=$?
	assertEquals "mpl2 checking return value" "$RET_OK" "$status"

	data=$(head -n 1 "$out" | tail -n 1 | strip_newline | grep -c "\[105\]\[205\]line1")
	assertTrue "mpl2 checking output 5" "[ \"$data\" -ge 1 ]"

	data=$(head -n 2 "$out" | tail -n 1 | strip_newline | grep -c "\[225\]\[255\]line2")
	assertTrue "mpl2 checking output 6" "[ \"$data\" -ge 1 ]"

	unlink "$tmp"
	unlink "$out"
	_restore_subotage_globs
	return 0

}


test_write_format_subviewer2() {
	local tmp=$(mktemp tmp.XXXXXXXX)
	local out=$(mktemp out.XXXXXXXX)
	local status=0
	local data=''

	_save_subotage_globs

	echo "junk" > "$tmp"
	echo "junk" >> "$tmp"

	write_format_subviewer2 "$tmp" "$out" 2>&1 > /dev/null
	status=$?
	assertEquals "checking return value" "$RET_FAIL" "$status"

	echo "secs" > "$tmp"
	echo "1 10 20 line1" >> "$tmp"
	echo "2 22 25 line2" >> "$tmp"

	write_format_subviewer2 "$tmp" "$out"
	status=$?
	assertEquals "checking return value" "$RET_OK" "$status"

	data=$(head -n 11 "$out" | tail -n 1 | strip_newline | grep -c "00:00:10\.00,00:00:20\.00")
	assertTrue "subviewer2 checking output 1" "[ \"$data\" -ge 1 ]"

	data=$(head -n 14 "$out" | tail -n 1 | strip_newline | grep -c "00:00:22\.00,00:00:25\.00")
	assertTrue "subviewer2 checking output 2" "[ \"$data\" -ge 1 ]"

	echo "hms" > "$tmp"
	echo "1 00:00:10 00:00:20 line1" >> "$tmp"
	echo "2 00:00:22 00:00:25 line2" >> "$tmp"
    
	write_format_subviewer2 "$tmp" "$out"
	status=$?
	assertEquals "subviewer2 checking return value" "$RET_OK" "$status"
    
	data=$(head -n 11 "$out" | tail -n 1 | strip_newline | grep -c "00:00:10\.00,00:00:20\.00")
	assertTrue "subviewer2 checking output 1" "[ \"$data\" -ge 1 ]"

	data=$(head -n 14 "$out" | tail -n 1 | strip_newline | grep -c "00:00:22\.00,00:00:25\.00")
	assertTrue "subviewer2 checking output 2" "[ \"$data\" -ge 1 ]"

	echo "hmsms" > "$tmp"
	echo "1 00:00:10.5 00:00:20.5 line1" >> "$tmp"
	echo "2 00:00:22.5 00:00:25.5 line2" >> "$tmp"
    
	write_format_subviewer2 "$tmp" "$out"
	status=$?
	assertEquals "subviewer2 checking return value" "$RET_OK" "$status"
    
	data=$(head -n 11 "$out" | tail -n 1 | strip_newline | grep -c "00:00:10\.50,00:00:20\.50")
	assertTrue "subviewer2 checking output 1" "[ \"$data\" -ge 1 ]"

	data=$(head -n 14 "$out" | tail -n 1 | strip_newline | grep -c "00:00:22\.50,00:00:25\.50")
	assertTrue "subviewer2 checking output 2" "[ \"$data\" -ge 1 ]"
    
	unlink "$tmp"
	unlink "$out"
	_restore_subotage_globs
	return 0
}


test_write_format_tmplayer() {
	return 0
}


test_write_format_subrip() {
	local tmp=$(mktemp tmp.XXXXXXXX)
	local out=$(mktemp out.XXXXXXXX)
	local status=0
	local data=''

	_save_subotage_globs

	echo "junk" > "$tmp"
	echo "junk" >> "$tmp"

	write_format_subrip "$tmp" "$out" 2>&1 > /dev/null
	status=$?
	assertEquals "checking return value" "$RET_FAIL" "$status"

	echo "secs" > "$tmp"
	echo "1 10 20 line1" >> "$tmp"
	echo "2 22 25 line2" >> "$tmp"

	write_format_subrip "$tmp" "$out"
	status=$?
	assertEquals "checking return value" "$RET_OK" "$status"

	data=$(head -n 1 "$out" | tail -n 1 | strip_newline)
	assertEquals "subrip checking output 1" 1 "$data"

	data=$(head -n 2 "$out" | tail -n 1 | strip_newline | grep -c "00:00:10,000 --> 00:00:20,000")
	assertTrue "subrip checking output 2" "[ \"$data\" -ge 1 ]"

	data=$(head -n 3 "$out" | tail -n 1 | strip_newline | grep -c "line1")
	assertTrue "subrip checking output 3" "[ \"$data\" -ge 1 ]"

	echo "hms" > "$tmp"
	echo "1 00:00:10 00:00:20 line1" >> "$tmp"
	echo "2 00:00:22 00:00:25 line2" >> "$tmp"
    
	write_format_subrip "$tmp" "$out"
	status=$?
	assertEquals "subrip checking return value" "$RET_OK" "$status"
    
	data=$(head -n 1 "$out" | tail -n 1 | strip_newline)
	assertEquals "subrip checking output 4" 1 "$data"

	data=$(head -n 2 "$out" | tail -n 1 | strip_newline | grep -c "00:00:10,000 --> 00:00:20,000")
	assertTrue "subrip checking output 5" "[ \"$data\" -ge 1 ]"

	data=$(head -n 3 "$out" | tail -n 1 | strip_newline | grep -c "line1")
	assertTrue "subrip checking output 6" "[ \"$data\" -ge 1 ]"

	echo "hmsms" > "$tmp"
	echo "1 00:00:10.5 00:00:20.5 line1" >> "$tmp"
	echo "2 00:00:22.5 00:00:25.5 line2" >> "$tmp"
    
	write_format_subrip "$tmp" "$out"
	status=$?
	assertEquals "subrip checking return value" "$RET_OK" "$status"
    
	data=$(head -n 1 "$out" | tail -n 1 | strip_newline)
	assertEquals "subrip checking output 7" 1 "$data"

	data=$(head -n 2 "$out" | tail -n 1 | strip_newline | grep -c "00:00:10,500 --> 00:00:20,500")
	assertTrue "subrip checking output 8" "[ \"$data\" -ge 1 ]"

	data=$(head -n 3 "$out" | tail -n 1 | strip_newline | grep -c "line1")
	assertTrue "subrip checking output 9" "[ \"$data\" -ge 1 ]"

	unlink "$tmp"
	unlink "$out"
	_restore_subotage_globs
	return 0
}


test_guess_format() {
	
	return 0
}

test_correct_overlaps() {

	return 0
}

test_list_formats() {
	# no need to test that
	return 0
}


test_usage() {
	# no need to test that
	return 0
}


test_parse_argv() {
	
	return 0
}


test_verify_format() {
	local status=0

	verify_format "bogus_format"
	status=$?
	assertEquals "failure for bogus format" $RET_PARAM "$status"

	declare -a formats=( "subrip" "microdvd" "subviewer2" "mpl2" "tmplayer" )
	for i in "${formats[@]}"; do
		verify_format "$i"
		status=$?
		assertEquals "$i format" $RET_OK "$status"
	done
	return 0
}


test_verify_fps() {
	local status=0

	verify_fps "23,456"
	status=$?
	assertEquals "fps format with comma" $RET_PARAM "$status"

	verify_fps "23.456"
	status=$?
	assertEquals "fps format with period" $RET_OK "$status"

	verify_fps "23"
	status=$?
	assertEquals "fps format without period" $RET_OK "$status"

	return 0
}


test_verify_argv() {

	return 0
}


test_detect_microdvd_fps() {
	local status=0

	declare -a data=( \
	   "{1}{1}23.976fps" \
	   "{1}{72}movie info: XVID  720x304 23.976fps 1.4 GB" \
	   "{1}{72}movie info: XVID  720x304 25.0 1.4 GB" \
	   "{1}{72}30fps" \
	   "{1}{72}30" \
   	   )

	declare -a res=( \
	   "23.976" \
	   "23.976" \
	   "25.0" \
	   "30" \
	   "30"
   	   )

	local idx=0
	local fps=0

	for i in "${data[@]}"; do
		fps=$(echo "$i" | detect_microdvd_fps)
		assertEquals "checking fps $idx" "${res[$idx]}" "$fps"
		idx=$(( idx + 1 ))
	done
	
	return 0
}


test_correct_fps() {
	_save_subotage_globs

	g_inf[$___FPS]=25
	g_outf[$___FPS]=0
	correct_fps
	assertEquals "checking if fps has been synced" "${g_inf[$___FPS]}" "${g_outf[$___FPS]}"


	g_inf[$___FPS]=25
	g_outf[$___FPS]=23
	correct_fps
	assertEquals "checking if fps has not been synced" 23 "${g_outf[$___FPS]}"

	_restore_subotage_globs
	return 0
}

test_check_if_conv_needed() {
	local status=0

	_save_subotage_globs

	g_inf[$___FORMAT]="subrip"
	g_outf[$___FORMAT]="SUBRIP"
	check_if_conv_needed
	status=$?
	assertEquals "conversion not needed rv check" $RET_NOACT "$status"

	g_inf[$___FORMAT]="subrip"
	g_outf[$___FORMAT]="mpl2"
	check_if_conv_needed
	status=$?
	assertEquals "conversion needed rv check" $RET_OK "$status"

	g_inf[$___FORMAT]="microdvd"
	g_outf[$___FORMAT]="microdvd"

	g_inf[$___FPS]="23.456"
	g_outf[$___FPS]="23.456"
	check_if_conv_needed 2>&1 > /dev/null
	status=$?
	assertEquals "conversion not needed udvd same fps" $RET_NOACT "$status"
	
	g_inf[$___FPS]="23.456"
	g_outf[$___FPS]="29.756"
	check_if_conv_needed
	status=$?
	assertEquals "conversion needed udvd != fps" $RET_OK "$status"

	_restore_subotage_globs
	return 0
}


test_print_format_summary() {
	local presence=0
	_save_subotage_globs

	presence=$(print_format_summary "PREFIX_" "some_file" | grep -c "PREFIX_")
	assertEquals "checking summary prefix" 0 "$presence"

	g_output[$___VERBOSIRTY]=2
	presence=$(print_format_summary "PREFIX_" "some_file" | grep -c "PREFIX_")
	assertTrue "checking summary prefix" "[ $presence -gt 0 ]"

	g_output[$___VERBOSIRTY]=1
	g_getinfo=1
	presence=$(print_format_summary "PREFIX_" "some_file" | grep -c "PREFIX_")
	assertTrue "checking summary prefix" "[ $presence -gt 0 ]"

	_restore_subotage_globs
	return 0
}


test_convert_formats() {
	
	return 0
}


test_process_file() {
	# empty this will be verified with system tests
	return 0
}


test_create_output_summary() {
	local tmp=$(mktemp ipc.XXXXXXXX)
	local data=''
	_save_subotage_globs

	g_ipc_file="$tmp"
	g_output[$___CNT]=666
	create_output_summary
	read data < "$tmp"

	assertEquals "comparing cnt values" 666 "$data"

	unlink "$tmp"
	_restore_subotage_globs
	return 0
}

# shunit call
. shunit2
