export WM_PID=$(pgrep wizardmirror) 
watch -n 0.1 ps -p $WM_PID -o rss,cmd