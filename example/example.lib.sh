## $Id: example.lib.sh,v 1.3 2010/05/13 18:16:29 wschlich Exp wschlich $
## vim:ts=4:sw=4:tw=200:nu:ai:nowrap:

##
## REQUIRED PROGRAMS
## =================
## - rm
## - mkdir
## - ls
##

##
## application initialization function
## (command line argument parsing and validation etc.)
##

function __init() {

	## -- BEGIN YOUR OWN APPLICATION INITIALIZATION CODE HERE --

	## parse command line options
	while getopts ':ab:q' opt; do
		case "${opt}" in
			## option a
			a)
				declare -i A=1
				;;
			## option b
			b)
				B="${OPTARG}"
				;;
			## quiet operation
			q)
				declare -i __MsgQuiet=1
				;;
			## option without a required argument
			:)
				__die 2 "option -${OPTARG} requires an argument" # TODO FIXME: switch to __msg err
				;;
			## unknown option
			\?)
				__die 2 "unknown option -${OPTARG}" # TODO FIXME: switch to __msg err
				;;
			## this should never happen
			*)
				__die 2 "there's an error in the matrix!" # TODO FIXME: switch to __msg err
				;;
		esac
		__msg debug "command line argument: -${opt}${OPTARG:+ '${OPTARG}'}"
	done
	## check if command line options were given at all
	if [[ ${OPTIND} == 1 ]]; then
		__die 2 "no command line option specified" # TODO FIXME: switch to __msg err
	fi
	## shift off options + arguments
	let OPTIND--; shift ${OPTIND}; unset OPTIND
	args="${@}"
	set --

	return 0 # success

	## -- END YOUR OWN APPLICATION INITIALIZATION CODE HERE --

}

##
## application main function
##

function __main() {

	## -- BEGIN YOUR OWN APPLICATION MAIN CODE HERE --

	local i
	for i in debug info notice warning err crit alert emerg; do
		__msg ${i} "this is a ${i} test"
	done

	rm -v /does/not/exist >>"${_L}" 2>&1
	mkdir -v /does/not/exist >>"${_L}" 2>&1
	ls -v /does/not/exist >>"${_L}" 2>&1

	exampleFunction "${ApplicationVariable1}" "${ApplicationVariable2}"

	fooFunction fooArgs

	return 0 # success

	## -- END YOUR OWN APPLICATION MAIN CODE HERE --

}

##
## application worker functions
##

function exampleFunction() {

	## ----- head -----
	##
	## DESCRIPTION:
	##   this function does something
	##
	## ARGUMENTS:
	##   1: fooArgument (req): contains foo
	##   2: barArgument (opt): contains bar
	##
	## GLOBAL VARIABLES USED:
	##   /
	##

	local fooArgument="${1}"
	if [[ -z "${fooArgument}" ]]; then
		__msg err "argument 1 (fooArgument) missing"
		return 2 # error
	fi
	__msg debug "fooArgument: ${fooArgument}"

	local barArgument="${2}"
	__msg debug "barArgument: ${barArgument}"

	## ----- main -----

	__msg info "this is an example function"

	__msg info "PATH: ${PATH}"
	__msg info "umask: $(umask)"

	return 0 # success
}

function fooFunction() {
	barFunction barArgs
}

function barFunction() {
	bazFunction bazArgs
}

function bazFunction() {
	__die 1 "dying for test purposes"
}
