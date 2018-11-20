joke=$( curl http://api.icndb.com/jokes/random )
cat=$( curl --request GET --url 'https://api.thecatapi.com/v1/images/search?mime_types=png' -H 'Content-Type: application/json' -H 'x-api-key: f58770d1-e868-4653-8405-59319615c36d' | jq -r '.[].url' )
echo $cat
wget -O "./kotek.png" $cat
`img2txt -W 100 -f utf8 "./kotek.png" > "./output.txt"`
cat "./output.txt"
echo $joke | jq '.value.joke'
