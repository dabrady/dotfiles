########################################
# User configuration
#########################################

# Enable more powerful globbing
setopt extended_glob

# For riak happiness, upgrade open file limit
ulimit -n 200000
ulimit -u 2048
