function manifest_header() {
	print "{" 
	print "	\"minecraft\": {"
	print "		\"version\": \"1.20.1\", "
	print "		\"modLoaders\": [{\"id\": \"forge-47.4.10\", \"primary\": true }] "
	print "	},"
	print "	\"manifestType\": \"minecraftModpack\","
	print "	\"manifestVersion\": 1,"
	print "	\"name\": \"Abyssal Descent\","
	print "	\"version\": \"1\","
	print "	\"author\": \"AbyssalDescent\","
	print "	\"overrides\": \"overrides\","
	print "	\"files\": ["
}

BEGIN {
	FS = ","
	RS = "\r?\n"
}

!/^#/ && NF {
	switch (mode) {
		case "install":
			if (out_dir == "") {
				print "\x1b[31;1mERROR:\x1b[0m Output directory unspecified."
				exit 1
			}
			print "Downloading " $1
			system("curl -sSLo \""out_dir"/"$1".jar\" \"https://www.curseforge.com/api/v1/mods/"$2"/files/"$3"/download""\"")
			break
		case "curse":
			if (!started++) manifest_header()
			if (count++) printf ",\n"
			printf "		{ \"projectID\": "$2", \"fileID\": "$3", \"required\": true }"
			break
		default:
			print "\x1b[31;1mERROR:\x1b[0m Unknown mode: " mode
			exit 1
	}
}

END {
	if (mode == "curse") {
		print "\n	]\n}"
	}
}
