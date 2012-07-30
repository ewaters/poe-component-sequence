use Module::Build;

my $build = Module::Build->new(
	module_name => 'POE::Component::Sequence',
	license     => 'perl',
	sign        => 1,
	configure_requires => {
		'Module::Build' => 0.4,
	},
	build_requires => {
		'Test::More' => 0,
	},
	requires => {
		'POE' => 0,
		'Class::MethodMaker' => 1,
	},
	create_makefile_pl => 'small',
);

$build->create_build_script;

