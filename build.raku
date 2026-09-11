use JSON::Fast <sorted-keys>;
use File::Directory::Tree;

sub copy-dir-contents(IO::Path $src, IO::Path $dst) {
	$dst.mkdir unless $dst.d;

	for $src.dir {
		my $target = $dst.add: .basename;
		.d ?? copy-dir-contents $_, $target !! .copy: $target;
	}
}

sub parse-mods(IO::Path $src --> Seq) {
	$src.lines.map: {
		next if .starts-with('#') || .trim eq "";
		my ($filename, $project-id, $file-id) = .split(",");
		item { projectID => $project-id.Int, fileID => $file-id.Int, required => True }
	}
}

sub MAIN(Bool :$release = False) {
	say "Preparing build dir";
	try .d ?? rmtree $_ !! .unlink for "build".IO.dir;

	if !$release {
		mkdir "build/overrides/mods";
		for "src".IO.dir.grep(*.d) {
			say "Building {.basename}";
			run $*DISTRO.is-win ?? "gradlew.bat" !! "./gradlew", "build", "--quiet", :cwd($_);
			my $f = "$_/build/libs/".IO.dir.head or exit;
			$f.move: "build/overrides/mods".IO.add($f.basename);
		}
	}

	copy-dir-contents "overrides".IO, "build/overrides".IO;

	my %curse-manifest = (
		minecraft => {
			version => "1.20.1",
			modLoaders => [item {id => "forge-47.4.10", primary => True}],
		},
		manifestType => "minecraftModpack",
		manifestVersion => 1,
		name => "Abyssal Descent",
		version => 1,
		author => "AbyssalDescent",
		overrides => "overrides",
		files => flat parse-mods("mods.csv".IO), $release ?? parse-mods("src/mods.csv".IO) !! (),
	);
	
	"build/manifest.json".IO.spurt: to-json(%curse-manifest);
	
	my $version = ($release ?? "release-" !! "dev-") ~ qqx{git rev-parse --short HEAD}.trim-trailing;
	say "Packaging version $version";
	"build/release.txt".IO.spurt: $version;

	my @overrides = 'build'.IO.dir.map(*.basename).grep(* !~~ /^'.'/);
	my @cmd = $*DISTRO.is-win ?? ("tar", "acf") !! ("zip", "-r");
	run |@cmd, "../Abyssal-Descent-$version.zip", |@overrides, :cwd("build"), :out;
}
