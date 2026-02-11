This perl script unflattens the files in a dataset for those that prefer to have all of the files split across sub-directories. To use it, open it in and editor and customize the configuration options at the top. By default it looks for pdf files in $PWD/dataset_00009/pdfs/. It will automatically calculate the number of sub-directories and the batch size, create those directories, then move all of the pdf files into the sub-directories.

# configuration
my $dataset = "dataset_00009/"; # the dataset to be unflattened
my $subdir = "pdfs/";           # the name of the sub-directory in the dataset directory containing the files
my $extension = ".pdf";         # the extension of the file
my $batch_size = 1000;          # files per sub-directory
