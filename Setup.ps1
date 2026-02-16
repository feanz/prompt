#Update this to be chocolatey meta package

Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

choco feature enable -n allowGlobalConfirmation

choco install nerd-fonts-cascadiacode
choco install microsoft-windows-terminal
choco install git
choco install powershell-core
choco install oh-my-posh
choco install vim
choco install kdiff3
choco install gh
choco install bat

Install-Module Terminal-Icons
Install-Module z -AllowClobber

