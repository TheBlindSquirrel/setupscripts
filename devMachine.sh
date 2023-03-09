# Log file
timestamp=$(date +%s)
logFile="./machineSetup-$timestamp.log"

echo "Installing Homebrew" | tee -a $logFile
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo "Installing Bundler" | tee -a $logFile
sudo gem install bundler | tee -a $logFile
sudo gem install fastlane-plugin-firebase_app_distribution -v 0.3.8 | tee -a $logFile
sudo gem install cocoapods | tee -a $logFile

# List of applications to install via brew
brew install git | tee -a $logFile
brew install gh | tee -a $logFile
brew install brew-gem | tee -a $logFile
brew install fastlane | tee -a $logFile
brew install android-studio --cask | tee -a $logFile
brew install chromium --cask | tee -a $logFile
brew install jq | tee -a $logFile
brew install --cask visual-studio-code | tee -a $logFile
brew install --cask postman | tee -a $logFile
brew install --cask spotify | tee -a $logFile
brew install --cask slack | tee -a $logFile
brew install --cask burp-suite | tee -a $logFile
brew install --cask visual-studio | tee -a $logFile
brew install --cask azure-data-studio | tee -a $logFile
brew install swiftlint | tee -a $logFile
brew install --cask reflector | tee -a $logFile
brew install --cask vysor | tee -a $logFile

# https://stackoverflow.com/a/26647594/77814
echo "Setting correct permissions on folders that brew needs acccess to." | tee -a $logFile
touch /usr/local | tee -a $logFile
sudo chown -R `whoami`:admin /usr/local/bin | tee -a $logFile
sudo chown -R `whoami`:admin /usr/local/share | tee -a $logFile

# Make zsh the default shell
echo "Making zsh the default shell" | tee -a $logFile
source ~/.zshrc
sudo dscl . -create /Users/$USER UserShell /usr/local/bin/zsh | tee -a $logFile
echo which zsh | tee -a $logFile
dscl . -read /Users/$USER UserShell | tee -a $logFile
echo $SHELL | tee -a $logFile
chsh -s $(which zsh) | tee -a $logFile

#Install NVM
echo "Installing NVM" | tee -a $logFile
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash | tee -a $logFile
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Install node using NVM
nvm install node | tee -a $logFile
nvm use node | tee -a $logFile

source ~/.zshrc

# Global node packages to install
echo "Installing global NPM packages" | tee -a $logFile
npm config set strict-ssl false | tee -a $logFile
npm i -g @ionic/cli | tee -a $logFile
npm i -g @capacitor/core | tee -a $logFile
npm i -g @capacitor/cli | tee -a $logFile

echo "A setup log is available at $logFile."
