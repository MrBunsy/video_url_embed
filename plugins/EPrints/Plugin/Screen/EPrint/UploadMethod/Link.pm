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

	my $valid_url = 0;
	if( $url =~ m{^(https?)://www\.youtube\.com/.*\bv=([^;&]+)} )
    {
		#normal youtube link
		$valid_url = 1;
		# just keep the id and junk everything else
		$url = "https://www.youtube.com/watch?v=$2";
	}elsif( $url =~ m{^(https?)://www\.youtube\.com/shorts/([^;&]+)}){
		#youtube short, convert to normal youtube video
		$url = "https://www.youtube.com/watch?v=$2";
		$valid_url = 1;
	}

	if( !$valid_url )
	{
		$processor->add_message( "error", $self->{session}->html_phrase( "Plugin/InputForm/Component/Upload:not_youtube_url" ) );
		return;
	}
	
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
	# TODO expand this for more types of link than just assuming youtube
	$doc->set_format("video");
	$doc->set_value("formatdesc", "YouTube Video");
	
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

	

	my $fragment = $self->{session}->make_doc_fragment;

	my $inner_fragment = $self->{session}->make_element( "div", class=>"ep_link_upload_grid");

	my $ffname = join('_', $self->{prefix}, "url");
	my $label = $self->{session}->make_element( "label", for => $ffname );
	$label->appendChild( $self->{session}->html_phrase( "Plugin/InputForm/Component/Upload:new_from_link" ) );
	$inner_fragment->appendChild( $label );

	my $file_button = $self->{session}->make_element( "input",
		name => $ffname,
		size => "30",
		id => $ffname,
		);
	my $add_format_button = $self->{session}->render_button(
		value => $self->{session}->phrase( "Plugin/InputForm/Component/Upload:add_link" ), 
		class => "ep_form_internal_button",
		name => "_internal_".$self->{prefix}."_add_format" );
	$inner_fragment->appendChild( $file_button );
	$inner_fragment->appendChild( $self->{session}->make_text( " " ) );
	$inner_fragment->appendChild( $add_format_button );


	#inspired by Repository::render_row_with_help
	my $help_prefix = "link_upload_help";
	my $inline_help_class = "ep_multi_inline_help ep_no_js";

	# style=>"overflow: hidden; display: none; height: 0px;"
	my $inline_help_div = $self->{session}->make_element( "div", id=>$help_prefix, class=>$inline_help_class);
	my $inner_help_div = $self->{session}->make_element( "div", id=>$help_prefix."_inner");
	
	$inner_help_div->appendChild($self->{session}->make_text($self->{session}->phrase( "Plugin/Screen/EPrint/UploadMethod/Link:help")));
	$inline_help_div->appendChild($inner_help_div);
	

	my $help_button_div = $self->{session}->make_element( "div", class=>"ep_multi_help ep_only_js_table_cell ep_toggle ep_table_cell", style=>"display:inline-block;" );
	my $show_help = $self->{session}->make_element( "div", class=>"ep_sr_show_help ep_only_js", id=>$help_prefix."_show" );
	my $helplink = $self->{session}->make_element( "a", onclick => "EPJS_blur(event); EPJS_toggleSlide('$help_prefix',false,'block');EPJS_toggle('${help_prefix}_hide',false,'block');EPJS_toggle('${help_prefix}_show',true,'block');return false", href=>"#" );
	$helplink->appendChild( $self->{session}->make_element( "img", 
		alt => $self->{session}->phrase( "lib/session:show_help_alt" ), 
		title=> $self->{session}->phrase( "lib/session:show_help_title" ), 
		src => $self->{session}->phrase( "lib/session:show_help_src" ) ) );
	$show_help->appendChild( $helplink );
	$help_button_div->appendChild( $show_help );

	my $hide_help = $self->{session}->make_element( "div", class=>"ep_sr_hide_help ep_hide", id=>$help_prefix."_hide" );
	my $helplink2 = $self->{session}->make_element( "a", onclick => "EPJS_blur(event); EPJS_toggleSlide('$help_prefix',false,'block');EPJS_toggle('${help_prefix}_hide',false,'block');EPJS_toggle('${help_prefix}_show',true,'block');return false", href=>"#" );
        $helplink2->appendChild( $self->{session}->make_element( "img", 
		alt => $self->{session}->phrase( "lib/session:hide_help_alt" ), 
		title=> $self->{session}->phrase( "lib/session:hide_help_title" ), 
		src => $self->{session}->phrase( "lib/session:hide_help_src" ) ) );
	$hide_help->appendChild( $helplink2 );
	$help_button_div->appendChild( $hide_help );
	$inner_fragment->appendChild( $help_button_div );

	# help text after button
	$inner_fragment->appendChild($inline_help_div);


	$fragment->appendChild($inner_fragment);
	
	return $fragment; 
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

