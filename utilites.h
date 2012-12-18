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

unsigned char dcx(char c)
{
	switch (toupper(c))
	{
		case 'B':{return 0x0B;}
		case 'D':{return 0x1B;}
		case 'H':{return 0x2B;}
		default:{return 0;}
	}
}

unsigned char ldax(char c)
{
	switch (toupper(c))
	{
		case 'B':{return 0x0A;}
		case 'C':{return 0x1A;}
		default:{return 0;}
	}
}

unsigned char sub(char c)
{
	switch(toupper(c))
	{
		case 'B':{return 0x90;}
		case 'C':{return 0x91;}
		case 'D':{return 0x92;}
		case 'E':{return 0x93;}
		case 'H':{return 0x94;}
		case 'L':{return 0x95;}
		case 'M':{return 0x96;}
		case 'A':{return 0x97;}
		default:{return 0;}
	}
}

unsigned char cmp(char c)
{
	switch(toupper(c))
	{
		case 'B':{return 0xB8;}
		case 'C':{return 0xB9;}
		case 'D':{return 0xBA;}
		case 'E':{return 0xBB;}
		case 'H':{return 0xBC;}
		case 'L':{return 0xBD;}
		case 'M':{return 0xBE;}
		case 'A':{return 0xBF;}
		default:{return 0;}
	}
}

unsigned char dcr(char c)
{
	switch (toupper(c))
	{
		case 'B':{return 0x05;}
		case 'C':{return 0x0D;}
		case 'D':{return 0x15;}
		case 'E':{return 0x1D;}
		case 'H':{return 0x25;}
		case 'L':{return 0x2D;}
		case 'M':{return 0x35;}
		case 'A':{return 0x3D;}
		default:{return 0;}
	}
}