# {
# package EPrints::Script::Compiled;
# use strict;

# print STDERR "Running z_video_url_embed.pl\n";

# sub run_embed_video_url
# {
#     print STDERR "running run_embed_video_url\n";
#     my( $self, $state, $object ) = @_;
    
#     my $eprint = $object->[0];

#     my $repo = $eprint->{session};
#     my $frag = $repo->xml->create_document_fragment;

# 	if( $eprint->exists_and_set( "official_url" ) )
# 	{
#         print STDERR "official_url exists \n";
# 		my $url = $eprint->value( "official_url" );
#         print STDERR "official_url: $url\n";
# 		if( $url =~ m{^(https?)://www\.youtube\.com/.*\bv=([^;&]+)} )
# 		{
#             print STDERR "matches youtube: $1\n";
# 			$frag->appendChild( $repo->xml->create_element( "iframe",
# 						width => 420,
# 						height => 315,
# 						src => sprintf("$1://www.youtube.com/embed/%s", $2),
# 						frameborder => 0,
# 						allowfullscreen => "yes"
# 					) );
# 		}
# 		elsif( $url =~ m{^(https?)://vimeo.com/(\d+)} ) {
# 			$frag->appendChild( $repo->xml->create_element( "iframe",
# 						width => 500,
# 						height => 281,
# 						src => sprintf("$1://player.vimeo.com/video/%s", $2),
# 						frameborder => 0,
# 						allowfullscreen => "yes"
# 					) );
# 		}
# 	}


#     # if( !$object->[0]->isa( "EPrints::DataObj::Document" ) )
#     # {
#     #         $self->runtime_error( "can't call embed_vidio on non-document objects." );
#     # }

#     # my $xhtml = ""
#     return [ $frag, "XHTML" ];
#     # return [ $xhtml, "XHTML" ];
# }
# }