#!/usr/bin/perl
use warnings;
use strict;

use Mac::iTunes::Library;
use Mac::iTunes::Library::XML;
use Mac::iTunes::Library::Item;
use URI::Escape;
use Encode qw(encode decode is_utf8);
use Lingua::Translit;

my $tr = new Lingua::Translit("GOST 7.79 RUS");

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

	print "==================================================================\nProcessing playlist: ";

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
		#	if ($item->album)
		#	{
		#		print encode("cp866",$item->album());
		#		print "  ";
		#	}
		#	if ($item->artist)
		#	{
		#		print encode("cp866",$item->artist());
		#		print "  ";
		#	}
		#	print encode("cp866",$item->name());
		#	print "  ";

			my $true_location = $item->location();
			$true_location =~ s/file:\/\/localhost\///gi;
			$true_location = uri_unescape($true_location);
			print encode("cp866", (decode("utf-8", $true_location)));
			print "\n";

			my $copy_cmd = "copy \"" . encode("cp1251", (decode("utf-8", $true_location))) . "\" \""; # . $dest_dir . "\/";

			my $new_file_name = "";
			my $check_full_path = "";

			if ($translit)
			{	
				# Translit file name
				$copy_cmd = $copy_cmd . encode("cp1251",$tr->translit($playlist_value->name())) . "\/";

				if ($item->artist)
				{
					$new_file_name = encode("cp1251",$tr->translit($item->artist())) . " - ";
				}

				my $check_name = $new_file_name . encode("cp1251",$tr->translit($item->name())) . ".mp3";
				$check_full_path = encode("cp1251",$tr->translit($playlist_value->name())) . "\/" . $check_name;
				my $postfix = 1;
					
				while (-e $check_full_path)
				{
					$check_name = $new_file_name . encode("cp1251",$tr->translit($item->name())) . "_" . $postfix . ".mp3\"";
					$check_full_path = encode("cp1251",$tr->translit($playlist_value->name())) . "\/" . $check_name;					
					$postfix = $postfix + 1;
				}
			
				$new_file_name = $check_name;	
				
			}
			else
			{
				# Do not translit file name
				$copy_cmd = $copy_cmd . encode("cp1251",$playlist_value->name()) . "\/";

				if ($item->artist)
				{
					$new_file_name = encode("cp1251",$item->artist()) . " - ";
				}

				my $check_name = $new_file_name . encode("cp1251",$item->name()) . ".mp3";
				$check_full_path = encode("cp1251",$playlist_value->name()) . "\/" . $check_name;
				my $postfix = 1;
					
				while (-e $check_full_path)
				{
					$check_name = $new_file_name . encode("cp1251",$item->name()) . "_" . $postfix . ".mp3\"";
					$check_full_path = encode("cp1251",$playlist_value->name()) . "\/" . $check_name;					
					$postfix = $postfix + 1;
				}
			
				$new_file_name = $check_name;				
			}

			$copy_cmd = $copy_cmd . $new_file_name . "\""; 			
			$copy_cmd =~ s/\//\\/gi;
			my @copy_res = `$copy_cmd`;
			print @copy_res;

			# TODO: check if copy was successful

			# replace tags only if they are not empty
        	if (( $item->artist) || ( $item->album ) || ( $item->name ))
        	{
                my $updatetagscmd = "mp3info2";

                if ($item->artist)
                {
                		if ($translit)
                		{
	                		$updatetagscmd .= " -a \"" . encode("cp1251", $tr->translit($item->artist)). "\"";
                		} else {
                			$updatetagscmd .= " -a \"" . encode("cp1251", $item->artist). "\"";
                		}
                }

                if ($item->name)
                {
                        
                		if ($translit)
                		{
	                		$updatetagscmd .= " -t \"" . encode("cp1251", $tr->translit($item->name)). "\"";
                		} else {
                			$updatetagscmd .= " -t \"" . encode("cp1251", $item->name). "\"";
                		}
                        
                }

                if ($item->album)
                {                        
                        if ($translit)
                		{
	                		$updatetagscmd .= " -l \"" . encode("cp1251", $tr->translit($item->album)). "\"";
                		} else {
                			$updatetagscmd .= " -l \"" . encode("cp1251", $item->album). "\"";
                		}
                        
                }

                $updatetagscmd .= " \"$check_full_path\"";
                my @sreplacetags = `$updatetagscmd`;
                print @sreplacetags;
        	}	

		}
	}

	}
}


exit();
