## $Id: bashinator.lib.0.sh,v 1.5 2009/05/27 07:50:56 wschlich Exp wschlich $
## vim:ts=4:sw=4:tw=200:nu:ai:nowrap:
##
## bashinator shell script framework library
##
## Created by Wolfram Schlich <wschlich@gentoo.org>
## Licensed under the GNU GPLv3

##
## REQUIRED PROGRAMS
## =================
## - rm
## - touch
## - mktemp
## - cat
## - logger
## - sed
## - date
## - sendmail (default /usr/sbin/sendmail, can be overridden with __SendmailBin)
##

## define the required minimum bash version for this
## bashinator release to function properly
export __BashinatorRequiredBashVersion=3.2.0

##
## bashinator control functions
##

function __boot() {

	## ----- head -----
	##
	## DESCRIPTION:
	##   initializes bashinator
	##
	## ARGUMENTS:
	##   /
	##
	## GLOBAL VARIABLES USED:
	##   __BashinatorRequiredBashVersion (default: 0.0.0)
	##   BASH_VERSINFO
	##   EUID
	##   PATH
	##

	## check for required bash version
	IFS='.'
	set -- ${__BashinatorRequiredBashVersion:-0.0.0}
	unset IFS
	local -i requiredBashMajorVersion=${1}
	local -i requiredBashMinorVersion=${2}
	local -i requiredBashPatchLevel=${3}
	set --
	if [[ ! ( ${BASH_VERSINFO[0]} -ge ${requiredBashMajorVersion} \
		&& ${BASH_VERSINFO[1]} -ge ${requiredBashMinorVersion} \
		&& ${BASH_VERSINFO[2]} -ge ${requiredBashPatchLevel} ) ]]; then
		echo "!!! FATAL: bashinator requires at least bash version ${__BashinatorRequiredBashVersion}" 1>&2
		exit 2 # error
	fi

	## define safe PATH
	export PATH="/bin:/usr/bin"
	if [[ ${EUID} -eq 0 ]]; then
		export PATH="/sbin:/usr/sbin:${PATH}"
	fi

	## basic shell settings
	shopt -s extglob  # enable extended globbing (required for pattern matching)
	shopt -s extdebug # enable extended debugging (required for function stack trace)
	hash -r           # reset hashed command paths
	set +m            # disable monitor mode (job control)
	umask 0077        # use secure default umask

	return 0 # success

} # __boot()

function __dispatch() {

	## ----- head -----
	##
	## DESCRIPTION:
	##   dispatches the application.
	##   calls the __init() and __main()
	##   functions that have to be defined by the user.
	##
	## ARGUMENTS:
	##   *: all arguments of the originally executed script
	##
	## GLOBAL VARIABLES USED:
	##   Exit: can be set to a custom exit code from within
	##   the user functions
	##

	## check for user defined __init() function
	if ! declare -F __init >&/dev/null; then
		__die 2 "function __init() does not exist, unable to dispatch application"
	fi

	## check for user defined __main() function
	if ! declare -F __main >&/dev/null; then
		__die 2 "function __main() does not exist, unable to dispatch application"
	fi

	## ----- main -----

	## init application function
	__init "${@}" || __die 2 "__init() failure"

	## main application pre-processing (create lockfile and subcommand logfile)
	__prepare || __die 2 "__prepare() failure"

	## main application function
	__main || __die 2 "__main() failure"

	## main application post-processing (remove lockfile and subcommand logfile)
	__cleanup || __die 2 "__cleanup() failure"

	exit ${Exit:-0}

} # __dispatch()

