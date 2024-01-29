
if [ $# -eq 0 ]; then
	PLATFORM="x86_64-linux"
else
	PLATFORM="$1"
fi

if [ $# -eq 1 ]; then
	CHANNEL="alpha"
else
	CHANNEL="$2"
fi

if [ "${PLATFORM}" = "x86_64-win32" ] || [ "${PLATFORM}" = "x86-win32" ]; then
	DMENGINE=dmengine_headless.exe
else
	DMENGINE=dmengine_headless
fi

# {"version": "1.2.89", "sha1": "5ca3dd134cc960c35ecefe12f6dc81a48f212d40"}
# Get SHA1 of the current Defold stable release
SHA1=$(curl -s http://d.defold.com/${CHANNEL}/info.json | sed 's/.*sha1": "\(.*\)".*/\1/')

echo "Building for platform '${PLATFORM}' from channel '${CHANNEL}' with version '${SHA1}'"

# Download dmengine
if [[ ! -f ${DMENGINE} ]]; then
	DMENGINE_URL="http://d.defold.com/archive/${SHA1}/engine/${PLATFORM}/${DMENGINE}"
	echo "Downloading ${DMENGINE_URL}"
	curl -L -o ${DMENGINE} ${DMENGINE_URL}
	chmod +x ${DMENGINE}
fi

# Download bob.jar
if [[ ! -f bob.jar ]]; then
	BOB_URL="http://d.defold.com/archive/${SHA1}/bob/bob.jar"
	echo "Downloading ${BOB_URL}"
	curl -L -o bob.jar ${BOB_URL}
fi

# Fetch libraries
echo "Running bob.jar - resolving dependencies"
java -jar bob.jar resolve

echo "Running bob.jar - building"
java -jar bob.jar --verbose --variant=headless build --platform=${PLATFORM} --keep-unused

echo "Running '${DMENGINE}'"
if [ -n "${DEFOLD_BOOSTRAP_COLLECTION}" ]; then
	./${DMENGINE} --config=bootstrap.main_collection=${DEFOLD_BOOSTRAP_COLLECTION}
else
	./${DMENGINE}
fi
