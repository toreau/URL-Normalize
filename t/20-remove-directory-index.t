#!/usr/bin/env perl
#
use 5.006;
use strict;
use warnings FATAL => 'all';

use Test::More;

BEGIN {
    use_ok( 'URL::Normalize' );
}

{
    # Remove well-known directory indexes.
    my @indexes = (
        'default.asp',
        'default.aspx',
        'index.cgi',
        'index.htm',
        'index.html',
        'index.php',
        'index.php5',
        'index.pl',
        'index.shtml',
    );

    my %urls = ();

    foreach my $index ( @indexes ) {
        $urls{ 'http://www.example.com/' . $index                     } = 'http://www.example.com/';
        $urls{ 'http://www.example.com/' . $index . '?foo=/' . $index } = 'http://www.example.com/?foo=/' . $index;
    }

    foreach ( keys %urls ) {
        my $normalizer = URL::Normalize->new(
            url => $_,
        );

        $normalizer->remove_directory_index;

        ok( $normalizer->url eq $urls{$_}, "$_ eq $urls{$_} - got " . $normalizer->url );
    }
}

{
    # Check for default regular expressions.
    my $normalizer = URL::Normalize->new( 'http://www.example.com/' );
    is_deeply( $normalizer->dir_index_regexps, ['/default\.aspx?', '/index\.cgi', '/index\.php\d?', '/index\.pl', '/index\.s?html?'], 'Default dir_index_regexps matches' );

    # Add to dir_index_regexps array ref.
    $normalizer->add_directory_index_regexp( '/Default\.aspx?' );
    is_deeply( $normalizer->dir_index_regexps, ['/default\.aspx?', '/index\.cgi', '/index\.php\d?', '/index\.pl', '/index\.s?html?', '/Default\.aspx?'], 'Default dir_index_regexps matches' );
}

done_testing;
