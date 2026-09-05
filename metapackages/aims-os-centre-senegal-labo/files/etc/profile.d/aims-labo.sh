# AIMS OS labo — shared SDKs installed by aims-labo-extras
[ -d /opt/android-sdk ] && export ANDROID_HOME=/opt/android-sdk ANDROID_SDK_ROOT=/opt/android-sdk
[ -d /opt/android-sdk/platform-tools ] && PATH="$PATH:/opt/android-sdk/platform-tools"
[ -d /opt/android-studio/bin ] && PATH="$PATH:/opt/android-studio/bin"
[ -d /opt/julia/bin ] && PATH="$PATH:/opt/julia/bin"
[ -d /opt/ghidra ] && PATH="$PATH:/opt/ghidra"
export PATH
