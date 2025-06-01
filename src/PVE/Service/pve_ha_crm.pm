package PVE::Service::pve_ha_crm;

use strict;
use warnings;

use PVE::Daemon;

use PVE::HA::Env;
use PVE::HA::Env::PVE2;
use PVE::HA::CRM;

use base qw(PVE::Daemon);

my $cmdline = [$0, @ARGV];

my %daemon_options = (stop_wait_time => 60);

my $daemon = __PACKAGE__->new('pve-ha-crm', $cmdline, %daemon_options);

sub run {
    my ($self) = @_;

    $self->{haenv} = PVE::HA::Env->new('PVE::HA::Env::PVE2', $self->{nodename});

    $self->{crm} = PVE::HA::CRM->new($self->{haenv});

    for (;;) {
        last if !$self->{crm}->do_one_iteration();
    }
}

sub shutdown {
    my ($self) = @_;

    $self->{crm}->shutdown_request();
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
