The /root/execute folder
========================

Any script put in here, ending in .sh will be pulled and executed on the EC2
server.

If executed without errors, a tag will be put in /root/execute-done on that
server, preventing it from being executed in the future.

The script(s) are executed in sorted, ascending order, and therefore it is vital
to use an appropriate naming scheme to ensure some kind of sequence. Suggested
naming scheme is:
    YYYY-MM-DD.HHMM-descriptive-name.sh