function __prepare() {

	## ----- head -----
	##
	## DESCRIPTION:
	##   run application main pre-processing tasks
	##
	## ARGUMENTS:
	##   /
	##
	## GLOBAL VARIABLES USED:
	##   __ScriptSubCommandLog (default: 0)
	##   __ScriptSubCommandLogFile
	##   __ScriptLock (default: 0)
	##   __ScriptLockFile
	##

	## ----- main -----

	## handle script subcommand logfile
	if [[ ${__ScriptSubCommandLog:-0} == 1 ]]; then
		## create temporary logfile
		__ScriptSubCommandLogFile=$(mktemp -q -t -p "${__ScriptSubCommandLogDir:-/var/log}" ${__ScriptName}.log.XXXXXX)
		if [[ -z "${__ScriptSubCommandLogFile}" ]]; then
			__msg alert "failed to create temporary script subcommand logfile in script logdir '${__ScriptSubCommandLogDir:-/var/log}'"
			return 2 # error
		else
			__msg debug "successfully created temporary script subcommand logfile '${__ScriptSubCommandLogFile}'"
		fi
	else
		## if sub command logging is disabled, set logfile to
		## /dev/null to make redirections work nevertheless.
		__ScriptSubCommandLogFile="/dev/null"
	fi
	export __ScriptSubCommandLogFile _L=${__ScriptSubCommandLogFile} # use _L as a shorthand
	__msg debug "script subcommand logfile: '${__ScriptSubCommandLogFile}'"

	## handle script lockfile
	if [[ ${__ScriptLock:-0} == 1 ]]; then
		__ScriptLockFile="${__ScriptLockDir:-/var/lock}/${__ScriptName}.lock"
		## check/create lockfile
		if [[ -e "${__ScriptLockFile}" ]]; then
			__msg alert "script lockfile '${__ScriptLockFile}' already exists"
			return 2 # error
		elif ! touch "${__ScriptLockFile}" >>"${_L}" 2>&1; then
			__msg alert "failed to create script lockfile '${__ScriptLockFile}'"
			return 2 # error
		else
			__msg debug "successfully created script lockfile '${__ScriptLockFile}'"
		fi
	fi

	return 0 # success

} # __prepare()

function __cleanup() {

	## ----- head -----
	##
	## DESCRIPTION:
	##   run application main post-processing tasks
	##
	## ARGUMENTS:
	##   /
	##
	## GLOBAL VARIABLES USED:
	##   __ScriptSubCommandLog (default: 0)
	##   __ScriptSubCommandLogFile
	##   __ScriptLock (default: 0)
	##   __ScriptLockFile
	##

	## ----- main -----

	## remove script subcommand logfile
	if [[ ${__ScriptSubCommandLog:-0} == 1 && "${__ScriptSubCommandLogFile}" != /dev/null ]]; then
		__msg debug "removing script subcommand logfile '${__ScriptSubCommandLogFile}'"
		if ! rm -f "${__ScriptSubCommandLogFile}" &>/dev/null; then
			__msg alert "failed to remove script subcommand logfile '${__ScriptSubCommandLogFile}'"
			return 2 # error
		else
			__msg debug "successfully removed script subcommand logfile '${__ScriptSubCommandLogFile}'"
		fi
	fi

	## remove script lockfile
	if [[ ${__ScriptLock:-0} == 1 ]]; then
		__msg debug "removing script lockfile '${__ScriptLockFile}'"
		if ! rm -f "${__ScriptLockFile}" &>/dev/null; then
			__msg alert "failed to remove script lockfile '${__ScriptLockFile}'"
			return 2 # error
		else
			__msg debug "successfully removed script lockfile '${__ScriptLockFile}'"
		fi
	fi

	return 0 # success

} # __cleanup()

