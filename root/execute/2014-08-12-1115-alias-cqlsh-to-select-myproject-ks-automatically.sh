#!/bin/bash

echo "Aliasing cqlsh to cqlsh -k myproject so that we open the shell directly in the myproject keyspace ..."

echo "alias cqlsh='cqlsh -k myproject'" >> /home/daniel/.bashrc &&
echo "alias cqlsh='cqlsh -k myproject'" >> /home/jimmy/.bashrc &&
echo "
alias cqlsh='cqlsh -k myproject'" >> /root/.bashrc &&
exit 0

exit 1