#!/bin/bash
#
# Kills stalled init.d Myproject scripts pid after a given number of seconds.
# 
# Pass on --shout if you want to email home on errors.

# How many seconds a script must have been running for us to actively kill it.
TIMEOUT=420

PREV_IFS=$IFS
IFS=$'\n'

. /.env

shout()
{
    echo "$2" | mail -s "$1" -t $EMAIL_RECIPIENT -a FROM:"Watchdog on $EMAIL_SENDER"
    return 0
}

# Get a list of all running processes, minus the watchdog script and our grep statement:
PROCESSES=$(ps -eo pid,etime,args|grep '/bin/bash /etc/init.d/myproject-'|grep -v grep|grep -v 'myproject-watchdog')

[[ "$PROCESSES" = "" ]] &&
    echo "There are no running Myproject init.d processes" &&
    exit 0

PR_PID=""
PR_SCRIPT=""
PR_ELAPSED=""

for PROCESS in $PROCESSES; do
    # The output is something like,
    #  3731       01:10 /bin/bash /etc/init.d/myproject-update-env-vars start
    #  3864       00:08 /bin/bash /etc/init.d/myproject-pull-application-code
    #  3865       00:08 /bin/bash /etc/init.d/myproject-pull-server-conf
    #  
    #  We need the process id, the number of minutes and seconds, and the script name without path.
    if [[ $PROCESS =~ ^\ *([0-9]+)\ +([0-9]+):([0-9]+).+\/etc\/init.d\/(myproject\-[^\ ]+) ]]; then
        
        PR_PID=${BASH_REMATCH[1]}
        PR_SCRIPT=${BASH_REMATCH[4]}
        PR_ELAPSED=$((10#${BASH_REMATCH[2]} * 60 + 10#${BASH_REMATCH[3]}))
        
        if [[ $PR_ELAPSED -gt $TIMEOUT ]]; then
            KILL_COUNT=$((KILL_COUNT + 1))
            
            echo "$PR_SCRIPT (PID: $PR_PID) has run for more than $TIMEOUT seconds ($PR_ELAPSED), killing it ..."
            kill -9 $PR_PID
            
            if [[ "$?" = "0" ]]; then
                echo "Killed"
                
                [[ "$1" = "--shout" ]] && shout "$PR_SCRIPT killed by watchdog" "Killed after $PR_ELAPSED seconds ${NL2}Captured output: $NL2$(cat /tmp/$PR_SCRIPT.output)"
                
                rm -f /tmp/$PR_SCRIPT.output
            else
                echo "Failed"
                
                [[ "$1" = "--shout" ]] && shout "$PR_SCRIPT failed to be killed by watchdog" "Attempt was made after $PR_ELAPSED seconds ${NL2}Captured output: $NL2$(cat /tmp/$PR_SCRIPT.output)"
            fi
        else
            echo "$PR_SCRIPT (PID: $PR_PID) has only run for $PR_ELAPSED seconds, not touching ..."
        fi
    fi
done

IFS=$PREV_IFS
