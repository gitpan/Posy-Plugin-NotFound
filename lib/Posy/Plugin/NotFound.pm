package Posy::Plugin::NotFound;
use strict;

=head1 NAME

Posy::Plugin::NotFound - Posy plugin to provide a custom Not Found page.

=head1 VERSION

This describes version B<0.10> of Posy::Plugin::NotFound.

=cut

our $VERSION = '0.10';

=head1 SYNOPSIS

    @plugins = qw(Posy::Core
	...
	Posy::Plugin::NotFound));
    @actions = qw(init_params
	parse_path
	set_config
	process_path_error
	...
	);

=head1 DESCRIPTION

The purpose of this plugin is to provide the user with the ability to
present a custom "Page Not Found" page, rather than the boring plain-text
message which Posy::Core provides in the 'process_path_error' method.

=head2 Activation

Add the plugin to the plugin list.

This plugin replaces the 'process_path_error' method, replacing its
actions with an alteration of the 'path' information so that
the $self->{config}->{not_found_entry} will be displayed instead,
as if it were a normal entry.  Therefore the actions list may have
to be rearranged so that 'set_config' is called before
'process_path_error'.

=head2 Configuration

This expects configuration settings in the $self->{config} hash,
which, in the default Posy setup, can be defined in the main "config"
file in the config directory.

=over

=item B<not_found_entry>

The relative path of the entry file to use for a Not Found page.
This is expected to be somewhere under the data directory, and will
be treated like a normal entry, except that it is only shown
when there is a path-parsing error (that is, when a page is not
found).

For example:

    not_found_entry: errorpages/404.html

Those using the Posy::Plugin::Categories plugin may wish also to
set the 'categories_hide' value, so that one can place the custom
Not Found page into a directory which won't be displayed in the
category_tree or breadcrumbs provided by the Posy::Plugin::Categories
plugin.

=back

=cut

=head1 OBJECT METHODS

Documentation for developers and those wishing to write plugins.

=head2 init

Do some initialization; make sure that default config values are set.

=cut
sub init {
    my $self = shift;
    $self->SUPER::init();

    # set defaults
    $self->{config}->{not_found_entry} = ''
	if (!defined $self->{config}->{not_found_entry});
} # init

=head1 Flow Action Methods

Methods implementing actions.

=head2 process_path_error

If there was an error parsing the path ($self->{path}->{error} is true)
then set up for displaying a custom 404 page defined by
the 'not_found_entry' config value.

=cut
sub process_path_error {
    my $self = shift;
    my $flow_state = shift;

    if ($self->{path}->{error}
	&& $self->{config}->{not_found_entry})
    {
	my ($path_and_filebase, $suffix) =
	    $self->{config}->{not_found_entry} =~ /^(.*)\.(\w+)$/;
	$path_and_filebase = $self->{config}->{not_found_entry} if (!$suffix);
	$path_and_filebase =~ s#^\./##; # remove an initial "./"
	$path_and_filebase =~ s#^/##;
	$path_and_filebase =~ s#/$##;

	# note that the PATH will be in the standard this/is/a/dir form
	# so just use split
	my @path_split = split(/\//, $path_and_filebase);
	my $full_no_ext = File::Spec->catdir($self->{data_dir}, @path_split);
	my $full_path_info = ($suffix ? "${full_no_ext}.$suffix" : $full_no_ext);
	# look for a possible filename
	my ($fullname, $ext) = $self->_find_file_and_ext($full_no_ext);
	if ($fullname) # is an entry
	{
	    $self->{path}->{type} = 'entry';
	    $self->{path}->{file_key} = $path_and_filebase;
	    $self->{path}->{ext} = $ext;
	    $self->{path}->{data_file} = $fullname;
	    $self->{path}->{basename} = pop @path_split;
	    $self->{path}->{cat_id} = (@path_split ? join('/', @path_split) : '');
	    $self->{path}->{depth} = @path_split;
	    $self->{path}->{type} = 'top_entry'
		if ($self->{path}->{cat_id} eq '');
	    $self->{path}->{name} = '';
	    $self->{path}->{pretty} = $self->{path}->{info};
	    $self->{path}->{pretty} =~ s#/# :: #g;
	    $self->{path}->{pretty} =~ s#_# #g;
	    $self->{path}->{pretty} =~ s/(\w+)/\u\L$1/g;
	}
	else # not-found is not found!
	{
	    $self->SUPER::process_path_error($flow_state);
	}
    }
    else
    {
	$self->SUPER::process_path_error($flow_state);
    }
} # process_path_error

=head1 REQUIRES

    Posy
    Posy::Core

    Test::More

=head1 SEE ALSO

perl(1).
Posy

Posy::Plugin::Categories

=head1 BUGS

Please report any bugs or feature requests to the author.

=head1 AUTHOR

    Kathryn Andersen (RUBYKAT)
    perlkat AT katspace dot com
    http://www.katspace.com

=head1 COPYRIGHT AND LICENCE

Copyright (c) 2005 by Kathryn Andersen http://www.katspace.com

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Posy::Plugin::NotFound
__END__