function __die() {

	## ----- head -----
	##
	## DESCRIPTION:
	##   terminate the currently executing script
	##
	## ARGUMENTS:
	##   1: exit code (req, default: 1)
	##   2: message (opt): the message explaining the termination
	##
	## GLOBAL VARIABLES USED:
	##   /
	##

	local -i exitCode="${1}"; shift
	local message="${1}"; shift

	## ----- main -----

	## check for exit code
	if [[ -z "${exitCode}" ]]; then
		let exitCode=1
	fi

	## check for error message
	if [[ -z "${message}" ]]; then
		message="<called ${FUNCNAME[0]}() without message>"
	fi

	## number of functions involved
	local -i numberOfFunctions=$((${#FUNCNAME[@]} - 1))

	## skip this number of functions from the bottom of the call stack
	## 1 == only skip this function itself
	local -i skipNumberOfFunctions=1

	## display main error message
	__msg alert "FATAL: ${message}"

	## display function call stack (if any functions are involved)
	if [[ "${numberOfFunctions}" > "${skipNumberOfFunctions}" ]]; then

		__msg alert "function call stack (most recent last):"

		## n: current function array pointer (initially the last element of the FUNCNAME array)
		## p: current parameter pointer (initially the last element of the BASH_ARGV array)
		## bashFileName: source file of previous function that called the current function
		## bashLineNumber: line in file that called the function
		## functionName: name of called function
		local -i n=0 p=0 bashLineNumber=0
		local bashFileName= functionName=

		for ((n = ${#FUNCNAME[@]} - 1, p = ${#BASH_ARGV[@]} - 1; n >= ${skipNumberOfFunctions}; n--)) ; do

			bashFileName="${BASH_SOURCE[n + 1]##*/}"
			bashLineNumber="${BASH_LINENO[n]}"
			functionName="${FUNCNAME[n]}"

			## get function arguments (bash3 only)
			if [[ ${#BASH_ARGC[n]} -gt 0 ]]; then
				## argList: list of quoted arguments of current function
				## arg: next argument
				local argList= arg=
				## a: current function argument count pointer
				local -i a=0
				for ((a = 0; a < ${BASH_ARGC[n]}; ++a)); do
					arg="${BASH_ARGV[p - a]}"
					argList="${argList:+${argList},}'${arg}'"
				done
				## decrement parameter pointer by the count of parameters of the current function
				(( p -= ${BASH_ARGC[n]} ))
			fi

			## skip main function
			if [[ ${FUNCNAME[n]} == "main" ]]; then
				continue
			fi

			## print function information
			__msg alert "--> ${functionName}(${argList:+${argList}}) called in '${bashFileName}' on line ${bashLineNumber}"

		done
	fi

	## mention path to script subcommand log if enabled and not empty
	if [[ ${__ScriptSubCommandLog:-0} -eq 1 \
		&& ${__ScriptSubCommandLogFile} != /dev/null \
		&& -s ${__ScriptSubCommandLogFile} ]]; then
		__msg alert "please check script subcommand log '${__ScriptSubCommandLogFile}' for details"
	fi

	__msg alert "terminating script"

	exit ${exitCode}

} # __die()

##
## bashinator message functions
##

function __msgPrint() {
	
	## ----- head -----
	##
	## DESCRIPTION:
	##   prints a message
	##
	## ARGUMENTS:
	##   1: severity (req): severity of the message
	##   2: message (req): the message to print
	##
	## GLOBAL VARIABLES USED:
	##   __PrintDebug
	##   __PrintInfo
	##   __PrintNotice
	##   __PrintWarning
	##   __PrintErr
	##   __PrintCrit
	##   __PrintAlert
	##   __PrintEmerg
	##   __PrintPrefixTimestamp
	##   TERM (used to determine if we are running inside a terminal supporting colors)
	##

	local timestamp="${1}"; shift
	local severity="${1}"; shift
	local message="${1}"; shift

	## ----- main -----

	## check whether message is to be printed at all
	case ${severity} in
		  debug) if [[ ${__PrintDebug:-0}   -ne 1 ]]; then return 0; fi ;;
		   info) if [[ ${__PrintInfo:-1}    -ne 1 ]]; then return 0; fi ;;
		 notice) if [[ ${__PrintNotice:-1}  -ne 1 ]]; then return 0; fi ;;
		warning) if [[ ${__PrintWarning:-1} -ne 1 ]]; then return 0; fi ;;
		    err) if [[ ${__PrintErr:-1}     -ne 1 ]]; then return 0; fi ;;
		   crit) if [[ ${__PrintCrit:-1}    -ne 1 ]]; then return 0; fi ;;
		  alert) if [[ ${__PrintAlert:-1}   -ne 1 ]]; then return 0; fi ;;
		  emerg) if [[ ${__PrintEmerg:-1}   -ne 1 ]]; then return 0; fi ;;
	esac

	## determine whether we can show colors
	local -i colorTerm=0
	case "${TERM}" in
		screen*|xterm*) let colorTerm=1 ;;
		*) let colorTerm=0 ;;
	esac

	## show colors on stdout/stderr only if
	## on a terminal (not redirected)
	local -i colorStdout=0 colorStderr=0
	if [[ -t 1 && ${colorTerm} -eq 1 ]]; then
		let colorStdout=1
	fi
	if [[ -t 2 && ${colorTerm} -eq 1 ]]; then
		let colorStderr=1
	fi

	## mapping severity -> stderr/prefix/color
	local prefix color
	local -i stderr=0
	case ${severity} in
		  debug) let stderr=0; prefix=">>> [____DEBUG] "; color="1;34"    ;; # blue on default
		   info) let stderr=0; prefix=">>> [_____INFO] "; color="1;36"    ;; # cyan on default
		 notice) let stderr=0; prefix=">>> [___NOTICE] "; color="1;32"    ;; # green on default
		warning) let stderr=1; prefix="!!! [__WARNING] "; color="1;33"    ;; # yellow on default
		    err) let stderr=1; prefix="!!! [____ERROR] "; color="1;31"    ;; # red on default
		   crit) let stderr=1; prefix="!!! [_CRITICAL] "; color="1;37;41" ;; # white on red
		  alert) let stderr=1; prefix="!!! [____ALERT] "; color="1;33;41" ;; # yellow on red
		  emerg) let stderr=1; prefix="!!! [EMERGENCY] "; color="1;37;45" ;; # white on magenta
	esac

	## prefix message with timestamp?
	case ${__PrintPrefixTimestamp:-1} in
		1) prefix="${timestamp} ${prefix}" ;;
		*) ;;
	esac

	## print message
	case ${stderr} in
		## print message to stdout
		0)
			if [[ ${colorStdout} -eq 1 ]]; then
					## print colored message
					echo -e "\033[${color}m${prefix}${message}\033[m"
			else
					## print plain message
					echo "${prefix}${message}"
			fi
			;;
		## print message to stderr
		1)
			if [[ ${colorStderr} -eq 1 ]]; then
					## print colored message
					echo -e "\033[${color}m${prefix}${message}\033[m" 1>&2
			else
					## print plain message
					echo "${prefix}${message}" 1>&2
			fi
			;;
	esac

	return 0 # success

} # __msgPrint()

