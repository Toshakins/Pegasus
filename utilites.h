#include <vector>
#include <map>

vector<uint8_t> commands;
map<string, uint8_t> consts;
map<string, uint8_t> DBs;
map<string, uint16_t> DDs;
map<string, uint16_t> pointers;

int mov(char x, char y)
{
	if (regs.find(x) != set::empty && regs.find(y) != set::empty)
	{
		uint8_t opcode;
		switch toupper(x):
		{
			case 'B': {opcode = 0x40; break;}
			case 'C': {opcode = 0x48; break;}
			case 'D': {opcode = 0x50; break;}
			case 'E': {opcode = 0x58; break;}
			case 'H': {opcode = 0x60; break;}
			case 'L': {opcode = 0x68; break;}
			case 'M': {opcode = 0x70; break;}
			case 'A': {opcode = 0x78; break;}
			default: {return 1;}
		}
		switch topupper(y):
		{
			case 'C': {opcode += 1; break;}
			case 'D': {opcode += 2; break;}
			case 'E': {opcode += 3; break;}
			case 'H': {opcode += 4; break;}
			case 'L': {opcode += 5; break;}
			case 'M': {opcode += 6; break;}
			case 'A': {opcode += 7; break;}
			default: {return 1;}
		}
	}
	else return 1;
	return 0;
}