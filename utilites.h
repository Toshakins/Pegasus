#include <cctype>

unsigned char adc(char c)
{
	switch (toupper(c))
	{
		case 'B':{return 0x88;}
		case 'C':{return 0x89;}
		case 'D':{return 0x8A;}
		case 'E':{return 0x8B;}
		case 'H':{return 0x8C;}
		case 'L':{return 0x8D;}
		case 'M':{return 0x8E;}
		case 'A':{return 0x8F;}
	}
}

unsigned char ora(char c)
{
	switch (toupper(c))
	{
		case 'B':{return 0xB0;}
		case 'C':{return 0xB1;}
		case 'D':{return 0xB2;}
		case 'E':{return 0xB3;}
		case 'H':{return 0xB4;}
		case 'L':{return 0xB5;}
		case 'M':{return 0xB6;}
		case 'A':{return 0xB7;}
	}
}