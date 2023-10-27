# Log file
timestamp=$(date +%s)
logFile="./machineSetup-$timestamp.log"

echo "Installing Homebrew" | tee -a $logFile
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# List of applications to install via brew
brew install git | tee -a $logFile
brew install gh | tee -a $logFile
brew install brew-gem | tee -a $logFile
brew install fastlane | tee -a $logFile
brew install android-studio --cask | tee -a $logFile
brew install chromium --cask | tee -a $logFile
brew install node | tee -a $logFile
brew install jq | tee -a $logFile

# https://stackoverflow.com/a/26647594/77814
echo "Setting correct permissions on folders that brew needs acccess to." | tee -a $logFile
touch /usr/local
sudo chown -R `whoami`:admin /usr/local/bin
sudo chown -R `whoami`:admin /usr/local/share

# Make zsh the default shell
echo "Making zsh the default shell" | tee -a $logFile
source ~/.zshrc
sudo dscl . -create /Users/$USER UserShell /usr/local/bin/zsh | tee -a $logFile
echo which zsh | tee -a $logFile
dscl . -read /Users/$USER UserShell | tee -a $logFile
echo $SHELL | tee -a $logFile
chsh -s $(which zsh) | tee -a $logFile

echo "Installing NVM" | tee -a $logFile
NONINTERACTIVE=1 /bin/bash -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash"

# Global node packages to install
echo "Installing global NPM packages" | tee -a $logFile
npm config set strict-ssl false
npm i --location=global @ionic/cli
npm i --location=global @capacitor/cli
npm i --location=global corepack
npm i --location=global @sentry/cli

echo "Installing Gitlab Runner" | tee -a $logFile
sudo curl --output /usr/local/bin/gitlab-runner "https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-darwin-arm64"
sudo chmod +x /usr/local/bin/gitlab-runner

echo "Installing Sentry CLI" | tee -a $logFile
curl -sL https://sentry.io/get-cli/ | sh
touch ~/.sentryclirc
echo "[auth]\ntoken=c043da57cfe742a8b484b8d97a899f1406eb07f90b1b4a18a3a1e014a831949a" > ~/.sentryclirc

#Ruby Gems
echo "Installing rbenv" | tee -a $logFile
brew install rbenv | tee -a $logFile
echo "if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi" >> ~/.zshrc
source ~/.zshrc
rbenv install 3.2.0
rbenv global 3.2.0

echo "Installing Bundler" | tee -a $logFile
gem install bundler --user-install | tee -a $logFile
gem install fastlane-plugin-firebase_app_distribution --user-install| tee -a $logFile
sudo gem install cocoapods -v 1.11 | tee -a $logFile
gem install fastlane-plugin-firebase_app_distribution -v 0.7.4 --user-install | tee -a $logFile
gem install google-apis-firebaseappdistribution_v1 -v 0.3.0 --user-install | tee -a $logFile

#Update zshrc
echo "export ANDROID_SDK="$HOME/Library/Android/sdk/platform-tools"" > ~/.zshrc
echo "export JAVA_HOME="/Applications/Android\ Studio.app/Contents/jbr/Contents/Home/bin"" > ~/.zshrc
echo "export PATH="$ANDROID_SDK${PATH+:$PATH}"" > ~/.zshrc
echo "export PATH=$JAVA_HOME:$PATH" > ~/.zshrc
echo "export PATH="/Users/$USER/.gem/ruby/3.2.0/bin${PATH+:$PATH}"" > ~/.zshrc
source ~/.zshrc

echo "A setup log is available at $logFile."
