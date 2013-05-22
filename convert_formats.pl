#!/usr/bin/perl
use warnings;
use strict;
use File::Find;

my $dest_dir = $ARGV[0];

find(\&wanted, $dest_dir);




exit();

sub wanted 
{
	if (-f $_)
	{
        my $probe_cmd = "ffprobe -select_streams a -show_entries stream=codec_name -of flat -loglevel quiet \"$_\"";
        my @probe_res = `$probe_cmd`;

		foreach my $res_item (@probe_res)
		{
			if($res_item =~ m/codec_name=.mp2./i)
			{
				print "MP2->MP3: $_\n";
				my $newfilename = "fixed_" . $_;
				my $conv_cmd = "ffmpeg -i \"$_\" -vn -c:a libmp3lame -f mp3 -aq 0 -loglevel quiet \"$newfilename\"";
				my @conv_res = `$conv_cmd`;
				print @conv_res;
				
				#todo: check for MP3 extenstion 
				#todo: check result of conversion
				rename "$newfilename", "$_";
			}
			elsif($res_item =~ m/codec_name=.alac./i) 
			{
				print "ALAC->MP3: $_\n";
				my $newfilename = $_;
				if ($_ =~ m/.m4a/i)
				{
					$newfilename = $_;
					$newfilename =~ s/.m4a/.mp3/gi;
				} else 
				{
					$newfilename = "fixed_" . $_ . ".mp3";
				}
				my $conv_cmd = "ffmpeg -i \"$_\" -vn -c:a libmp3lame -f mp3 -aq 0 -loglevel quiet \"$newfilename\"";
				my @conv_res = `$conv_cmd`;
				print @conv_res;
				#todo: check result of conversion
				unlink($_);
			}
			elsif($res_item !~ m/codec_name=.mp3./i)
			{
				print "UNKNOWN MEDIA TYPE: $_\n";
			}
		}		
        
    }
}
