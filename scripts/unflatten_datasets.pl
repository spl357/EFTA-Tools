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
	for(my $i=0; $i < $dir_count - 1; $i++) {
		my $dir_name = sprintf("%0.4d", $i);
		if ( ! -d "$dir_name") {
			print "Creating directory $dir_name\n";
			mkdir $path . "/" . $dir_name or die("mkdir operation failed: $!\n");
		} else {
			die "Error: directory $dir_name already exists and it shouldn't. The destination directory need to be cleaned up by hand.\n";
		}
	}
	print "Done creating $dir_count sub-directories. Moving files into new sub-directories...\n";
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
		for (my $j = 0; $j <= $batch_size; $j++) {
			my $file_name = shift(@file_names);
			if(defined $file_name) {
				chomp $file_name;
				print "Moving $file_name to $base_path$dir_name\n";
				move("$file_name", "$base_path$dir_name/")
					or die "move operation failed: $!";
			} else {
				next; 
			}
		}
	}
	print "All operations completed.\n";
	return;
}

1;
