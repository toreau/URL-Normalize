requires 'Moose', '2.2015';
requires 'URI', '5.09';
requires 'namespace::autoclean', '0.29';

on build => sub {
    requires 'ExtUtils::MakeMaker', '7.62';
    requires 'Test::More', '1.302186';
};
