# this field is used to store the URL of a video
push @{$c->{fields}->{eprint}},
{
	name => 'video_remote_url',
    type => 'text',
    render_value => 'render_video_link',
    # fields => [
	# 	{
    #         name => 'render_thumbnail',
    #         type => 'text',
    #         virtual => 1,
    #     }
    # ]
};

# $c->{render_video_remote_url_thumbnail} = sub{

#     return "THUMBNAIL OF VIDEO HERE";
# };

# use strict;
# use Data::Dumper;
$c->{render_video_link} = sub{

    my( $session, $field, $value) = @_;#, %opts # , $unused0, $unused1, $eprint
    # user Data::Dumper;
    # print STDERR "opts: " . Dumper(\%opts) . "\n";
    my $element;
    # if($field->get_property("render_custom") eq "small"){
    #     $element = $session->make_element("div");
    #     $element->appendChild( $session->make_text( "Thumnail of video" ) );
    #     return $element;
    # }

    

    # use Devel::StackTrace;
    # my $trace = Devel::StackTrace->new;
    # print STDERR "render_video_link stack trace: " . $trace->as_string . "\n"; 


    my $url = $value;
    if( $url =~ m{^(https?)://www\.youtube\.com/.*\bv=([^;&]+)} )
    {

        my $id = $2;
        if($field->get_property("render_custom") eq "small"){
            $element = $session->make_element("img", src => sprintf("$1://img.youtube.com/vi/%s/1.jpg", $2))
        }else{

            $element = $session->make_element( "iframe",
                        width => 420,
                        height => 315,
                        src => sprintf("$1://www.youtube.com/embed/%s", $2),
                        frameborder => 0,
                        allowfullscreen => "yes"
                    );
        }
    }
    elsif( $url =~ m{^(https?)://vimeo.com/(\d+)} ) {
        $element = $session->make_element( "iframe",
                    width => 500,
                    height => 281,
                    src => sprintf("$1://player.vimeo.com/video/%s", $2),
                    frameborder => 0,
                    allowfullscreen => "yes"
                );
    }




# <iframe width="560" height="315" src="https://www.youtube.com/embed/odrTlAO7zx8?si=7I8ixnROi37Sra5r" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

    # my $iframe = $session->make_element("iframe", "width" => "560", "height" => "315", "src" => $value);
    # $iframe->appendChild( $session->make_text( $value ) );
    return $element;

};

# sub render_video_url2
# {
#     print STDERR "video url: " . Dumper(\@_) . "\n";

#     my( $repo, $field, $value, undef, undef, $epm ) = @_;

#     # my $plugin = $repo->plugin( "Screen::$value" );
#     # return $repo->xml->create_document_fragment if !defined $plugin;

#     # return $plugin->render_action_link;
# }