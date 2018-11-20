#!/bin/sh
clear

function moveBackNet() {
  for((i=${#tableNet[*]}-1; i>0; i--));do
    let "tableNet[$i] = ${tableNet[$i-1]}"
  done
  let "tableNet[0]=$1"
}

function moveBackCPU() {
  for((i=${#tableCPU[*]}-1; i>0; i--));do
    let "tableCPU[$i] = ${tableCPU[$i-1]}"
  done
  liczba=$(echo "scale=0; $1*10" | bc -l)
  #quantity of scale
  let "tableCPU[0] = $(echo "$liczba / 2" | bc)"
}

function showNet() {
  for element in ${tableNet[*]};do
    echo -n "$element "
  done
  echo
}

function showCPU() {
  for element in ${tableCPU[*]};do
    echo -n "$element "
  done
  echo
}

function maxy() {
  for i in ${tableNet[*]};do
    if [ $max -lt $i ];then
      let "max=$i"
    fi
  done
}

function drawColumn() {
  for ((i=0; i < $1; i++));do
    echo -n $(tput setab 4)" "$(tput sgr0)
    tput cuu1
    tput cub1
  done
  for ((i=$1; i < 10; i++));do
    tput ech 1
    tput cuu1
  done
  tput cuf 2
  tput cud 10
}

function tmp() {
  max=0
  maxy
  tput el
  var=$(echo "$max / 10" | bc -l)
  echo $var
}
function graphNet() {
  max=0
  maxy
  tput el
  var=$(echo "$max / 10" | bc -l)

  if [ $max -lt 1000 ]; then
    echo -n "$max B"
  elif [ $max -gt 999 -a $max -lt 1000000 ]; then
    echo -n "$( echo "scale=2; $max / 1000" | bc -l ) kB"
  else
    echo -n "$( echo "scale=2; $max / 1000000" | bc -l ) MB"
  fi
  tput cud1
  for ((i=0; i < 9; i++));do
    echo -n "|"
    tput cud1
  done
  echo -n "0"

  tput cuf 3
  if [[ $var != 0 ]];then
    #echo "var = $var"
    for element in ${tableNet[*]};do
      tmp=$(echo "$element / $var" | bc )
      #let "tmp = $tmp + 1"
      drawColumn $tmp
    done
  fi
}

function graphCPU() {
  for ((i=20; i>0; i = $i - 2));do
    echo -n "$(echo "scale=1; $i / 10" | bc -l)"
    tput cud1
  done
  tput cuu1
  tput cuf 4

  for element in ${tableCPU[*]};do
    drawColumn $element
  done


}
#All variables
tableNet=(0 0 0 0 0 0 0 0 0 0)
tableCPU=(0 0 0 0 0 0 0 0 0 0)
sum=0;
time=0;
recived1=0
transmited1=0
recived2=0
transmited2=0
uptime=0

#Main part of script
while [ true ]; do
  tput sc
  let "recived1 = $( cat /proc/net/dev | grep wlp | awk '{print $2}' )"
  let "transmited1 = $( cat /proc/net/dev | grep wlp | awk '{print $10}' )"

  sleep 1
  let "time++"
  let "recived2 = $( cat /proc/net/dev | grep wlp | awk '{print $2}' )"
  let "transmited2 = $( cat /proc/net/dev | grep wlp | awk '{print $10}' )"
  let "sum = sum + $recived2 + $transmited2 - $recived1 - $transmited1"

  current=$( echo "scale=0;$recived2 - $recived1 + $transmited2 - $transmited1" | bc -l )
  let "current = $( echo "scale=0; $current / 8" | bc -l)"
  #TableCPU
  moveBackNet $current
  average=$( echo "scale=0; $sum / $time" | bc -l )
  let "average = $( echo "scale=0; $average / 8" | bc -l )"

  uptime=$( cat /proc/uptime | awk '{print $1}' )
  uptime=$( echo "scale=0; $uptime / 1" | bc -l )

  battery=$( cat /sys/class/power_supply/BAT1/uevent | grep POWER_SUPPLY_CAPACITY= | awk -F = '{print $2}' )

  cpu1=$( cat /proc/loadavg | awk '{print $1}')
  cpu5=$( cat /proc/loadavg | awk '{print $2}')
  cpu15=$( cat /proc/loadavg | awk '{print $3}')
  moveBackCPU $cpu1

  #current speed
  if [ $current -lt 1000 ]; then
    echo "Current: $( tput el )$current B"
  elif [ $current -gt 999 -a $current -lt 1000000 ]; then
    echo "Current: $( tput el )$( echo "scale=2; $current / 1000" | bc -l ) kB"
  else
    echo "Current: $( tput el )$( echo "scale=2; $current / 1000000" | bc -l ) MB"
  fi
  #average speed
  if [ $average -lt 1000 ]; then
    echo "Average: $( tput el )$average B"
  elif [ $average -gt 999 -a $average -lt 1000000 ]; then
    echo "Average: $( tput el )$( echo "scale=2; $average / 1000" | bc -l ) kB"
  else
    echo "Average: $( tput el )$( echo "scale=2; $average / 1000000" | bc -l ) MB"
  fi
  #uptime
  let "tmp = 60 * 60 * 24"
  day=$( echo "$uptime / $tmp" | bc )
  let "uptime = $uptime - ($day * $tmp)"
  let "tmp = 60 * 60"
  hour=$( echo "$uptime / $tmp" | bc )
  let "uptime = $uptime - ($hour * $tmp)"
  let "tmp = 60"
  minute=$( echo "$uptime / $tmp" | bc )
  let "uptime = $uptime - ($minute * $tmp)"
  second=$uptime
  echo "Uptime: $( tput el )$day day; $hour hour; $minute minute; $second second;"
  #baterry
  echo "Battery: $battery %"
  #CPU info
  echo "CPU: $cpu1 [1 minute], $cpu5 [5 minutes], $cpu15 [15 minutes]"
  printf "\n\n\n\n\n\n"
  graphCPU
  printf "\n\n"
  graphNet
  tput rc

done
