#!/bin/bash
#
# Executes the specified script from /root/execute and, if no errors occur,
# marks it as excuted so that it won't be executed once more.

echo "Executing $1 once ..."

if [[ ! -f "$1" ]]; then
    echo "'$1' does not exist"
    exit 1
fi

[[ -d /root/execute-done ]] || mkdir /root/execute-done

# Already executed?
TAG=$(echo $1|sed -E 's:/execute/:/execute-done/:')
[[ -e "$TAG" ]] && echo "$1 has already been run" && exit 0

# Nope. Let's do it:
"$1"

EXITCODE=$?

[[ "$EXITCODE" != "0" ]] && exit $EXITCODE

touch "$TAG"
