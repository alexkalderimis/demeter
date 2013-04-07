=head1 App::Demeter::Source

A role which serves to define the interface for compatible
data sources.

=head1 SYNOPSIS

    package App::Demeter::Source::MySource;

    use Moose;
    with 'App::Demeter::Source';

    sub get_data {
        my $self = shift;
        ... # do your thing here.
    }

=head1 DESCRIPTION

This role serves as a description of the interface that all
download sources must implement. There is no need for this role
to actually be consumed, but the methods it defines must be 
provided.

=head1 METHODS

=head2 ::new(data_dir => Str, logger => Log::Handler, options => HashRef)

A constructor method that takes three named arguments:

=over 4

=item data_dir [Str]: Where the data should go

=item logger [Log::Handler]: A logger to use to report messages

=item options [HashRef]: A hash of options as configured by the environment.

=back

=head2 get_data()

Perform whatever actions are required to get data for this source. It is
expected that most sources will extend L<App::Demeter::Source::ABC> to
gain access to the workflow definition it supplies.

=cut

package App::Demeter::Source;

use strict;
use warnings;

use Moose::Role;

requires qw/new get_data/;

1;
