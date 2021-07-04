
# MacPorts Installer addition on 2021-04-15_at_16:57:34: adding an appropriate PATH variable for use with MacPorts.
export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
# Finished adapting your PATH environment variable for use with MacPorts.

# Use GNU coreutils by default
#export PATH=/opt/local/libexec/gnubin/:$PATH # (04/25/2021) nevermind

# MacPorts Installer addition on 2021-04-15_at_16:57:34: adding an appropriate DISPLAY variable for use with MacPorts.
export DISPLAY=:0
# Finished adapting your DISPLAY environment variable for use with MacPorts.

export MANPATH=/opt/local/share/man:$MANPATH

## NOTE(dabrady) Copied from .bash_profile, which is where `conda init` puts it :p
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/local/bin/miniforge3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/local/bin/miniforge3/etc/profile.d/conda.sh" ]; then
        . "/opt/local/bin/miniforge3/etc/profile.d/conda.sh"
    else
        export PATH="/opt/local/bin/miniforge3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
