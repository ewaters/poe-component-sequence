use strict;
use warnings;
use Test::More;
use POE::Component::Sequence;
use Time::HiRes qw(sleep);

use FindBin;
use lib "$FindBin::Bin/lib";
use MyTests;

sequence_test "Pause and resume" => sub {
	my ($sequence, $test_sequence) = @_;
	$sequence->add_action(sub {
		my $self = shift;

		is $self->pause_state, 0, "Pause state before pause is 0";

		$self->pause();
		is $self->pause_state, 1, "Pause state after pause is 1";

		$self->pause();
		is $self->pause_state, 2, "Pause state after repeated pause is 2";

		$self->resume();
		is $self->pause_state, 1, "Resume lowers the sequence pause state by one";

		# The test sequence expects this sub sequence to ultimately hit 'finally'
		# Since we're leaving it paused here, this will never happen.  Let's trigger
		# resume on it manually here so we can continue to the next test
		$test_sequence->resume();
	});

	$sequence->add_action(sub {
		ok 0, "This should never be reached; the sequence is paused";
	});
}, tests => 4;

sequence_test "Delay" => sub {
	my $sequence = shift;
	my @touch_points;

	$sequence->add_action(sub {
		my $self = shift;
		push @touch_points, 1;
		$sequence->add_delay(0.01, sub { push @touch_points, 2 });
	});

	$sequence->add_action(sub {
		push @touch_points, 3;
		# The delay should trigger after this action runs but before the finally callback
		# To ensure this, let's sleep for the length of the delay
		sleep 0.01;
	});

	$sequence->add_finally_callback(sub {
		is_deeply \@touch_points, [1, 3, 2], "Adding a delay caused sequence to run in the expected order";
	});
}, tests => 1;

run_tests;
