# More Mac setup at https://mac.iamdeveloper.com
# Taken from https://gist.github.com/nickytonline/729fc106a0146345c0b90f3356a41e4d

# Log file
timestamp=$(date +%s)
logFile="./machineSetup-$timestamp.log"

# if true is passed in, things will reinstall
reinstall=$1

beginInstallation() {
  echo "Starting installation for $1..." | tee -a $logFile
}

installComplete() {
  echo "Installation complete for $1.\n\n\n" | tee -a $logFile
}

# List of applications to install via brew
declare -a brewApps=("git" "github/gh/gh" "nvm", "brew-gem", "fastlane", "cocoapods", "Swiftlint", "gitlab-runner")

# List of applications to install via brew cask
declare -a brewCaskApps=("android-studio")

# Global node packages to install
declare -a globalNodePackages=("npm@latest" "@ionic/cli")

# List of applications to start right away
declare -a appsToStartRightAway=()

echo "Installing command line tools" | tee -a $logFile
xcode-select --install

# https://stackoverflow.com/a/26647594/77814
echo "Setting correct permissions on folders that brew needs acccess to."
sudo chown -R `whoami`:admin /usr/local/bin
sudo chown -R `whoami`:admin /usr/local/share

# Install applications
echo "Installing applications. You may be prompted at certain points to provide your password." | tee -a $logFile

command -v brew >/dev/null 2>&1 || {
  beginInstallation "Homebrew"

  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  installComplete "Homebrew"

  beginInstallation "Homebrew Cask"
  brew tap caskroom/cask
  installComplete "Homebrew Cask"
} | tee -a $logFile

#echo "Setting GitHub CLI protocol to SSH" | tee -a $logFile
#gh config set git_protocol ssh

echo "Setting up some brew tap stuff for fonts and some applications" | tee -a $logFile
brew tap caskroom/versions | tee -a $logFile
brew tap caskroom/fonts | tee -a $logFile
echo "Finished setting up some brew tap stuff for fonts and some applications" | tee -a $logFile

for appName in "${brewApps[@]}"
do
  beginInstallation $appName | tee -a $logFile

  if [ $reinstall=true ]; then
    brew reinstall $appName | tee -a $logFile
  else
    brew install $appName | tee -a $logFile
  fi

  installComplete $appName | tee -a $logFile
done

for appName in "${brewCaskApps[@]}"
do
  beginInstallation $appName | tee -a $logFile

  if [ $reinstall=true ]; then
    brew cask reinstall $appName | tee -a $logFile
  else
    brew cask install $appName | tee -a $logFile
  fi

  installComplete $appName | tee -a $logFile
done

beginInstallation "Setting up node.js" | tee -a $logFile

export NVM_DIR="$HOME/.nvm"
mkdir $NVM_DIR

[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm

echo "Installing LTS version of node."
nvm install --lts
nvm alias default "lts/*"
nvm use default
installComplete "Finished installing node.js." | tee -a $logFile

beginInstallation "Installing global node packages" | tee -a $logFile
npm i -g "${globalNodePackages[@]}" | tee -a $logFile
installComplete "Finished installing global node packages." | tee -a $logFile

echo "Done installing applications" | tee -a $logFile
echo "\n\n\n" | tee -a $logFile
echo "Just a few final touches..." | tee -a $logFile

# Make zsh the default shell
echo "Making zsh the default shell" | tee -a $logFile

sudo dscl . -create /Users/$USER UserShell /usr/local/bin/zsh | tee -a $logFile
echo which zsh | tee -a $logFile
dscl . -read /Users/$USER UserShell | tee -a $logFile
echo $SHELL | tee -a $logFile
chsh -s $(which zsh) | tee -a $logFile

echo "Creating .zshrc file" | tee -a $logFile
touch ~/.zshrc | tee -a $logFile
echo "
export NODE=/usr/local/bin
export PATH=$NODE:$PATH
export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
export PUPPETEER_EXECUTABLE_PATH=`which chromium`

test -e \"${HOME}/.iterm2_shell_integration.zsh\" && source \"${HOME}/.iterm2_shell_integration.zsh\"

export LANG=en_US.UTF-8
export ANDROID_SDK=/Library/Android/sdk/platform-tools
export PATH=$ANDROID_SDK:$PATH
export JAVA_HOME=\"/Applications/Android Studio.app/Contents/jre/Contents/Home\"
export PATH=$JAVA_HOME:$PATH
export NVM_DIR=\"$HOME/.nvm\"
[ -s \"$NVM_DIR/nvm.sh\" ] && \. \"$NVM_DIR/nvm.sh\"  # This loads nvm
[ -s \"$NVM_DIR/bash_completion\" ] && \. \"$NVM_DIR/bash_completion\"  # This loads nvm bash_completion
export PATH=\"/usr/local/opt/openjdk@11/bin:$PATH\"" > ~/.zshrc | tee -a $logFile

echo "Testing zsh prompt" | tee -a $logFile
zsh | tee -a $logFile

echo "Installing xcode"
gem install xcode-install | tee -a $logFile
xcversion install 13.4.1 | tee -a $logFile

echo "Configuring gitlab runner"
#Does this need to be sudo?
gitlab-runner install | tee -a $logFile
chmod -R drwxrwx--- /etc/gitlab-runner | tee -a $logFile
cd /etc/gitlab-runner | tee -a $logFile
echo "
concurrent = 4 \n
check_interval = 0 \n
\n
[session_server] \n
\t  session_timeout = 1800 \n
\n
[[runners]] \n
\t  name = \"unanet crm build mac\" \n
\t  url = \"https://gitlab.unanet.io\" \n
\t  token = \"wom836bsjVhzUCqH4Lg5\" \n
\t  executor = \"shell\" \n
\t  request_concurrency = 4 \n
\t  [runners.custom_build_dir] \n
\t  [runners.cache] \n
\t\t   [runners.cache.s3] \n
\t\t   [runners.cache.gcs] \n
\t\t   [runners.cache.azure] \n
" > config.toml | tee -a $logFile
cd ../ | tee -a $logFile
chmod -R drwxr----- /etc/gitlab-runner | tee -a $logFile
gitlab-runner start | tee -a $logFile

echo "A setup log is available at $logFile."
