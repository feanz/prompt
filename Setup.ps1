#Update this to be chocolatey meta package

Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

choco feature enable -n allowGlobalConfirmation

choco install git -y
choco install nerd-fonts-cascadiacode -y
choco install microsoft-windows-terminal -y
choco install powershell-core -y
choco install oh-my-posh -y
choco install vim -y
choco install kdiff3 -y
choco install gh -y 
choco install bat -y
choco install azure-cli -y
choco install chatgpt -y
choco install awscli -y
choco install kubernetes-cli -y

Install-Module Terminal-Icons
Install-Module z -AllowClobber

