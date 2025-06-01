package PVE::HA::Sim::RTEnv;

use strict;
use warnings;
use POSIX qw(strftime EINTR);
use JSON;
use IO::File;
use Fcntl qw(:DEFAULT :flock);

use PVE::HA::Tools;

use base qw(PVE::HA::Sim::Env);

sub new {
    my ($this, $nodename, $hardware, $log_id) = @_;

    my $class = ref($this) || $this;

    my $self = $class->SUPER::new($nodename, $hardware, $log_id);

    return $self;
}

sub get_time {
    my ($self) = @_;

    return time();
}

sub log {
    my ($self, $level, $msg) = @_;

    chomp $msg;

    my $time = $self->get_time();

    printf(
        "%-5s %10s %12s: $msg\n",
        $level,
        strftime("%H:%M:%S", localtime($time)),
        "$self->{nodename}/$self->{log_id}",
    );
}

sub sleep {
    my ($self, $delay) = @_;

    CORE::sleep($delay);
}

sub sleep_until {
    my ($self, $end_time) = @_;

    for (;;) {
        my $cur_time = time();

        last if $cur_time >= $end_time;

        $self->sleep(1);
    }
}

sub loop_start_hook {
    my ($self) = @_;

    $self->{loop_start} = $self->get_time();
}

sub loop_end_hook {
    my ($self) = @_;

    my $delay = $self->get_time() - $self->{loop_start};

    die "loop take too long ($delay seconds)\n" if $delay > 30;
}

1;
