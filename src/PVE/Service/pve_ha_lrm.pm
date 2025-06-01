package PVE::Service::pve_ha_lrm;

use strict;
use warnings;

use PVE::Daemon;

use PVE::HA::Env;
use PVE::HA::Env::PVE2;
use PVE::HA::LRM;

use base qw(PVE::Daemon);

my $cmdline = [$0, @ARGV];

my %daemon_options = (stop_wait_time => 60 * 60);

my $daemon = __PACKAGE__->new('pve-ha-lrm', $cmdline, %daemon_options);

sub run {
    my ($self) = @_;

    $self->{haenv} = PVE::HA::Env->new('PVE::HA::Env::PVE2', $self->{nodename});

    $self->{lrm} = PVE::HA::LRM->new($self->{haenv});

    for (;;) {
        last if !$self->{lrm}->do_one_iteration();
    }
}

sub shutdown {
    my ($self) = @_;

    $self->{lrm}->shutdown_request();
}

$daemon->register_start_command();
$daemon->register_stop_command();
$daemon->register_status_command();

our $cmddef = {
    start => [__PACKAGE__, 'start', []],
    stop => [__PACKAGE__, 'stop', []],
    status => [__PACKAGE__, 'status', [], undef, sub { print shift . "\n"; }],
};

1;
