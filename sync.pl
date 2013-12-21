#!/usr/bin/env perl

use warnings;
use strict;

use WWW::Mechanize;
use XML::Simple;
use File::Spec::Functions;

#--------------------------------------------------------------------------#
# CONSTANTS
#--------------------------------------------------------------------------#

use constant USERNAME => '** Roboform Online Username **';
use constant PASSWORD => '** Roboform Onlune Password **';
use constant DATA_DIR => './roboform-data';

#--------------------------------------------------------------------------#
# MAIN
#--------------------------------------------------------------------------#

## prepare objects
my $mech = WWW::Mechanize->new(agent_alias => 'Mac Safari');
my $xs = XML::Simple->new(NoSort => 1);

## get login screen
$mech->get('https://online.roboform.com/account/login');

## submit login form
$mech->submit_form(
    form_id => 'login_form',
    fields  => {
        username => USERNAME,
        password => PASSWORD,
    },
);
die 'Cannot login.' unless $mech->content =~ /Logged in as/;

## extract session ID
my ($aid) = $mech->content =~ m{name="aid" value="([^"]+)">};
die 'Cannot find aid.' unless $aid;

## lets go deeper
recurse('.');

#--------------------------------------------------------------------------#
# FUNCTIONS
#--------------------------------------------------------------------------#

=head2 recurse($dir)

Recursively download all Roboform pass cards.

=cut

sub recurse {
    my ($dir) = @_;

    ## create dir if needed
    my $dir_path = catdir(DATA_DIR, $dir);
    print $dir_path;
    mkdir($dir_path) unless -d $dir_path;

    ## fetch data for the current dir
    my $data = dir($dir);

    if (exists $data->{file} && ref $data->{file} eq 'ARRAY') {
        foreach my $file (@{ $data->{file} }) {
            my $path = catfile(DATA_DIR, $dir, $file->{content});

            ## skip this file if we already fetched it
            ## in case fetch fails and we are retrying
            next if -e $path;

            ## save file contents
            open(my $fh, ">:encoding(UTF-8)", $path)
                || die "Can't open $path: $!";
            print $fh file($file->{fullName});
            close($fh);
        }
    }

    if (exists $data->{dir} && ref $data->{dir} eq 'ARRAY') {
        foreach my $dir (@{ $data->{dir} }) {
            recurse($dir->{fullName});
        }
    }

    return 1;
}

=head2 dir($dir)

Fetch directory and return HashRef of all directories and files

=cut

sub dir {
    my ($dir) = @_;

    $mech->get(
        "https://online.roboform.com/requests/fileList.php?d=$dir&aid=$aid");

    die "Cannot fetch dir $dir: " . $mech->status unless $mech->success;

    return $xs->XMLin($mech->content);
}

=head2 file($file)

Fetch and return XML contents of the passcard file.

=cut

sub file {
    my ($file) = @_;

    $mech->post(
        'https://online.roboform.com/requests/filePreview.php',
        {   aid              => $aid,
            f                => $file,
            is_rfonline      => 1,
            rf_savepasscheck => 'on',
        },
        'Accept' => 'application/xml, text/xml, */*',
    );

    die "Cannot fetch file $file: " . $mech->status unless $mech->success;

    return $mech->content;
}
