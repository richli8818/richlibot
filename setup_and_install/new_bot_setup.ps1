# Retrieving User Information
$GITHUBUSER = Read-Host -Prompt "What is your GitHub Username?"
Write-Output ""
Write-Output "** If you have 2 Factor Auth configured, "
Write-Output "   provide a Personal Access Token with repo and delete_repo access."
Write-Output "   Tokens can be generated at https://github.com/settings/tokens **"
$SECUREPASS = Read-Host -Prompt 'What is your GitHub Password?' -AsSecureString
$GITHUBPASS = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($SECUREPASS))
Write-Output ""
$GITHUBREPO = Read-Host -Prompt "What is the name of your bot? A new GitHub repo will be created with this name"
Write-Output ""

# Retrieving Master Zip File
Write-Output "Pulling down and prepping the code for the UI service."
Invoke-WebRequest "https://github.com/imapex/boilerplate_sparkbot/archive/master.zip" -OutFile "master.zip"

# Prepare Files and Directories
Write-Output ""
Write-Output "Creating new directory ./$GITHUBREPO with bot code"
#unzip -qq master.zip -d ./$GITHUBREPO
7z x ./master.zip -o"$GITHUBREPO"
Remove-Item master.zip
Set-Location ./$GITHUBREPO

# Move the files into the root of the repo and cleanup folder
Move-Item boilerplate_sparkbot-master/* ./
Move-Item boilerplate_sparkbot-master/\.* ./
Remove-Item -Force -Recurse boilerplate_sparkbot-master

# Delete Drone Build files from boilerplate
Remove-Item .drone.sec
Remove-Item .drone.yml
Remove-Item drone-secrets-sample.yml

Write-Output ""
Write-Output "Creating new GitHub Repo"

# Setup GitHub Credentials
$PAIR = "${GITHUBUSER}:${GITHUBPASS}"
$BYTES = [System.Text.Encoding]::ASCII.GetBytes($PAIR)
$BASE64 = [System.Convert]::ToBase64String($BYTES)
$BASICAUTH = "Basic $BASE64"
$HEADERS = @{ Authorization = $BASICAUTH }

# Create GitHub Repo
Invoke-RestMethod -Method Post -Uri "https://api.github.com/user/repos" -Headers $HEADERS -Body "{`"name`": `"$GITHUBREPO`"}"

# Setup Local Repo and Push to GitHub
Write-Output ""
Write-Output "Setting up Local GitHub Repo and pushing to GitHub."
git init
git add .
git commit -m "First commit"
git remote add origin https://github.com/$GITHUBUSER/$GITHUBREPO.git
git push -u origin master

Write-Output " "
Write-Output "Your new Spark Bot has been prepped in repo https://github.com/$GITHUBUSER/$GITHUBREPO."
Write-Output "Now begin customizing the bot code in the file bot/bot.py"
Write-Output "  "
