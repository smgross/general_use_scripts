#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Usage: 

	Provide 2 strings on command line.
	Check that strings are equal length.
	If so, report back what fraction of characters match.
	
*/


int main (int argc, char *argv[])
{

/*  Troubleshooting: Commented out.
	printf ("argv1 %s\n", argv[1]);
	printf ("argv2 %s\n", argv[2]);
*/

	if (argc != 3)
	{
		/* ARGV is program name then anything else on command line */
		/* We need at least 2 inputs to program */
		printf ("ERROR\n");
		exit(1);
	}
	else
	{
		char *first = argv[1];
		char *second = argv[2];
		
		/*
		printf ("I see %s and %s\n", first, second);
		printf ("I see %c\n", first[1]);
		*/
		
		int firstlength = strlen(first);
		
		if (firstlength == strlen(second))
		{
		}
		else 
		{
			printf ("Strings are of unequal length\n");
			exit(1);
		}
		
		/* iterate over the string arrays */
		float matches;
		int i;
		for (i = 0; i < firstlength; i++)
		{
			if (first[i] == second[i]) 
			{
				matches++;
			}
		}
		
		float perc = matches / firstlength;
		
		printf ("%f\n", perc);	
		
		
	}
}
		