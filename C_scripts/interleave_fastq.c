#include <stdio.h>
#include <stdlib.h>
#include <string.h>



/* Input is: read1.fastq read2.fastq outfile.fastq */
/* Follow from http://www.programmingsimplified.com/c-program-merge-two-files */
/* Stephen Gross sgross@mac.com */

int main (int argc, char *argv[])
{
	if (argc != 3)
	{
		/* ARGV is program name then anything else on command line */
		/* We need at least 2 inputs to program */
		printf ("Usage: interlave_fastq read1.fastq read2.fastq\n");
		printf ("Output is to STDOUT.\n");
		printf ("-------------\ncontact: sgross@illumina.com\n");
		exit(1);
	}
	else
	{
		/*get read1, read2, and output file names */
		char *first = argv[1];
		char *second = argv[2];
		char *third = argv[3];
		FILE *read1;
		FILE *read2;
		read1 = fopen(first,"r");
		read2 = fopen(second,"r");

		int file1valid = 1;
		int file2valid = 1;

		while (1)
		{
			char f1line[1000];
			char f2line[1000];
			int counter = 0;

			if (feof(read1)) 
			{
				break;
			}
			if (feof(read2)) 
			{
				break;
			}
			while ((fgets(f1line, 1000, read1)) != NULL ) 
			{

				/*get 4 lines from file 1 */
				fputs (f1line, stdout);
				counter++;
				if (counter == 4) 
				{
					counter = 0;
					break;
				}
			}
			while ((fgets(f2line, 1000, read2)) != NULL ) 
			{

				/* get 4 lines from file 2 */
				fputs (f2line, stdout);
				counter++;
				if (counter == 4) 
				{
					counter = 0;
					break;

				}
			}
		}

	fclose(read1);
	fclose(read2);
	}
return 0;
}