## vim:ts=4:sw=4:tw=200:nu:ai:nowrap:
##
## bashinator config for bashinator example application
##
## Created by Wolfram Schlich <wschlich@gentoo.org>
## Licensed under the GNU GPLv3
## Web: http://www.bashinator.org/
## Code: https://github.com/wschlich/bashinator/
##

##
## bashinator settings
##

## -- bashinator basic settings --

## log stdout and/or stderr of subcommands to a file.
## the output of all subcommands need to be manually redirected to the logfile
## contained in the variable _L which is automatically defined by bashinator.
##
## examples:
##
## - redirect stdout + stderr to the logfile:
##   mkdir /foo &> "${_L}"
##
## - redirect only stderr to the logfile, so stdout can be processed as usual:
##   grep localhost /etc/hosts 2> "${_L}"
##
export __ScriptSubCommandLog=1 # default: 0
## directory to create logfile in
export __ScriptSubCommandLogDir="/tmp" # default: /var/log

## check for a lockfile on startup and error out if it exists, create it otherwise
export __ScriptLock=1 # default: 0
## directory to create lockfile in
export __ScriptLockDir="/tmp" # default: /var/lock

## use a safe PATH environment variable instead
## of the one supplied by the calling environment:
## - when running as non-root user: /bin:/usr/bin
## - when running as super user: /sbin:/usr/sbin:/bin:/usr/bin
#export __ScriptUseSafePathEnv=0 # default: 1

## set the umask
export __ScriptUmask=022 # default: 077

## generate a stack trace when the __die() function is called (fatal errors)
## affects printing, mailing and logging!
#export __ScriptGenerateStackTrace=0 # default: 1

## -- bashinator message handling settings --

## enable quiet operation: nothing is printed on stdout/stderr,
## messages are only logged and/or mailed (if enabled).
## overrides __Print* variables!
## it should be possible to enable this by passing -q
## as an argument to your own application script.
#export __MsgQuiet=1 # default: 0

## timestamp format for the message functions,
## will be passed to date(1).
## default: "%Y-%m-%d %H:%M:%S %:z"
export __MsgTimestampFormat="[%Y-%m-%d %H:%M:%S %:z]" # with brackets
#export __MsgTimestampFormat="[%Y-%m-%d %H:%M:%S.%N %:z]" # with brackets and nanoseconds

## -- bashinator message printing settings --

## enable/disable printing of messages by severity
export __PrintDebug=1   # default: 0
#export __PrintInfo=0    # default: 1
#export __PrintNotice=0  # default: 1
#export __PrintWarning=0 # default: 1
#export __PrintErr=0     # default: 1
#export __PrintCrit=0    # default: 1
#export __PrintAlert=0   # default: 1
#export __PrintEmerg=0   # default: 1

## enable/disable prefixing the messages to be printed with...
##
## ...their script name + pid
#export __PrintPrefixScriptNamePid=0 # default: 1
##
## ...their timestamp
#export __PrintPrefixTimestamp=0 # default: 1
##
## ...their severity
#export __PrintPrefixSeverity=0 # default: 1
##
## ...their source (file name, line number and function name)
#export __PrintPrefixSource=0 # default: 1

## print severity prefixes
#export __PrintPrefixSeverity7=">>> [____DEBUG]" # LOG_DEBUG
#export __PrintPrefixSeverity6=">>> [_____INFO]" # LOG_INFO
#export __PrintPrefixSeverity5=">>> [___NOTICE]" # LOG_NOTICE
#export __PrintPrefixSeverity4="!!! [__WARNING]" # LOG_WARNING
#export __PrintPrefixSeverity3="!!! [____ERROR]" # LOG_ERR
#export __PrintPrefixSeverity2="!!! [_CRITICAL]" # LOG_CRIT
#export __PrintPrefixSeverity1="!!! [____ALERT]" # LOG_ALERT
#export __PrintPrefixSeverity0="!!! [EMERGENCY]" # LOG_EMERG

## print severity colors (for the entire message, not just the prefix)
#export __PrintColorSeverity7="1;34"    # LOG_DEBUG:   blue on default
#export __PrintColorSeverity6="1;36"    # LOG_INFO:    cyan on default
#export __PrintColorSeverity5="1;32"    # LOG_NOTICE:  green on default
#export __PrintColorSeverity4="1;33"    # LOG_WARNING: yellow on default
#export __PrintColorSeverity3="1;31"    # LOG_ERR:     red on default
#export __PrintColorSeverity2="1;37;41" # LOG_CRIT:    white on red
#export __PrintColorSeverity1="1;33;41" # LOG_ALERT:   yellow on red
#export __PrintColorSeverity0="1;37;45" # LOG_EMERG:   white on magenta

## -- bashinator message logging settings --

