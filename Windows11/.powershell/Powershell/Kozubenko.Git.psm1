using module .\classes\FunctionRegistry.psm1
using module .\Kozubenko.Utils.psm1
class KozubenkoGit {   
    static [FunctionRegistry] GetFunctionRegistry() {
        return [FunctionRegistry]::new(
            "Kozubenko.Git",
            @(
                "Push(`$commitMsg = 'no_msg')       -->  push to github repo. does not work with branches",
                "GitHistory()                      -->  git log --oneline",
                "Github()                          -->  goes to remote.origin.url in the browser",
                "GitConfig(`$email, `$name)          -->  git config --global user.email `$email; etc."
            ));
    }
}


function GitConfig ($email, $name) {
    git config --global user.email $email
    git config --global user.name $name
}

function Push ($commitMsg = "No Commit Message") {
    git add .
    git commit -a -m $commitMsg
    git push
}

function Github ($path = $PWD.Path) {
    $configFile = "$path\.git\config"
    if(TestPathSilently $configFile) {  $url = git config --file $configFile --get remote.origin.url; Start-Process $url;  RETURN;  }

    $possibleAltConfigLocation = "$path\..\.git\config"
    if(TestPathSilently $possibleAltConfigLocation) {  $url = git config --file $possibleAltConfigLocation --get remote.origin.url; Start-Process $url;  RETURN;  }

    $possibleAltConfigLocation2 = "$path\..\..\.git\config"
    if(TestPathSilently $possibleAltConfigLocation2) {  $url = git config --file $possibleAltConfigLocation2 --get remote.origin.url; Start-Process $url;  RETURN;  }

    WriteRed "No .git config file found under `$path: $path";
}

function GitHistory {
    git log --oneline
}