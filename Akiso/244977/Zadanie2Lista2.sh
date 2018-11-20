echo "PID   PID   Status   Name"
for file in $( ls /proc/ | awk '/[0-9]/{print}' ); do
  if [ -e "/proc/$file" ];then
      echo "$file $( cat /proc/$file/status | grep PPid | awk '{print $2}' ) $( cat /proc/$file/status | grep State | awk '{print $2}' ) $( cat /proc/$file/status | grep Name | awk '{print $2}' ) "
      if [ -r "/proc/$file/fd" ];then
        echo "Number of opened file: $( ls /proc/$file/fd | wc -l )"
      else
        echo "Number of opened file: ???"
      fi
      echo
  fi
done
