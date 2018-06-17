########################################
# User configuration
#########################################

# rbenv
eval "$(rbenv init -)"

# For riak happiness, upgrade open file limit
ulimit -n 200000
ulimit -u 2048

# android NDK
export ANDROID_HOME=$HOME/Library/Android/sdk
export ANDROID_NDK_HOME=$HOME/bin/android-ndk-r12b

# Java
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_102.jdk/Contents/Home
export ANT_HOME=$HOME/bin/apache-ant-1.10.1

# go-lang
export GO15VENDOREXPERIMENT=1 # special 'Vendoring' flag for tapjoy projects on 1.5.x
## Not needed if using GVM
#export GOPATH=$HOME/projects/go
#export PATH=$PATH:$GOPATH/bin
