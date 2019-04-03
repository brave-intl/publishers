

# Clean up old builds
rm -rf ../precache*.js
rm -rf ../static/css/main.*
rm -rf ../static/js/*.chunk.*
rm -rf ../static/js/runtime*

cp -Rf build/* ../
