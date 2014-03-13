## $Id: bashinator.cfg.sh,v 1.3 2009/05/15 14:17:16 wschlich Exp wschlich $
## vim:ts=4:sw=4:tw=200:nu:ai:nowrap:

##
## bashinator settings
##

## -- bashinator basic settings --

export __ScriptSubCommandLog=1 # log stdout and/or stderr of subcommands to a file -- default: 0
export __ScriptSubCommandLogDir="/tmp" # default: /var/log
export __ScriptLock=0 # create/check lockfile -- default: 0
export __ScriptLockDir="/tmp" # default: /var/lock

## -- bashinator message handling settings --

## enable quiet operation: nothing is printed on stdout/stderr,
## messages are only logged and/or mailed (if enabled).
## overrides __Print* variables!
## it should be possible to enable this by passing -q to the script.
#export __MsgQuiet=0 # default: 0

## timestamp format for the message functions,
## will be passed to date(1).
## default: "%Y-%m-%d %H:%M:%S %:z"
export __MsgTimestampFormat="[%Y-%m-%d %H:%M:%S %:z]"

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

## enable/disable prefixing the message(s) to be printed with its timestamp
export __PrintPrefixTimestamp=1 # default: 1

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

## enable/disable prefixing the message(s) to be logged with its timestamp (ignored for syslog log target)
export __LogPrefixTimestamp=1 # default: 1

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

## enable/disable prefixing the message(s) to be mailed with its timestamp
export __MailPrefixTimestamp=1 # default: 1

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
