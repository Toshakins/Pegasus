#include <vector>
#include <map>

vector<uint8_t> ops;
map<string, uint8_t> consts;
map<string, uint8_t> DBs;
map<string, uint16_t> DDs;
map<string, uint16_t> pointers;

uint8_t mov(char x, char y)
{
	uint8_t opcode;
	switch (toupper(x))
	{
		case 'B': {opcode = 0x40; break;}
		case 'C': {opcode = 0x48; break;}
		case 'D': {opcode = 0x50; break;}
		case 'E': {opcode = 0x58; break;}
		case 'H': {opcode = 0x60; break;}
		case 'L': {opcode = 0x68; break;}
		case 'M': {opcode = 0x70; break;}
		case 'A': {opcode = 0x78; break;}
		default: {return 0;}
	}
	switch (toupper(y))
	{
		case 'C': {opcode += 1; break;}
		case 'D': {opcode += 2; break;}
		case 'E': {opcode += 3; break;}
		case 'H': {opcode += 4; break;}
		case 'L': {opcode += 5; break;}
		case 'M': {opcode += 6; break;}
		case 'A': {opcode += 7; break;}
		default: {return 0;}
	}
	return opcode;
}

uint8_t ana(char r)
{
	uint8_t opcode;
	switch (toupper(r))
	{
		case 'B': {opcode = 0xA0;break;}
		case 'C': {opcode = 0xA1;break;}
		case 'D': {opcode = 0xA2;break;}
		case 'E': {opcode = 0xA3;break;}
		case 'H': {opcode = 0xA4;break;}
		case 'L': {opcode = 0xA5;break;}
		case 'M': {opcode = 0xA6;break;}
		case 'A': {opcode = 0xA7;break;}
		default: {return 0;}
	}
	return opcode;
}

uint8_t inr(char r)
{
	uint8_t opcode;
	switch (toupper(r))
	{
		case 'A': {opcode = 0x3C;break;}
		case 'B': {opcode = 0x04;break;}
		case 'C': {opcode = 0x0C;break;}
		case 'D': {opcode = 0x14;break;}
		case 'E': {opcode = 0x1C;break;}
		case 'H': {opcode = 0x24;break;}
		case 'L': {opcode = 0x2C;break;}
		case 'M': {opcode = 0x34;break;}
		default: {return 0;}
	}
	return opcode;
}