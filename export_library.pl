#!/usr/bin/perl
use warnings;
use strict;

#use utf8;

use Mac::iTunes::Library;
use Mac::iTunes::Library::XML;
use Mac::iTunes::Library::Item;
use URI::Escape;
use Encode qw(encode decode is_utf8);

my %ignore_list = ("Юмор" => "", "Новый плейлист 1" => "", "" => "");

my $usage = "Usage: parse_itunes.pl <library.xml> <destination_dir>\n";

die $usage if (scalar(@ARGV) != 2);
my $file = $ARGV[0];
my $dest_dir = $ARGV[1];

# Make a new Library
print "Loading '$file'...";
my $library = Mac::iTunes::Library::XML->parse($file);
print " loaded " . $library->num() . " items.\n"; 


# Get the hash of playlists

my $playlist = Mac::iTunes::Library::Playlist->new();

my %playlists = $library->playlists();

my $playlist_key="";
my $playlist_value="";

chdir($dest_dir);	

while(($playlist_key,$playlist_value) = each %playlists){
	if  ($playlist_value->{'items'} )  
	{


	print "Processing playlist: ";
	print encode("cp866", $playlist_value->name());
	print "  ";
	print "\n";

	my $playlistname = encode("cp1251", $playlist_value->name());
	if ( exists($ignore_list{"$playlistname"}) ) {
    	print "Ignore this playlist\n\n";
	}

	# Create directory for the playlist

	mkdir(encode("cp1251", $playlist_value->name()));
	
	my @items = $playlist_value->items();

	if ( @items )
	{
		foreach my $item (@items)
		{
		#	print "   ";
		#	print $item->name();
		#	print "  ";
		#	if ($item->album)
		#	{
		#		print $item->album();
		#		print "  ";
		#	}
#			my $true_location = $item->location();
#			$true_location =~ s/file:\/\/localhost\///gi;
#			print uri_unescape($true_location);
#			print "\n";
		}
	
	}

	}
}


exit();
