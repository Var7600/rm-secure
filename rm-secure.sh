#!/usr/bin/env bash

# trash directory
# Use the externally provided sauvegarde_rm or default to ~/rm_saved/
sauvegarde_rm=${sauvegarde_rm:-~/rm_saved}


# Usages
function usage() {

	echo "rm_secure: A safer alternative to GNU rm"
	echo "Usage: rm [OPTIONS] FILE..."
	echo "Options:"
	# echo "  -d <days>      Set retention period in days (default: $days)"
	echo "  -e, --empty    Empty the trash folder(Definitively)"
	echo "  -l, --list     List files in the trash folder"
	echo "  -s, --restore  Restore files or directory from trash"
	echo "  -r/-R, --delete delete a directory "
	echo "  -v, --verbose  Verbose output"
	echo "  --help         Show this help message"
}

# Function to ensure the trash directory exists
function create_trash_dir() {
    if [ ! -d "$sauvegarde_rm" ]; then
        mkdir -p "$sauvegarde_rm" || { echo "Failed to create trash directory!"; return 1; }
    fi
}

# Function to list trash
function list_trash() {

    if [ -z "$(ls -A "$sauvegarde_rm")" ]; then
        echo "Trash is empty."
    else
        ls -lA "$sauvegarde_rm"
    fi
}


# Function to empty the trash
function delete_trash() {
	# Empty the trash
  /bin/rm -rf "$sauvegarde_rm" ||  echo "Failed to empty trash!"
}

# Function to restore files
function restore_files() {
		# restore files provided as arguments
		while [ -n "$1" ]; do
				# find file(s)
				local found
				# shellcheck disable=SC2010 
				found=$(ls "$sauvegarde_rm" | grep "$1")
				if [ -z "$found" ];then
					echo "no filename $1 found in trash!"
				else
					# restore file
					for file in $found
					do
						mv "${sauvegarde_rm}/$file" ./
					done
				fi
				# next argument
				shift
		done

}

# find and cleanup file(s)
function cleanup_old_files() {
	# Function to delete files after retention period
    find "$sauvegarde_rm" -type f -mtime +"$1" -delete 
}

function rm {
    local opt_force=0
    local opt_interactive=0
    local opt_recursive=0
    local opt_verbose=0
    local opt_empty=0
    local opt_list=0
    local opt_restore=0
    local opt

		# default retention period is 60 days
		local days=60

    OPTIND=0
    # process command line argument
    while getopts ':d:firRvels-:' opt ; do
        case $opt in
					# TO DO -d option to specify the number of days to save the file
       # d) override_days="$OPTARG" ;; 
        f) opt_force=1 ;;
        i) opt_interactive=1 ;;
        r | R ) opt_recursive=1 ;;
        e ) opt_empty=1 ;;
        l) opt_list=1 ;;
        s) opt_restore=1 ;;
        v) opt_verbose=1 ;;
				:)
					echo "option requires an argument"
					return 1
					;;
        -) case $OPTARG in
					# TO DO --days  to specify the number of days to save the file
					# days ) override_days="$3"; OPTIND=$(( OPTIND + 1 )) ;;
								
                force) opt_force=1 ;;
                interactive) opt_interactive=1 ;;
                recursive) opt_recursive=1 ;;
                verbose) opt_verbose=1 ;;
                help) 
										usage
                    return 0 ;; # exit code for rm
                version ) 
										echo "rm_secure version 1.3"
                    return 0 ;;
                # default option
                empty ) opt_empty=1 ;;
                list ) opt_list=1 ;;
                restore) opt_restore=1 ;;
                * ) echo "unknow option -- $OPTARG" # option invalid 
                    return 1 ;; # error 
            esac ;;
        ? ) echo "illegal option -- $OPTARG"
            return 1 ;;
        esac
    done

    shift $((OPTIND - 1)) # shifts the arguments by removing the first n
		

    # Function to create the backup directory
		create_trash_dir

    # empty trash call function delete_trash
		[ $opt_empty -ne 0 ] && { delete_trash; return 0; }

    # list files in the trash call function list_trash
		[ $opt_list -ne 0 ] && { list_trash; return 0; }

    # restore trash files	
		if [ -z "$1" ];then
			echo "No arguments was provided"
			return 0
		else
			[ $opt_restore -ne 0 ] && { restore_files "$@";  return 0; }
		fi
	  # Cleanup old files
    cleanup_old_files "$days"

    # delete files
    while [ -n "$1" ]; do
        # delete interactive mode 
        if [ $opt_force -ne 1 ] && [ $opt_interactive -ne 0 ]; then
            local response
            echo -n "Delete $1?[y/n]: "
            read -r response
            if [ "$response" != "y" ] && [ "$response" != "Y" ]; then
                shift # delete
                continue
            fi
        fi

        # for deleting a directory
        if [ -d "$1" ] && [ $opt_recursive -eq 0 ]; then
            echo "$1 is a Directory please use -r or -R option."
            shift
            continue
        fi

        if [ $opt_verbose -ne 0 ]; then
					echo "deleting $1 (Saved in $sauvegarde_rm)"
        fi

				# format YYYY_MM_DD_XXhXXm
				timestamp=$(date +%Y_%m_%d_%Hh%Mm)
				# deleting/moving files
				mv -f "$1" "${sauvegarde_rm}/${timestamp}_$(basename "$1")" && echo "saved for $days days"
        shift
    done
}