## enable/disable logging of messages by severity
export __LogDebug=1   # default: 0
#export __LogInfo=0    # default: 1
#export __LogNotice=0  # default: 1
#export __LogWarning=0 # default: 1
#export __LogErr=0     # default: 1
#export __LogCrit=0    # default: 1
#export __LogAlert=0   # default: 1
#export __LogEmerg=0   # default: 1

## enable/disable prefixing the messages to be logged with...
##
## ...their script name + pid (ignored for syslog log target)
#export __LogPrefixScriptNamePid=0 # default: 1
##
## ...their timestamp (ignored for syslog log target)
#export __LogPrefixTimestamp=0 # default: 1
##
## ...their severity (ignored for syslog log target)
#export __LogPrefixSeverity=0 # default: 1
##
## ...their source (file name, line number and function name)
#export __LogPrefixSource=0 # default: 1

## log severity prefixes
#export __LogPrefixSeverity7=">>> [____DEBUG]" # LOG_DEBUG
#export __LogPrefixSeverity6=">>> [_____INFO]" # LOG_INFO
#export __LogPrefixSeverity5=">>> [___NOTICE]" # LOG_NOTICE
#export __LogPrefixSeverity4="!!! [__WARNING]" # LOG_WARNING
#export __LogPrefixSeverity3="!!! [____ERROR]" # LOG_ERR
#export __LogPrefixSeverity2="!!! [_CRITICAL]" # LOG_CRIT
#export __LogPrefixSeverity1="!!! [____ALERT]" # LOG_ALERT
#export __LogPrefixSeverity0="!!! [EMERGENCY]" # LOG_EMERG

## log target configuration
## supported targets (any comma separated combination of):
## - "syslog:FACILITY"
## - "file:TARGET-FILE"
## - "file:TARGET-FILE:WRITE-MODE" (default WRITE-MODE: overwrite)
## default: "syslog:user"
#export __LogTarget="syslog:user"
#export __LogTarget="file:/var/log/${__ScriptName}.log"
#export __LogTarget="file:/var/log/${__ScriptName}.log:append"
#export __LogTarget="file:/var/log/${__ScriptName}.log:overwrite"
#export __LogTarget="file:/var/log/${__ScriptName}.log:append,syslog:user"
#export __LogTarget="file:/var/log/${__ScriptName}.log:overwrite,syslog:user"
#export __LogTarget="file:/var/log/${__ScriptName}.log:append,file:/var/log/${__ScriptName}-current.log:overwrite"
#export __LogTarget="file:/var/log/${__ScriptName}.$(date +"%Y%m%d-%H%M%S").log"

## -- bashinator message mailing settings --

## enable/disable mailing of messages by severity
export __MailDebug=1   # default: 0
#export __MailInfo=0    # default: 1
#export __MailNotice=0  # default: 1
#export __MailWarning=0 # default: 1
#export __MailErr=0     # default: 1
#export __MailCrit=0    # default: 1
#export __MailAlert=0   # default: 1
#export __MailEmerg=0   # default: 1

## enable/disable prefixing the messages to be mailed with...
##
## ...their script name + pid
#export __MailPrefixScriptNamePid=1 # default: 0
##
## ...their timestamp
#export __MailPrefixTimestamp=0 # default: 1
##
## ...their severity
#export __MailPrefixSeverity=0 # default: 1
##
## ...their source (file name, line number and function name)
#export __MailPrefixSource=0 # default: 1

## mail severity prefixes
#export __MailPrefixSeverity7="[____DEBUG]" # LOG_DEBUG
#export __MailPrefixSeverity6="[_____INFO]" # LOG_INFO
#export __MailPrefixSeverity5="[___NOTICE]" # LOG_NOTICE
#export __MailPrefixSeverity4="[__WARNING]" # LOG_WARNING
#export __MailPrefixSeverity3="[____ERROR]" # LOG_ERR
#export __MailPrefixSeverity2="[_CRITICAL]" # LOG_CRIT
#export __MailPrefixSeverity1="[____ALERT]" # LOG_ALERT
#export __MailPrefixSeverity0="[EMERGENCY]" # LOG_EMERG

## enable/disable appending the script subcommand log to the mail (if enabled)
#export __MailAppendScriptSubCommandLog=0 # default: 1

## mail data configuration
## default __MailFrom:         "${USER} <${USER}@${__ScriptHost}>"
## default __MailEnvelopeFrom: "${USER}@${__ScriptHost}"
## default __MailRecipient:    "${USER}@${__ScriptHost}"
## default __MailSubject:      "Messages from ${__ScriptFile} running on ${__ScriptHost}"
#export __MailFrom="${USER} <${USER}@${__ScriptHost}>"
#export __MailEnvelopeFrom="${USER}@${__ScriptHost}"
#export __MailRecipient="${USER}@${__ScriptHost}"
#export __MailSubject="Messages from ${__ScriptFile} running on ${__ScriptHost}"