function __print() {
	
	## ----- head -----
	##
	## DESCRIPTION:
	##   prints a message
	##
	## ARGUMENTS:
	##   1: severity (req): severity of the message
	##   2: message (req): the message to print
	##
	## GLOBAL VARIABLES USED:
	##   __MsgTimestampFormat
	##

	local severity="${1}"; shift
	local message="${1}"; shift

	## ----- main -----

	## get current timestamp
	local timestamp=$(date "+${__MsgTimestampFormat:-%Y-%m-%d %H:%M:%S %:z}" 2>/dev/null)

	## print message
	__msgPrint "${timestamp}" "${severity}" "${message}"

	return 0 # success

} # __print()

function __msgLog() {
	
	## ----- head -----
	##
	## DESCRIPTION:
	##   logs a message (or stdin)
	##
	## ARGUMENTS:
	##   1: severity (req): severity of the message
	##   2: message (opt): the message to log (else stdin is read and logged)
	##
	## GLOBAL VARIABLES USED:
	##   __LogDebug
	##   __LogInfo
	##   __LogNotice
	##   __LogWarning
	##   __LogErr
	##   __LogCrit
	##   __LogAlert
	##   __LogEmerg
	##   __LogPrefixTimestamp
	##   __LogTarget (fallback: syslog.user)
	##   __LogFileHasBeenWrittenTo (helper variable)
	##   _L
	##

	local timestamp="${1}"; shift
	local severity="${1}"; shift
	local message="${1}"; shift

	## ----- main -----

	## check whether message is to be logged at all
	case ${severity} in
		  debug) if [[ ${__LogDebug:-0}   -ne 1 ]]; then return 0; fi ;;
		   info) if [[ ${__LogInfo:-1}    -ne 1 ]]; then return 0; fi ;;
		 notice) if [[ ${__LogNotice:-1}  -ne 1 ]]; then return 0; fi ;;
		warning) if [[ ${__LogWarning:-1} -ne 1 ]]; then return 0; fi ;;
		    err) if [[ ${__LogErr:-1}     -ne 1 ]]; then return 0; fi ;;
		   crit) if [[ ${__LogCrit:-1}    -ne 1 ]]; then return 0; fi ;;
		  alert) if [[ ${__LogAlert:-1}   -ne 1 ]]; then return 0; fi ;;
		  emerg) if [[ ${__LogEmerg:-1}   -ne 1 ]]; then return 0; fi ;;
	esac

	## mapping severity -> prefix
	local prefix
	case ${severity} in
		  debug) prefix=">>> [____DEBUG] " ;;
		   info) prefix=">>> [_____INFO] " ;;
		 notice) prefix=">>> [___NOTICE] " ;;
		warning) prefix="!!! [__WARNING] " ;;
		    err) prefix="!!! [____ERROR] " ;;
		   crit) prefix="!!! [_CRITICAL] " ;;
		  alert) prefix="!!! [____ALERT] " ;;
		  emerg) prefix="!!! [EMERGENCY] " ;;
	esac

	## prefix message with timestamp?
	case ${__LogPrefixTimestamp:-1} in
		1) prefix="${timestamp} ${prefix}" ;;
		*) ;;
	esac

	## loop through list of log targets
	IFS=','
	local -a logTargetArray=( ${__LogTarget:-syslog:user} )
	unset IFS
	local -i l
	for ((l = 0; l < ${#logTargetArray[@]}; l++)); do
		local logTarget=${logTargetArray[l]}
		case ${logTarget} in
			## log to a file
			file:*)
				## parse log target setting
				IFS=':'
				set -- ${logTarget}
				unset IFS
				local logFile=${2} # /path/to/logfile
				local logMode=${3:-overwrite} # overwrite|append, default: overwrite
				set --

				## write log message to file
				## if message is empty, we read stdin
				if [[ -z ${message} ]]; then
					if [[ ${logMode} == 'append' || ${__LogFileHasBeenWrittenTo} -eq 1 ]]; then
						## TODO FIXME: check return value?
						#cat >>${logFile} 2>>"${_L:-/dev/null}"
						sed -e "s/^/${prefix} /" >>${logFile} 2>>"${_L:-/dev/null}"
					else
						## TODO FIXME: check return value?
						#cat >${logFile} 2>>"${_L:-/dev/null}"
						sed -e "s/^/${prefix} /" >${logFile} 2>>"${_L:-/dev/null}"
					fi
				else
					if [[ ${logMode} == 'append' || ${__LogFileHasBeenWrittenTo} -eq 1 ]]; then
						## TODO FIXME: check return value?
						echo "${prefix}${message}" >>${logFile} 2>>"${_L:-/dev/null}"
					else
						## TODO FIXME: check return value?
						echo "${prefix}${message}" >${logFile} 2>>"${_L:-/dev/null}"
					fi
				fi
				## global helper variable to determine if logfile
				## has already been opened / written to before
				## during the current execution of the script,
				## needed to support "append" mode.
				declare -i __LogFileHasBeenWrittenTo=1
				;;
			## log via syslog
			syslog:*)
				## parse log target setting
				IFS=':'
				set -- ${logTarget}
				unset IFS
				local syslogFacility=${2:-user}
				local syslogPri="${syslogFacility}.${severity}"
				local syslogTag="${0##*/}[${$}]" # scriptname[PID]
				set --
				## send log message to syslog
				if [[ -z ${message} ]]; then
					## log stdin
					logger -p "${syslogPri}" -t "${syslogTag}" >>"${_L:-/dev/null}" 2>&1
				else
					## log passed message
					logger -p "${syslogPri}" -t "${syslogTag}" -- "${message}" >>"${_L:-/dev/null}" 2>&1
				fi
				;;
			## any other (invalid) log target
			*)
				return 2 # error
				;;
		esac
	done

	return 0 # success

} # __msgLog()

