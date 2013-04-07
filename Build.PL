use strict;
use warnings;
use Module::Build;
use List::Util qw/reduce/; # In core since 5.10

my @core_modules = qw/
    strict warnings feature autodie constant
    File::Path File::Basename
    List::Util
/;

my %extra_imports = ();
my @extra_reqs = ();
my %basic_deps = (
    'Moose' => '2.0',
    'MooseX::ABC' => '0.05',
    'MooseX::FollowPBP' => '0.05', 
    'MooseX::FileAttribute' => 0,
    'Net::FTP' => 0,
    'Log::Handler' => 0,
    'DateTime' => 0,
    'Module::Find' => 0,
    'Web::Scraper' => 0, 
    'Ouch' => 0,
    'Number::Format' => 0,
    'PerlIO::gzip' => 0,
    'Perl6::Junction' => 0,
    'List::MoreUtils' => 0,
    'LWP'             => 0,
    'URI'             => 0,
    'Carp'            => 0,
);

my $SOURCE_DIR = 'lib/App/Demeter/Source';
my $add_all = user_wants('all optional dependencies');

opendir(my $dh, $SOURCE_DIR)
    or die("Cannot access Source files, $!");
for (readdir($dh)) {
    next unless /\.pm$/;
    open(my $fh, "$SOURCE_DIR/$_")
        or die("Cannot read $_, $!");
    for my $line (<$fh>) {
        next unless $line =~ /^use ([\w:]+)/;
        my $module = $1;
        my $needers = $extra_imports{$module} || [];
        push @$needers, substr $_, 0, -3;
        $extra_imports{$1} = $needers;
    }
    close($fh) or die("Cannot close $_, $!");
}
closedir($dh) or die("Cannot close dir, $!");

for my $module (keys %extra_imports) {
    next if grep {$module eq $_} @core_modules;
    next if defined $basic_deps{$module};
    next if $module =~ /^Moose::/;
    next if $module =~ /^App::Demeter::/;
    next if $module =~ /^LWP::/;
    my $prompt = sprintf("%s (required by %s)",
        $module, join(', ', @{$extra_imports{$module}}));
    if ($add_all || user_wants($prompt)) {
        push @extra_reqs, $module, 0;
    }
}

print join(", ", @extra_reqs), "\n";

my $builder = Module::Build->new(
    module_name         => 'App::Demeter',
    license             => 'lgpl',
    dist_abstract       => 'Data Harvesting Application',
    dist_author         => q{Alex Kalderimis <perl@intermine.org>},
    dist_version_from   => 'lib/App/Demeter.pm',
    share_dir           => 'config',
    requires => {
        %basic_deps,
        @extra_reqs
    },
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'App-DataDownloader-*' ],
    create_makefile_pl => 'traditional',
);


$builder->create_build_script();

## HELPERS ##

sub user_wants {
    my ($thing) = @_;
    looks_like(Module::Build->prompt("Add support for $thing?", 'n'), 'yes');
}

sub looks_like {
    my ($input, $str) = @_;
    my @chars = reverse split '', $str;
    my $pattern = reduce { $a ? "$b($a)?" : $b } undef, @chars;
    $input =~ /$pattern/i;
}
