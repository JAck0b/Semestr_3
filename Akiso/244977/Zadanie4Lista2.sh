links -dump $1 > ./website.txt
cat ./website.txt > ./site.txt
git commit ./site.txt ./website.txt -m "New site." > /dev/null
while [ true ];do
  sleep $2
  links -dump $1 > ./website.txt
  echo "Difference: "
  diff ./website.txt ./site.txt
  cat ./website.txt > ./site.txt
  git commit ./site.txt ./website.txt -m "New site." > /dev/null
done