function __log() {
	
	## ----- head -----
	##
	## DESCRIPTION:
	##   logs a message (or stdin)
	##
	## ARGUMENTS:
	##   1: severity (req): severity of the message
	##   2: message (opt): the message to log (else stdin is read and logged)
	##
	## GLOBAL VARIABLES USED:
	##   __MsgTimestampFormat
	##

	local severity="${1}"; shift
	local message="${1}"; shift

	## ----- main -----

	## get current timestamp
	local timestamp=$(date "+${__MsgTimestampFormat:-%Y-%m-%d %H:%M:%S %:z}" 2>/dev/null)

	## log message
	__msgLog "${timestamp}" "${severity}" "${message}"

	return 0 # success

} # __log()

function __msg() {

	## ----- head -----
	##
	## DESCRIPTION:
	##   processes a message (or stdin) for logging/printing/later mailing
	##
	## ARGUMENTS:
	##   0: -q (opt): quiet (do not print message, required for print functions)
	##   1: severity (req): severity of the message
	##   2: message (opt): the message to log (else stdin is read and logged)
	##
	## GLOBAL VARIABLES USED:
	##   __MsgArray
	##   __MsgQuiet
	##   __MsgTimestampFormat
	##

	if [[ ${1} == "-q" ]]; then
		let quiet=1; shift
	fi

	local severity="${1}"; shift
	local message="${1}"; shift

	## ----- main -----

	## get current timestamp
	local timestamp=$(date "+${__MsgTimestampFormat:-%Y-%m-%d %H:%M:%S %:z}" 2>/dev/null)

	## check for global quiet operation setting
	if [[ ${__MsgQuiet} -eq 1 ]]; then
		let quiet=1
	fi

	## determine the line number and file name
	## of the current script file and the
	## calling function
	local callingFunction=
	local -i bashLineNumber=
	local bashFile=
	case "${FUNCNAME[1]}" in
		## we were called by __die()
		__die)
			## use the info of the function that called __die()
			bashFileName=${BASH_SOURCE[2]} # the file name where the function that called __die was called
			let bashLineNumber=${BASH_LINENO[1]} # the line number where __die was called
			callingFunction=${FUNCNAME[2]} # the name of the function that called __die
			;;
		## we were called by any other function
		*)
			## use the info of the function that called __msg()
			bashFileName=${BASH_SOURCE[1]} # the file name where the function that called __msg was called
			let bashLineNumber=${BASH_LINENO[0]} # the line number where __msg was called
			callingFunction=${FUNCNAME[1]} # the name of the function that called __msg
			;;
	esac
	bashFileName=${bashFileName##*/} # strip leading path

	## build message prefix based on calling function
	local messagePrefix=
	case "${callingFunction}" in
		## main execution/no function
		main)
			messagePrefix="{${bashFileName}:${bashLineNumber}}: "
			;;
		## __die function
		#__die)
		#	messagePrefix="{${bashFileName}:${bashLineNumber}}, ${callingFunction}(): "
		#	;;
		## we were called by any other function
		*)
			## use the calling function as message prefix
			messagePrefix="{${bashFileName}:${bashLineNumber}}, ${callingFunction}(): "
			;;
	esac

	## populate local messsage array
	local -a messageArray
	if [[ -z ${message} ]]; then
		## no message argument given, so read stdin
		## and append every line to the message array
		while read; do
			messageArray+=( "${REPLY}" )
		done
	else
		## single message argument
		messageArray=( "${messagePrefix}${message}" )
	fi

	## loop through local message array
	## and process messages:
	## - add message to global message array
	## - print message
	## - log message
	local -i m
	for ((m = 0; m < ${#messageArray[@]}; m++)); do

		## current message
		local currentMessage=${messageArray[m]}

		## append current message to the global message array
		__MsgArray+=( "${timestamp}|${severity}|${currentMessage}" )

		## only print current message if quiet operation isn't enabled
		if [[ ${quiet} -ne 1 ]]; then
			__msgPrint "${timestamp}" "${severity}" "${currentMessage}"
		fi

		## log current message
		__msgLog "${timestamp}" "${severity}" "${currentMessage}"

	done

	return 0 # success

} # __msg()

function __mail() {

	## ----- head -----
	##
	## DESCRIPTION:
	##   sends the contents of stdin via mail
	##
	## ARGUMENTS:
	##   1: mailFrom (req): Some User <some.user@example.com>
	##   2: mailEnvelopeFrom (req): some.user@example.com
	##   3: mailRecipient (req): some.user@example.com
	##   4: mailSubject (req): Messages from thisscript
	##
	## GLOBAL VARIABLES USED:
	##   __ScriptFile
	##   __ScriptHost
	##   __SendmailBin (default: /usr/sbin/sendmail)
	##   __SendmailArgs (default: -t)
	##

	local mailFrom=${1}
	if [[ -z "${mailFrom}" ]]; then
		__msg err "argument 1 (mailFrom) missing"
		return 2 # error
	fi
	__msg debug "mailFrom: ${mailFrom}"

	local mailEnvelopeFrom=${2}
	if [[ -z "${mailEnvelopeFrom}" ]]; then
		__msg err "argument 2 (mailEnvelopeFrom) missing"
		return 2 # error
	fi
	__msg debug "mailEnvelopeFrom: ${mailEnvelopeFrom}"

	local mailRecipient=${3}
	if [[ -z "${mailRecipient}" ]]; then
		__msg err "argument 3 (mailRecipient) missing"
		return 2 # error
	fi
	__msg debug "mailRecipient: ${mailRecipient}"

	local mailSubject=${4}
	if [[ -z "${mailSubject}" ]]; then
		__msg err "argument 4 (mailSubject) missing"
		return 2 # error
	fi
	__msg debug "mailSubject: ${mailSubject}"

	## ---- main -----

	## get current timestamp
	local timestamp=$(date "+%Y-%m-%d %H:%M:%S" 2>/dev/null)

	## read stdin and append every line to the body array
	local -a mailBodyArray
	while read; do
		mailBodyArray+=( "${REPLY}" )
	done

	## sendmail arguments
	local sendmailArgs="${__SendmailArgs:--t}"

	## send mail via sendmail
	{
		echo "From: ${mailFrom}"
		echo "To: ${mailRecipient}"
		echo "Subject: ${mailSubject}"
		echo
		local -i i
		for ((i = 0; i < ${#mailBodyArray[@]}; i++)); do
			echo "${mailBodyArray[i]}"
		done
		echo
		echo "-- "
		echo "sent by ${__ScriptFile} running on ${__ScriptHost} at ${timestamp}"
	} | "${__SendmailBin:-/usr/sbin/sendmail}" -f "${mailEnvelopeFrom}" ${sendmailArgs} >>"${_L:-/dev/null}" 2>&1
	local -i sendmailExitCode=${?}
	case ${sendmailExitCode} in
		0)
			__msg debug "successfully sent mail via sendmail"
			;;
		*)
			__msg err "failed sending mail via sendmail (sendmail exit code: ${sendmailExitCode})"
			return 1
			;;
	esac

	return 0 # success

} # __mail()

function __msgMail() {

	## ----- head -----
	##
	## DESCRIPTION:
	##   sends all saved messages (and script subcommand log, if enabled) via mail
	##
	## ARGUMENTS:
	##   /
	##
	## GLOBAL VARIABLES USED:
	##   __MailDebug
	##   __MailInfo
	##   __MailNotice
	##   __MailWarning
	##   __MailErr
	##   __MailCrit
	##   __MailAlert
	##   __MailEmerg
	##   __MailPrefixTimestamp
	##   __MailFrom
	##   __MailEnvelopeFrom
	##   __MailRecipient
	##   __MailSubject
	##   __MsgArray
	##   __ScriptFile
	##   __ScriptHost
	##

	local mailFrom=${__MailFrom:-${USER} <${USER}@${__ScriptHost}>}
	local mailEnvelopeFrom=${__MailEnvelopeFrom:-${USER}@${__ScriptHost}}
	local mailRecipient=${__MailRecipient:-${USER}@${__ScriptHost}}
	local mailSubject=${__MailSubject:-Messages from ${__ScriptFile} running on ${__ScriptHost}}

	## ----- main -----

	## check whether the global message array contains any messages at all
	if [[ ${#__MsgArray[@]} -eq 0 ]]; then
		return 0
	fi

	## initialize mail message array
	local -a mailMessageArray

	## loop through global message array
	local -i i=0
	for ((i = 0; i < ${#__MsgArray[@]}; i++)); do
		IFS='|'
		set -- ${__MsgArray[i]}
		unset IFS
		local timestamp=${1}; shift
		local severity=${1}; shift
		local message=${@}
		set --

		## check whether message is to be mailed at all
		case ${severity} in
			  debug) if [[ ${__MailDebug:-0}   -ne 1 ]]; then continue; fi ;;
			   info) if [[ ${__MailInfo:-1}    -ne 1 ]]; then continue; fi ;;
			 notice) if [[ ${__MailNotice:-1}  -ne 1 ]]; then continue; fi ;;
			warning) if [[ ${__MailWarning:-1} -ne 1 ]]; then continue; fi ;;
			    err) if [[ ${__MailErr:-1}     -ne 1 ]]; then continue; fi ;;
			   crit) if [[ ${__MailCrit:-1}    -ne 1 ]]; then continue; fi ;;
			  alert) if [[ ${__MailAlert:-1}   -ne 1 ]]; then continue; fi ;;
			  emerg) if [[ ${__MailEmerg:-1}   -ne 1 ]]; then continue; fi ;;
		esac

		## mapping severity -> prefix
		local prefix
		case ${severity} in
			  debug) prefix="[____DEBUG] " ;;
			   info) prefix="[_____INFO] " ;;
			 notice) prefix="[___NOTICE] " ;;
			warning) prefix="[__WARNING] " ;;
			    err) prefix="[____ERROR] " ;;
			   crit) prefix="[_CRITICAL] " ;;
			  alert) prefix="[____ALERT] " ;;
			  emerg) prefix="[EMERGENCY] " ;;
		esac

		## prefix message with timestamp?
		case ${__MailPrefixTimestamp:-1} in
			1) prefix="${timestamp} ${prefix}" ;;
			*) ;;
		esac

		## push final message into array
		mailMessageArray+=( "${prefix}${message}" )
	done

	## check whether the mail message array contains any messages at all
	if [[ ${#mailMessageArray[@]} -eq 0 ]]; then
		return 0
	fi

	## send mail
	{
		## print all messages that are to be mailed
		for ((i = 0; i < ${#mailMessageArray[@]}; i++)); do
			echo "${mailMessageArray[i]}"
		done
		## append script subcommand log?
		if [[ ${__MailAppendScriptSubCommandLog:-1} -eq 1 \
			&& ${__ScriptSubCommandLog:-0} -eq 1 \
			&& ${__ScriptSubCommandLogFile} != /dev/null \
			&& -s ${__ScriptSubCommandLogFile} ]]; then
			echo
			echo "--8<--[ start of script subcommand log (${__ScriptSubCommandLogFile}) ]--8<--"
			cat "${__ScriptSubCommandLogFile}" 2>/dev/null
			echo "--8<--[ end of script subcommand log ]--8<--"
		fi
	} | __mail \
		"${mailFrom}" \
		"${mailEnvelopeFrom}" \
		"${mailRecipient}" \
		"${mailSubject}"
	local -i returnValue=${?}
	case ${returnValue} in
		0)
			__msg debug "successfully sent mail"
			;;
		2)
			__msg err "failed sending mail"
			return 2 # error
			;;
		*)
			__msg err "undefined return value: ${returnValue}"
			return 2 # error
			;;
	esac

	return 0 # success

} # __msgMail()

##
## trap functions
##

function __trapExit() {

	## ----- head -----
	##
	## DESCRIPTION:
	##   trap function for script exits
	##
	## ARGUMENTS:
	##   /
	##
	## GLOBAL VARIABLES USED:
	##   /
	##

	## ----- main -----

	## mail saved messages
	__msgMail
	local -i returnValue=${?}
	case ${returnValue} in
		0)
			__msg debug "successfully mailed saved messages"
			;;
		2)
			__msg err "failed mailing saved messages"
			return 2 # error
			;;
		*)
			__msg err "undefined return value: ${returnValue}" ##
			return 2 # error
			;;
	esac

	return 0 # success

} # __trapExit()

