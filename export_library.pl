#!/usr/bin/perl
use warnings;
use strict;

use Mac::iTunes::Library;
use Mac::iTunes::Library::XML;
use Mac::iTunes::Library::Item;
use URI::Escape;
use Encode qw(encode decode is_utf8);
use Lingua::Translit;

my $tr = new Lingua::Translit("ALA-LC RUS");

my %ignore_list = ("Музыка" => "", "Новый плейлист 1" => "");

my $usage = "Usage: export_library.pl <library.xml> <destination_dir> [--translit]\n";

die $usage if (scalar(@ARGV) < 2);
my $file = $ARGV[0];
my $dest_dir = $ARGV[1];

my $translit = 0;

if ($ARGV[2])
{
	$translit = 1 if ($ARGV[2] eq "--translit");
}

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

	# encode any strings being printed into cp866 as Windows's command line emulator uses this encoding
	print encode("cp866", $playlist_value->name());
	print "  \n";
	
	my $playlistname = encode("cp1251", $playlist_value->name());

	# ignore playlists from the ignore list (see definition of the list above)
	if ( exists($ignore_list{"$playlistname"}) ) {
    	print "Ignore this playlist\n\n";
    	next;
	}

	# Create directory for the playlist
	if ($translit)
	{
		mkdir(encode("cp1251", $tr->translit($playlist_value->name())));
	}
	else
	{
		mkdir(encode("cp1251", $playlist_value->name()));
	}
	
	
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
