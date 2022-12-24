########################################
# User configuration
#########################################

# I've started organizing config such as functions and aliases into namespaced "facets".
for file ($ZSH_CUSTOM/facets/*.zsh(N)); do
  source $file
done
unset file

# Enable more powerful globbing
setopt extended_glob

