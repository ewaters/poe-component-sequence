use strict;
use warnings;
use Test::More tests => 1;

# Run the kernel now to force this to be synchronous
use POE qw(Component::Sequence);
POE::Kernel->run();

my $sequence = POE::Component::Sequence->new();
my @state;

$sequence->add_action(sub {
	push @state, 1;
});

$sequence->add_action(sub {
	push @state, 2;
	$sequence->add_action(sub {
		push @state, 4;
	});
	push @state, 3;
});

$sequence->add_action(sub {
	push @state, 5;
});

while (my $action = $sequence->get_next_action) {
	$action->();
}

is_deeply \@state, [ 1..5 ], "Actions ran in the order expected";
