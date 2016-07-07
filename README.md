# NAME

URL::Normalize - Normalize/optimize URLs.

# VERSION

Version 0.35

# SYNOPSIS

    use URL::Normalize;

    my $normalizer = URL::Normalize->new( 'http://www.example.com/display?lang=en&article=fred' );

    # Normalize the URL.
    $normalizer->remove_social_query_params;
    $normalizer->make_canonical;

    # Get the normalized version back.
    my $url = $normalizer->url;

# DESCRIPTION

When writing a web crawler, for example, it's always very costly to check if a
URL has been fetched/seen when you have millions or billions of URLs in a sort
of database. This module can help you create a unique "ID", which you then can
use as a key in a key/value-store; the key is the normalized URL, whereas all
the URLs that converts to the normalized URL are part of the value (normally an
array or hash);

    'http://www.example.com/' = {
        'http://www.example.com:80/'        => 1,
        'http://www.example.com/index.html' => 1,
        'http://www.example.com/?'          => 1,
    }

Above, all the URLs inside the hash normalizes to the key if you run these
methods:

- `make_canonical`
- `remove_directory_index`
- `remove_empty_query`

This is NOT a perfect solution. If you normalize a URL using all the methods in
this module, there is a high probability that the URL will stop "working." This
is merely a helper module for those of you who wants to either normalize a URL
using only a few of the safer methods, and/or for those of you who wants to
generate a unique "ID" from any given URL.

# CONSTRUCTORS

## new( $url )

Constructs a new URL::Normalize object:

    my $normalizer = URL::Normalize->new( 'http://www.example.com/some/path' );

You can also send in just the path:

    my $normalizer = URL::Normalize->new( '/some/path' );