## enable the __trapExit function for script exits
trap "__trapExit" EXIT

function __trapSignals() {

	## ----- head -----
	##
	## DESCRIPTION:
	##   trap function for script signals
	##
	## ARGUMENTS:
	##   1: signal (req): signal that was trapped
	##
	## GLOBAL VARIABLES USED:
	##   /
	##

	local signal=${1}
	if [[ -z "${signal}" ]]; then
		__msg err "argument 1 (signal) missing"
		return 2 # error
	fi
	__msg debug "signal: ${signal}"

	## ----- main -----

	case ${signal} in
		SIGHUP)
			__msg notice "received hangup signal"
			exit 2
			;;
		SIGINT)
			__msg notice "received interrupt from keyboard"
			exit 2
			;;
		SIGQUIT)
			__msg notice "received quit from keyboard"
			exit 2
			;;
		SIGABRT)
			__msg notice "received abort signal"
			exit 2
			;;
		SIGPIPE)
			__msg notice "broken pipe"
			exit 2
			;;
		SIGALRM)
			__msg notice "received alarm signal"
			exit 2
			;;
		SIGTERM)
			__msg notice "received termination signal"
			exit 2
			;;
		*)
			__msg notice "trapped signal ${signal}"
			;;
	esac

	return 0 # success

} # __trapSignals()

