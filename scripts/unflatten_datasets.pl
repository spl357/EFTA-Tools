#!/usr/bin/perl
use strict; use warnings;       #use diagnostics
use File::Copy;	        		

# configuration
my $dataset = "dataset_00009/";	# the dataset to be unflattened
my $subdir = "pdfs/";			# the name of the sub-directory in the dataset directory containing the files
my $extension = ".pdf";			# the extension of the file
my $batch_size = 1000;			# files per sub-directory

# make the numbered sub-sirectories and move files into them.
make_numbered_dirs($dataset, $subdir, $extension, $batch_size);
move_files_to_numbered_dirs($dataset, $subdir, $extension, $batch_size);

sub make_numbered_dirs {
	my($dataset, $subdir, $extension, $batch_size) = @_;
	my $path = "$dataset$subdir";
	chomp(my @file_names = `ls $path`);
	my $dir_count = scalar @file_names / $batch_size;
	print "Found " . scalar @file_names . " files. With a batch size of $batch_size, $dir_count directories are needed. Creating them...\n";
	for(my $i=0; $i < $dir_count; $i++) {
		my $dir_name = sprintf("%0.4d", $i);
		if ( ! -d "$dir_name") {
			mkdir $path . "/" . $dir_name or die("mkdir operation failed: $!\n");
			update_progress_bar($i, int($dir_count));
		} else {
			die "Error: directory $dir_name already exists and it shouldn't. The destination directory need to be cleaned up by hand.\n";
		}
	}
	print "\n\nDone creating " . int($dir_count) . " sub-directories. Migrating files...\n";
	return;
}

sub move_files_to_numbered_dirs {
	my($dataset, $subdir, $extendion, $batch_size) = @_;
	my $base_path = "$dataset$subdir";
	my @file_names = `find $base_path -name "*$extension" | sort`;
	my $total_files = scalar @file_names;
	my $num_batches = int($total_files/$batch_size);

	print "Moving a total of $total_files in $num_batches batches of $batch_size files each.\n";

	for (my $i = 0; $i <= $num_batches; $i++) {
		my $dir_name = sprintf("%0.4d",$i);				
		for (my $j = 0; $j < $batch_size; $j++) {
			my $file_name = shift(@file_names);
			if(defined $file_name) {
				chomp $file_name;
				move("$file_name", "$base_path$dir_name/")
					or die "move operation failed: $!";
				update_progress_bar($i, $num_batches);	
			} else {
				next; 
			}
		}
	}
	print "All operations completed.\n";
	return;
}

sub update_progress_bar {
    my ($current, $total) = @_;
    my $percent = int($current / $total * 100);
    my $bar_length = 50;
    my $filled = int($percent / (100 / $bar_length));
    printf "\r[%*s] %3d%%", $bar_length, '.' x $filled . ' ' x ($bar_length - $filled), $percent;
}

1;
