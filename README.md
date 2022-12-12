# Setup Scripts
The purpose of these scripts is to automate as much as possible the setup and configuration of new mobile build machines and new macbooks for mobile devs (WIP).

## Build Machine
The build machine script should be run as sudo to make sure everything is installed correctly. The scripts multiple lists of programs to install. The installations are handled with [Homebrew](https://brew.sh/). The first list is home brew apps then cask apps and finally global npm packages. There is also a apps to run on startup that currently isn't used. 

Once all the brew apps are installed next nvm will be setup and configured to use the LTS version of node. After that the global npm packages will be installed.

After brew & node the shell will be configured. The default shell will be set to zsh and a profile created at ~/.zshrc. The $PATH variable will be updated with the location for JAVA_HOME, ANDROID_SDK.

Next xcode will be installed. Because Apple doesn't release their software anywhere else than the offical Apple channels this step requires some additional 3rd party services. As of this writting the latest xcode is 13.4.1 and that is what will be installed. Currently the tool we're using to install xcode requires that a version be passed in. This will need to be updated whenver we upgrade our xcode version.

Once all the programs have been installed the last thing to configure is the gitlab runner. The script will create the config the config.toml file at */etc/gitlab-runner*. Using homebrew the runner will be started as a service.

The build machine should now be ready to run builds.