## enable the __trapSignals function for certain signals:
declare -a __TrapSignals=(
	SIGHUP  # 1
	SIGINT  # 2 (^C)
	SIGQUIT # 3 (^\)
	SIGABRT # 6
	SIGPIPE # 13
	SIGALRM # 14
	SIGTERM # 15
)
for signal in "${__TrapSignals[@]}"; do
	trap "__trapSignals ${signal}" "${signal}"
done

##
## misc helper functions
##

function __includeSource() {

	## ----- head -----
	##
	## DESCRIPTION:
	##   source a file
	##
	## ARGUMENTS:
	##   1: file: the file to include
	##
	## GLOBAL VARIABLES USED:
	##   _L
	##

	local file=${1}

	## ----- main -----

	if ! source "${file}" >>"${_L:-/dev/null}" 2>&1; then
		__msg crit "failed to include source file '${file}'"
		return 2 # error
	fi

	return 0 # success

} # __includeSource()

function __requireSource() {

	## ----- head -----
	##
	## DESCRIPTION:
	##   source a file and die on failure
	##
	## ARGUMENTS:
	##   1: file: the file to include
	##
	## GLOBAL VARIABLES USED:
	##   _L
	##

	local file=${1}

	## ----- main -----

	if ! source "${file}" >>"${_L:-/dev/null}" 2>&1; then
		__die 2 "failed to include required source file '${file}'"
	fi

	return 0 # success

} # __requireSource()

function __addPrefix() {

	## ----- head -----
	##
	## DESCRIPTION:
	##   add a prefix to a line of text read from stdin
	##
	## ARGUMENTS:
	##   /
	##
	## GLOBAL VARIABLES USED:
	##   /
	##

	## ----- main -----

	sed -e "s/^/[${@}] /"

} # __addPrefix()