The latter is NOT recommended, though, and hasn't been tested properly. You
should always give URL::Normalize an absolute URL by using [URI](https://metacpan.org/pod/URI)'s `new_abs`
(or is similar solutions).

# METHODS

## url

Get the current URL, preferably after you have run one or more of the
normalization methods.

## get\_url

DEPRECATED! Use `url` instead.

## URI

Returns a [URI](https://metacpan.org/pod/URI) representation of the current URL.

## make\_canonical

Just a shortcut for URI::URL->new->canonical->as\_string, and involves the
following steps (at least):

- Converts the scheme and host to lower case.
- Capitalizes letters in escape sequences.
- Decodes percent-encoded octets of unreserved characters.
- Removes the default port (port 80 for http).

Example:

    my $normalizer = URL::Normalize->new(
        url => 'HTTP://www.example.com:80/%7Eusername/',
    );

    $normalizer->make_canonical;

    print $normalizer->url; # http://www.example.com/~username/

## remove\_dot\_segments

The `.`, `..` and `...` segments will be removed and "folded" (or
"flattened", if you prefer) from the URL.

This method does NOT follow the algorithm described in [RFC 3986: Uniform
Resource Indentifier](http://tools.ietf.org/html/rfc3986), but rather flattens
each path segment.

Also keep in mind that this method doesn't (because it can't) account for
symbolic links on the server side.

Example:

    my $normalizer = URL::Normalize->new(
        url => 'http://www.example.com/../a/b/../c/./d.html',
    );

    $normalizer->remove_dot_segments;

    print $normalizer->url; # http://www.example.com/a/c/d.html

## remove\_directory\_index

Removes well-known directory indexes, eg. `index.html`, `default.asp` etc.

Example:

    my $normalizer = URL::Normalize->new(
        url => 'http://www.example.com/index.cgi?foo=/',
    );

    $normalizer->remove_directory_index;

    print $normalizer->url; # http://www.example.com/?foo=/

The default regular expressions for matching a directory index are:

- `/default\.aspx?`
- `/index\.cgi`
- `/index\.php\d?`
- `/index\.pl`
- `/index\.s?html?`

You can override these by sending in your own list of regular expressions
when creating the URL::Normalizer object:

    my $normalizer = URL::Normalize->new(
        url               => 'http://www.example.com/index.cgi?foo=/',
        dir_index_regexps => [ 'MyDirIndex\.html' ], # etc.
    );

You can also choose to add regular expressions after the URL::Normalize
object has been created:

    my $normalizer = URL::Normalize->new(
        url               => 'http://www.example.com/index.cgi?foo=/',
        dir_index_regexps => [ 'MyDirIndex\.html' ], # etc.
    );

    # ...

    $normalizer->add_directory_index_regexp( 'MyDirIndex\.html' );

Keep in mind that the regular expression ARE case-sensitive, so the
default `/default\.aspx?` expression WILL ALSO match `/Default\.aspx?`.

## sort\_query\_parameters

Sorts the URL's query parameters alphabetically.

Uppercased parameters will be lowercased during sorting, and if there are
multiple values for a parameter, the key/value-pairs will be sorted as well.

Example:

    my $normalizer = URL::Normalize->new(
        url => 'http://www.example.com/?b=2&c=3&a=0&A=1',
    );

    $normalizer->sort_query_parameters;

    print $normalizer->url; # http://www.example.com/?a=0&A=1&b=2&c=3

## remove\_duplicate\_query\_parameters

Removes duplicate query parameters, i.e. where the key/value combination is
identical with another key/value combination.

Example:

    my $normalizer = URL::Normalize->new(
        url => 'http://www.example.com/?a=1&a=2&b=4&a=1&c=4',
    );

    $normalizer->remove_duplicate_query_parameters;

    print $normalizer->url; # http://www.example.com/?a=1&a=2&b=3&c=4

## remove\_empty\_query\_parameters

Removes empty query parameters, i.e. where there are keys with no value. This
only removes BLANK values, not values considered to be no value, like zero (0).

Example:

    my $normalizer = URL::Normalize->new(
        url => 'http://www.example.com/?a=1&b=&c=3',
    );

    $normalizer->remove_empty_query_parameters;

    print $normalizer->url; # http://www.example.com/?a=1&c=3

## remove\_empty\_query

Removes empty query from the URL.

Example:

    my $normalizer = URL::Normalize->new(
        url => 'http://www.example.com/foo?',
    );

    $normalizer->remove_empty_query;

    print $Normalize->url; # http://www.example.com/foo

## remove\_fragment

Removes the fragment from the URL, but only if seems like they are at the end
of the URL.

For example `http://www.example.com/#foo` will be translated to
`http://www.example.com/`, but `http://www.example.com/#foo/bar` will stay
the same.

Example:

    my $normalizer = URL::Normalize->new(
        url => 'http://www.example.com/bar.html#section1',
    );

    $normalizer->remove_fragment;

    print $normalizer->url; # http://www.example.com/bar.html

You should probably use this with caution, as most web frameworks today allows
fragments for logic, for example:

- `http://www.example.com/players#all`
- `http://www.example.com/players#banned`
- `http://www.example.com/players#top`

...can all result in very different results, despite their "unfragmented" URL
being the same.

## remove\_fragments

Removes EVERYTHING after a `#`. As with `remove_fragment`, you should use this
with caution, because a lot of web applications these days returns different
output in response to what the fragment is, for example:

- `http://www.example.com/users#list`
- `http://www.example.com/users#edit`

...etc.

## remove\_duplicate\_slashes

Remove duplicate slashes from the URL.

Example:

    my $normalizer = URL::Normalize->new(
        url => 'http://www.example.com/foo//bar.html',
    );

    $normalizer->remove_duplicate_slashes;

    print $normalizer->url; # http://www.example.com/foo/bar.html

## remove\_social\_query\_parameters

Removes query parameters that are used for "social tracking."

For example, a lot of newspapers posts links to their articles on Twitter,
and adds a lot of (for us) "noise" in the URL so that they are able to
track the number of users clicking on that specific URL. This method
attempts to remove those query parameters.

Example:

    my $normalizer = URL::Normalize->new(
        url => 'http://www.example.com/?utm_campaign=SomeCampaignId',
    );

    print $normalize->url; # 'http://www.example.com/'

Default social query parameters are:

- `ncid`
- `utm_campaign`
- `utm_medium`
- `utm_source`

You can override these default values when creating the URL::Normalize
object:

    my $normalizer = URL::Normalize->new(
        url                 => 'http://www.example.com/',
        social_query_params => [ 'your', 'list' ],
    );

You can also choose to add parameters after the URL::Normalize object
has been created:

    my $normalizer = URL::Normalize->new(
        url => 'http://www.example.com/',
    );

    $normalizer->add_social_query_param( 'QueryParam' );

# SEE ALSO

- [URI](https://metacpan.org/pod/URI)
- [URI::URL](https://metacpan.org/pod/URI::URL)
- [URI::QueryParam](https://metacpan.org/pod/URI::QueryParam)
- [RFC 3986: Uniform Resource Indentifier](http://tools.ietf.org/html/rfc3986)
- [Wikipedia: URL normalization](http://en.wikipedia.org/wiki/URL_normalization)

# AUTHOR

Tore Aursand, `<toreau at gmail.com>`

# BUGS

Please report any bugs or feature requests to the web interface at [https://github.com/toreau/URL-Normalize/issues](https://github.com/toreau/URL-Normalize/issues)

# SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc URL::Normalize

You can also look for information at:

- AnnoCPAN: Annotated CPAN documentation

    [http://annocpan.org/dist/URL-Normalize](http://annocpan.org/dist/URL-Normalize)

- CPAN Ratings

    [http://cpanratings.perl.org/d/URL-Normalize](http://cpanratings.perl.org/d/URL-Normalize)

- Search CPAN

    [http://search.cpan.org/dist/URL-Normalize/](http://search.cpan.org/dist/URL-Normalize/)

# LICENSE AND COPYRIGHT

The MIT License (MIT)

Copyright (c) 2012-2016 Tore Aursand

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
