 for file in ./*; do echo "$file" | gawk '{print "mv -i '\''" $0 "'\'' '\''" tolower($0) "'\''" }'| sh ; done
