## $Id: bashinator.cfg.sh,v 1.6 2010/05/13 18:16:33 wschlich Exp wschlich $
## vim:ts=4:sw=4:tw=200:nu:ai:nowrap:

##
## bashinator settings
##

## -- bashinator basic settings --

export __ScriptSubCommandLog=1 # log stdout and/or stderr of subcommands to a file -- default: 0
export __ScriptSubCommandLogDir="/tmp" # default: /var/log
export __ScriptLock=0 # create/check lockfile -- default: 0
export __ScriptLockDir="/tmp" # default: /var/lock

## use a safe PATH environment variable instead
## of the one supplied by the calling environment:
## - when running as non-root user: /bin:/usr/bin
## - when running as super user: /sbin:/usr/sbin:/bin:/usr/bin
export __ScriptUseSafePathEnv=0 # default: 1

## set the umask
export __ScriptUmask=022 # default: 077

## -- bashinator message handling settings --

## enable quiet operation: nothing is printed on stdout/stderr,
## messages are only logged and/or mailed (if enabled).
## overrides __Print* variables!
## it should be possible to enable this by passing -q
## as an argument to your own application script.
#export __MsgQuiet=0 # default: 0

## timestamp format for the message functions,
## will be passed to date(1).
## default: "%Y-%m-%d %H:%M:%S %:z"
export __MsgTimestampFormat="[%Y-%m-%d %H:%M:%S %:z]" # with brackets
#export __MsgTimestampFormat="[%Y-%m-%d %H:%M:%S.%N %:z]" # with brackets and nanoseconds

## -- bashinator message printing settings --

## enable/disable printing of messages by severity
export __PrintDebug=1   # default: 0
export __PrintInfo=1    # default: 1
export __PrintNotice=1  # default: 1
export __PrintWarning=1 # default: 1
export __PrintErr=1     # default: 1
export __PrintCrit=1    # default: 1
export __PrintAlert=1   # default: 1
export __PrintEmerg=1   # default: 1

## enable/disable prefixing the messages to be printed with...
##
## ...their timestamp
export __PrintPrefixTimestamp=1 # default: 1
##
## ...their severity
export __PrintPrefixSeverity=1 # default: 1
##
## ...their source (file name, line number and function name)
export __PrintPrefixSource=1 # default: 1

## print severity prefixes
export __PrintPrefixSeverity7=">>> [____DEBUG]" # LOG_DEBUG
export __PrintPrefixSeverity6=">>> [_____INFO]" # LOG_INFO
export __PrintPrefixSeverity5=">>> [___NOTICE]" # LOG_NOTICE
export __PrintPrefixSeverity4="!!! [__WARNING]" # LOG_WARNING
export __PrintPrefixSeverity3="!!! [____ERROR]" # LOG_ERR
export __PrintPrefixSeverity2="!!! [_CRITICAL]" # LOG_CRIT
export __PrintPrefixSeverity1="!!! [____ALERT]" # LOG_ALERT
export __PrintPrefixSeverity0="!!! [EMERGENCY]" # LOG_EMERG

## print severity colors (for the entire message, not just the prefix)
export __PrintColorSeverity7="1;34"    # LOG_DEBUG:   blue on default
export __PrintColorSeverity6="1;36"    # LOG_INFO:    cyan on default
export __PrintColorSeverity5="1;32"    # LOG_NOTICE:  green on default
export __PrintColorSeverity4="1;33"    # LOG_WARNING: yellow on default
export __PrintColorSeverity3="1;31"    # LOG_ERR:     red on default
export __PrintColorSeverity2="1;37;41" # LOG_CRIT:    white on red
export __PrintColorSeverity1="1;33;41" # LOG_ALERT:   yellow on red
export __PrintColorSeverity0="1;37;45" # LOG_EMERG:   white on magenta

## -- bashinator message logging settings --

## enable/disable logging of messages by severity
export __LogDebug=1   # default: 0
export __LogInfo=1    # default: 1
export __LogNotice=1  # default: 1
export __LogWarning=1 # default: 1
export __LogErr=1     # default: 1
export __LogCrit=1    # default: 1
export __LogAlert=1   # default: 1
export __LogEmerg=1   # default: 1

## enable/disable prefixing the messages to be logged with...
##
## ...their timestamp (ignored for syslog log target)
export __LogPrefixTimestamp=1 # default: 1
##
## ...their severity (ignored for syslog log target)
export __LogPrefixSeverity=1 # default: 1
##
## ...their source (file name, line number and function name)
export __LogPrefixSource=1 # default: 1

## log severity prefixes
export __LogPrefixSeverity7=">>> [____DEBUG]" # LOG_DEBUG
export __LogPrefixSeverity6=">>> [_____INFO]" # LOG_INFO
export __LogPrefixSeverity5=">>> [___NOTICE]" # LOG_NOTICE
export __LogPrefixSeverity4="!!! [__WARNING]" # LOG_WARNING
export __LogPrefixSeverity3="!!! [____ERROR]" # LOG_ERR
export __LogPrefixSeverity2="!!! [_CRITICAL]" # LOG_CRIT
export __LogPrefixSeverity1="!!! [____ALERT]" # LOG_ALERT
export __LogPrefixSeverity0="!!! [EMERGENCY]" # LOG_EMERG

## log target configuration
## supported targets (any comma separated combination of):
## - "syslog:FACILITY"
## - "file:TARGET-FILE"
## - "file:TARGET-FILE:WRITE-MODE" (default WRITE-MODE: overwrite)
## default: "syslog:user"
export __LogTarget="syslog:user"
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
export __MailInfo=1    # default: 1
export __MailNotice=1  # default: 1
export __MailWarning=1 # default: 1
export __MailErr=1     # default: 1
export __MailCrit=1    # default: 1
export __MailAlert=1   # default: 1
export __MailEmerg=1   # default: 1

## enable/disable prefixing the messages to be mailed with...
##
## ...their timestamp
export __MailPrefixTimestamp=1 # default: 1
##
## ...their severity
export __MailPrefixSeverity=1 # default: 1
##
## ...their source (file name, line number and function name)
export __MailPrefixSource=1 # default: 1

## mail severity prefixes
export __MailPrefixSeverity7="[____DEBUG]" # LOG_DEBUG
export __MailPrefixSeverity6="[_____INFO]" # LOG_INFO
export __MailPrefixSeverity5="[___NOTICE]" # LOG_NOTICE
export __MailPrefixSeverity4="[__WARNING]" # LOG_WARNING
export __MailPrefixSeverity3="[____ERROR]" # LOG_ERR
export __MailPrefixSeverity2="[_CRITICAL]" # LOG_CRIT
export __MailPrefixSeverity1="[____ALERT]" # LOG_ALERT
export __MailPrefixSeverity0="[EMERGENCY]" # LOG_EMERG

## enable/disable appending the script subcommand log to the mail (if enabled)
export __MailAppendScriptSubCommandLog=1 # default: 1

## mail data configuration
## default __MailFrom:         "${USER} <${USER}@${__ScriptHost}>"
## default __MailEnvelopeFrom: "${USER}@${__ScriptHost}"
## default __MailRecipient:    "${USER}@${__ScriptHost}"
## default __MailSubject:      "Messages from ${__ScriptFile} running on ${__ScriptHost}"
export __MailFrom="${USER} <${USER}@${__ScriptHost}>"
export __MailEnvelopeFrom="${USER}@${__ScriptHost}"
export __MailRecipient="${USER}@${__ScriptHost}"
export __MailSubject="Messages from ${__ScriptFile} running on ${__ScriptHost}"
