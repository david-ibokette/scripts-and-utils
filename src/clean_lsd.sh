ps aux | grep lsd

echo "about to run lsrgister -kill"
sleep 5
/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -kill -r -domain local -domain system -domain user

echo "about to run sudo lsrgister -kill -seed -lint"
sleep 5
sudo /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -seed -lint -r -f -v -dump -domain local -domain system -domain user -domain network


echo "about to run killall Dock"
sleep 5
killall Dock


echo "about to run sudo mdutil -E"
sleep 5
sudo mdutil -E /


echo "about to run sudo mdutil -i on"
sleep 5
sudo mdutil -i on /

ps aux | grep lsd
