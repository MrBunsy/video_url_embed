# use EPrints;
# use strict;

# package EPrints::DataObj::Document;

# use strict;

# no warnings 'redefine';

# sub get_youtube_id
# {
#     return "burble";
# }

# push @{$c->{fields}->{document}},
# {
#     youtube_id => "text",
# };


# $c->add_dataset_trigger( "document", EPrints::Const::EP_TRIGGER_FILES_MODIFIED, sub
# {
# 	my( %args ) = @_;
# 	my( $session, $doc ) = @args{qw( repository dataobj )};

# 	print STDERR "Start in z_remote_video_url_support trigger for " . $doc->id . "\n";

# 	my $eprint = $doc->get_parent;

# 	return unless $doc->get_value( "main" ) eq "uri.list";

#     my $src = $doc->get_stored_file( $doc->get_main );

#     my $uri;
# 	$src->get_file(sub {$uri = $_[0]});

#     if( $uri =~ m{^(https?)://www\.youtube\.com/.*\bv=([^;&]+)} )
#     {
#         $doc->set_value("youtube_id", $2);
#     }

#     $doc->commit;
# 	print STDERR "Done in z_remote_video_url_support trigger for " . $doc->id . "\n";
# });

1