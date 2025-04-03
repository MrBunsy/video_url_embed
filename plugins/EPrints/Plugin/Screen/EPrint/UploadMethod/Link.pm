=head1 NAME

EPrints::Plugin::Screen::EPrint::UploadMethod::Link

=cut

package EPrints::Plugin::Screen::EPrint::UploadMethod::Link;

use EPrints::Plugin::Screen::EPrint::UploadMethod::File;

@ISA = qw( EPrints::Plugin::Screen::EPrint::UploadMethod::File );

use strict;
use File::Temp;

sub new
{
	my( $class, %opts ) = @_;

	my $self = $class->SUPER::new( %opts );

	$self->{actions} = [qw( add_format )];
	$self->{appears} = [
		{ place => "upload_methods", position => 400 },
	];

	return $self;
}

sub allow_add_format { shift->can_be_viewed }

sub action_add_format
{
	my( $self ) = @_;

	my $session = $self->{session};
	my $processor = $self->{processor};
	my $ffname = join('_', $self->{prefix}, "url");
	my $eprint = $processor->{eprint};

	my $url = Encode::decode_utf8( $session->param( $ffname ) );

	
	#plan is for a file that contains a list of urls, mime type "text/uri-list"
	my ($fh, $filepath) = File::Temp::tempfile();

	my $filename = EPrints->system->sanitise( "link.uri" );

	#actually write to the file!
	print $fh $url;
	$fh->flush;
	close $fh;
	# print STDERR `cat $filepath`;

	my $epdata = {};
	$epdata->{mime_type} = "text/uri-list";
	$epdata->{main} = $filename;

	my $doc = $eprint->create_subdataobj( "documents", $epdata);
	$doc->set_format("other");
	
	# contents of add_file, but with mime_type set
	my $fileobj;
	{
		$fileobj = $doc->stored_file( $filename );
		$fileobj->remove if defined $fileobj;

		$filename = EPrints->system->sanitise( $filename );

		open(my $fh, "<", $filepath) or return undef;

		$fileobj = $doc->create_subdataobj( "files", {
			_content => $fh,
			_filepath => $filepath,
			filename => $filename,
			filesize => -s $fh,
			mime_type => "text/uri-list"
		});

		close $fh;
	}

	if( !$fileobj )
	{
		$doc->remove();
		$processor->add_message( "error", $self->{session}->html_phrase( "Plugin/InputForm/Component/Upload:upload_failed" ) );
		return;
	}
	# let the indexer know this file needs looking at, otherwise thumbnails won't be generated
	$doc->queue_files_modified;

	$doc->commit;

	$processor->{notes}->{upload_plugin}->{to_unroll}->{$doc->get_id} = 1;
}


sub render
{
	my( $self ) = @_;

	my $f = $self->{session}->make_doc_fragment;

	my $ffname = join('_', $self->{prefix}, "url");
	my $label = $self->{session}->make_element( "label", for => $ffname );
	$label->appendChild( $self->{session}->html_phrase( "Plugin/InputForm/Component/Upload:new_from_link" ) );
	$f->appendChild( $label );

	my $file_button = $self->{session}->make_element( "input",
		name => $ffname,
		size => "30",
		id => $ffname,
		);
	my $add_format_button = $self->{session}->render_button(
		value => $self->{session}->phrase( "Plugin/InputForm/Component/Upload:add_link" ), 
		class => "ep_form_internal_button",
		name => "_internal_".$self->{prefix}."_add_format" );
	$f->appendChild( $file_button );
	$f->appendChild( $self->{session}->make_text( " " ) );
	$f->appendChild( $add_format_button );
	
	return $f; 
}

1;

=head1 COPYRIGHT

=for COPYRIGHT BEGIN

Copyright 2022 University of Southampton.
EPrints 3.4 is supplied by EPrints Services.

http://www.eprints.org/eprints-3.4/

=for COPYRIGHT END

=for LICENSE BEGIN

This file is part of EPrints 3.4 L<http://www.eprints.org/>.

EPrints 3.4 and this file are released under the terms of the
GNU Lesser General Public License version 3 as published by
the Free Software Foundation unless otherwise stated.

EPrints 3.4 is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with EPrints 3.4.
If not, see L<http://www.gnu.org/licenses/>.

=for LICENSE END

