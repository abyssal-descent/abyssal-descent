#!/bin/sh

REPO=$(pwd)
VERSION=$(echo "dev-1.0-$(git rev-parse --short HEAD)")

# eventually split these mods into their separate repos with versions we can pull from github
build_java() {
	mkdir -p "$1/mods"
	for mod in $(ls "$REPO/src"); do
		[ "$2" = "fuck-quek" ] && [ "$mod" = "undergarden" ] && continue
		echo "Building $mod"
		cd "$REPO/src/$mod" && ./gradlew build --quiet || exit 1
		mv build/libs/*.jar "$REPO/$1/mods"
		cd "$REPO"
	done
}

package() {
	echo "Packaging ver $VERSION"
	echo "$VERSION" > build/release.txt

	# FIXME: use the proper zip command to archive a dir's contents
	cd "$REPO/build"
	zip -r "../Abyssal-Descent-$VERSION.zip" * > /dev/null || exit 1
	cd "$REPO"
}

clean() {
	echo "Preparing build dir"
	rm -r "$REPO/build" 2> /dev/null
	mkdir -p "$REPO/build" 2> /dev/null
}


case $1 in
	"curse")
		clean
		build_java build/overrides
		cp -r overrides/* build/overrides
		awk -v "mode=curse" -f parse-mods.awk mods.csv > build/manifest.json || exit 1
		package
		;;
	"export")
		clean
		build_java build
		cp -r overrides/* build
		awk -v "mode=install" -v "out_dir=build/mods" -f parse-mods.awk mods.csv || exit 1
		package
		;;
	"export-no-pack")
		clean
		build_java build
		cp -r overrides/* build
		awk -v "mode=install" -v "out_dir=build/mods" -f parse-mods.awk mods.csv || exit 1
		;;
	"curse-no-quek")
		clean
		build_java build/overrides "fuck-quek"
		cp -r overrides/* build/overrides
		awk -v "mode=curse" -f parse-mods.awk mods.csv > build/manifest.json || exit 1
		package
		;;
	"export-no-quek")
		clean
		build_java build "fuck-quek"
		cp -r overrides/* build
		awk -v "mode=install" -v "out_dir=build/mods" -f parse-mods.awk mods.csv || exit 1
		package
		;;
	"package")
		package
		;;
	*)
		printf "\x1b[1mOptions:\x1b[0m\n"
		echo "   curse           Export the modpack for CurseForge"
		echo "   export          Export the modpack for manual installation"
		echo
		printf "\x1b[1mDev Options:\x1b[0m (prob not needed for normal use)\n"
		echo "   curse-no-quek"
		echo "   export-no-queck"
		echo "   export-no-pack  Export the modpack without zipping it"
		echo "   package         Package from build directory"
		;;
esac
