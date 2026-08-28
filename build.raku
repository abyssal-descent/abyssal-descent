use JSON::Fast;

sub MAIN(Bool :$no-quek = False) {
	say "Preparing build dir";
	try .d ?? .rmdir(:r) !! .unlink for "build".IO.dir;

	"build/overrides/mods".IO.mkdir(:parents);
	for "src".IO.dir.grep(*.d) {
		next if $no-quek && .basename eq "undergarden";
		say "Building {.basename}";
		run $*DISTRO.is-win ?? "gradlew.bat" !! "./gradlew", "build", "--quiet", :cwd($_);
		my $f = "$_/build/libs/".IO.dir.head or exit;
		$f.move: "build/overrides/mods".IO.add($f.basename);
	}

	sub copy-dir-contents(IO::Path $src, IO::Path $dst) {
		$dst.mkdir unless $dst.d;

		for $src.dir {
			my $target = $dst.add: .basename;
			.d ?? copy-dir-contents $_, $target
				!! .copy: $target;
		}
	}

	copy-dir-contents "overrides".IO, "build/overrides".IO;

	my %curse-manifest = (
		minecraft => {
			version => "1.20.1",
			modLoaders => [], 
		},
		manifestType => "minecraftModpack",
		manifestVersion => 1,
		name => "Abyssal Descent",
		version => 1,
		author => "AbyssalDescent",
		overrides => "overrides",
		files => [],
	);

	%curse-manifest{"minecraft"}{"modLoaders"}.push: { id => "forge-47.4.10", primary => True };

	for "mods.csv".IO.lines {
		next if .starts-with('#') || .trim eq "";
		my ($filename, $project-id, $file-id) = .split(",");
		%curse-manifest{"files"}.push: { projectID => $project-id, fileID => $file-id, required => True };
	}
	
	"build/manifest.json".IO.spurt: to-json(%curse-manifest);
	
	my $version = "dev-1.0-{qqx{git rev-parse --short HEAD}.trim-trailing}";
	say "Packaging version $version";
	"build/release.txt".IO.spurt: $version;

	my $null = open $*SPEC.devnull, :w;
	my @overrides = 'build'.IO.dir.map(*.basename).grep(* !~~ /^'.'/);
	run "tar", "acf", "../Abyssal-Descent-$version.zip", |@overrides,
		:cwd("build"), :out($null), :err($null);
}
