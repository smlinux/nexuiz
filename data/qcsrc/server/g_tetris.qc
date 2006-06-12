/*

Installation:

in weapons.qc add TetrisImpulses(); to ImpulseCommands

in progs.src add tetris.qc after subs.qc
in client.qc add if (TetrisPreFrame()) return; to  PlayerPreThink
in client.qc add if (TetrisPostFrame()) return; to PlayerPostThink

*/

.vector tet_org;

.float tetris_on, tet_time, tet_autodown;
.vector piece_pos;
.float piece_type, next_piece, tet_score, tet_lines;

var float tet_high_score = 0;

float TET_LINES = 20;
float TET_WIDTH = 10;
//character values
float TET_BORDER = 132;
float TET_BLOCKS = 132; // +1 = first color, +2, +3;
float TET_SPACE = 32; // blankness



float TETKEY_UP = 1;
float TETKEY_DOWN = 2;
float TETKEY_LEFT = 4;
float TETKEY_RIGHT = 8;
float TETKEY_ROTLEFT = 16;
float TETKEY_ROTRIGHT = 32;

float PIECES = 7;

.float line1, line2, line3, line4, line5, line6, line7,
line8, line9, line10, line11, line12, line13, line14, line15,
line16, line17, line18, line19, line20;


float	SVC_CENTERPRINTa		= 26;


/*
*********************************

Library Functions

*********************************
*/
void (float ln, float vl) SetLine =
{
	if (ln == 1)
		self.line1 = vl;
	else if (ln == 2)
		self.line2 = vl;
	else if (ln == 3)
		self.line3 = vl;
	else if (ln == 4)
		self.line4 = vl;
	else if (ln == 5)
		self.line5 = vl;
	else if (ln == 6)
		self.line6 = vl;
	else if (ln == 7)
		self.line7 = vl;
	else if (ln == 8)
		self.line8 = vl;
	else if (ln == 9)
		self.line9 = vl;
	else if (ln == 10)
		self.line10 = vl;
	else if (ln == 11)
		self.line11 = vl;
	else if (ln == 12)
		self.line12 = vl;
	else if (ln == 13)
		self.line13 = vl;
	else if (ln == 14)
		self.line14 = vl;
	else if (ln == 15)
		self.line15 = vl;
	else if (ln == 16)
		self.line16 = vl;
	else if (ln == 17)
		self.line17 = vl;
	else if (ln == 18)
		self.line18 = vl;
	else if (ln == 19)
		self.line19 = vl;
	else if (ln == 20)
		self.line20 = vl;
};

float (float ln) GetLine =
{
	if (ln == 1)
		return self.line1;
	else if (ln == 2)
		return self.line2;
	else if (ln == 3)
		return self.line3;
	else if (ln == 4)
		return self.line4;
	else if (ln == 5)
		return self.line5;
	else if (ln == 6)
		return self.line6;
	else if (ln == 7)
		return self.line7;
	else if (ln == 8)
		return self.line8;
	else if (ln == 9)
		return self.line9;
	else if (ln == 10)
		return self.line10;
	else if (ln == 11)
		return self.line11;
	else if (ln == 12)
		return self.line12;
	else if (ln == 13)
		return self.line13;
	else if (ln == 14)
		return self.line14;
	else if (ln == 15)
		return self.line15;
	else if (ln == 16)
		return self.line16;
	else if (ln == 17)
		return self.line17;
	else if (ln == 18)
		return self.line18;
	else if (ln == 19)
		return self.line19;
	else if (ln == 20)
		return self.line20;
	else
		return 0;
};

float(float x, float dat) GetXBlock =
{
	if (x == 1)
		return dat & 3;
	else if (x == 2)
		return (dat & 12) / 4;
	else if (x == 3)
		return (dat & 48) / 16;
	else if (x == 4)
		return (dat & 192) / 64;
	else if (x == 5)
		return (dat & 768) / 256;
	else if (x == 6)
		return (dat & 3072) / 1024;
	else if (x == 7)
		return (dat & 12288) / 4096;
	else if (x == 8)
		return (dat & 49152) / 16384;
	else if (x == 9)
		return (dat & 196608) / 65536;
	else if (x == 10)
		return (dat & 786432) / 262144;
	else
		return 0;
};

float(float x, float dat, float new) SetXBlock =
{
	if (x == 1)
		return (dat - (dat & 3)) | new;
	else if (x == 2)
		return (dat - (dat & 12)) | (new*4);
	else if (x == 3)
		return (dat - (dat & 48)) | (new*16);
	else if (x == 4)
		return (dat - (dat & 192)) | (new*64);
	else if (x == 5)
		return (dat - (dat & 768)) | (new*256);
	else if (x == 6)
		return (dat - (dat & 3072)) | (new*1024);
	else if (x == 7)
		return (dat - (dat & 12288)) | (new*4096);
	else if (x == 8)
		return (dat - (dat & 49152)) | (new*16384);
	else if (x == 9)
		return (dat - (dat & 196608)) | (new*65536);
	else if (x == 10)
		return (dat - (dat & 786432)) | (new*262144);
	else
		return dat;
};


float(float x, float y) GetSquare =
{
	return GetXBlock(x,  GetLine(y));
};

void (float x, float y, float val) SetSquare =
{
	float dat;

	dat = GetLine(y);
	dat  = SetXBlock(x, dat, val & 3);
	SetLine(y, dat);
};



vector(float pc) PieceShape =
{

/*
1 =
 ##
 ##
*/
	if (pc == 1)
		return '20 20 0'; // 1 * 4 + 1 * 16
/*
2 =

####
*/
	else if (pc == 2)
		return '85 0 0';

/*
3 =

###
#
*/
	else if (pc == 3)
		return '21 1 0';
/*
4 =

#
###
*/
	else if (pc == 4)
		return '1 21 0';
/*
5 =
##
 ##
*/
	else if (pc == 5)
		return '5 20 0';

/*
6 =
 ##
##
*/
	else if (pc == 6)
		return '20 5 0';

/*
7 =
 #
###
*/
	else if (pc == 7)
		return '4 21 0';


	else
		return '0 0 0';

}

// do x 1..4 and y 1..4 in case of rotation
float(float x, float y, float rot, float pc) PieceMetric =
{
	float t;
	vector piece_dat;

	// return bits of a piece
	if (rot == 1) // 90 degrees
	{
		t = y;
		y = x;
		x = 5 - t;
	}
	else if (rot == 2)//180
	{
		x = 5 - x;
		y = 3 - y;
	}
	else if (rot == 3) // 270
	{
		t = y;
		y = 5 - x;
		x = t;
	}
	if (x < 1 || y < 1 || x > 4 || y > 2)
		return 0;
	piece_dat = PieceShape(pc);
	if (y == 1)
		return GetXBlock(x, piece_dat_x); // first row
	else if (y == 2)
		return GetXBlock(x, piece_dat_y); // second row
	else if (y == 3)
		return GetXBlock(x, piece_dat_z); // third row (doesn't exist)
	else
		return 0; // illegal parms
};
/*
*********************************

Draw

*********************************
*/


/* some prydon gate functions to make life easier....

somewhat modified because we don't need all the fanciness Prydon Gate is capable of

*/

void(float c1, float c2, float c3, float c4, float c5, float c6) p6 =
{
	WriteChar(MSG_ONE, c1);
	WriteChar(MSG_ONE, c2);
	WriteChar(MSG_ONE, c3);
	WriteChar(MSG_ONE, c4);
	WriteChar(MSG_ONE, c5);
	WriteChar(MSG_ONE, c6);
};

float(float num, float dig) pnum =
{
	local float f, i;
	if (num < 0)
	{
		WriteChar(MSG_ONE, 45);
		num = 0 - num;
	}
	f = floor(num / 10);
	num = num - (f * 10);
	if (f)
		dig = pnum(f, dig+1);
	else
	{
		// pad to 6
		for (i = 0; i < (5 - dig); i = i + 1)
			WriteChar(MSG_ONE, TET_SPACE);
	}
	WriteChar(MSG_ONE, 48 + num);
	return dig;
};

void (float ln) DrawLine =
{
	float x, d;
	WriteChar(MSG_ONE, TET_BORDER);

	for (x = 1; x <= TET_WIDTH; x = x + 1)
	{
		d = GetSquare(x, ln);
		if (d)
			WriteChar(MSG_ONE, TET_BLOCKS + d);
		else
			WriteChar(MSG_ONE, TET_SPACE);
	}
	WriteChar(MSG_ONE, TET_BORDER);
}

void (float pc, float ln) DrawPiece =
{
	float x, d, piece_ln, color;
	vector piece_dat;
	color = pc & 3;
	if (color == 0) // 4
		color = 1;
	WriteChar(MSG_ONE, TET_SPACE); // pad to 6

	piece_dat = PieceShape(pc);
	if (ln == 1)
		piece_ln = piece_dat_x;
	else
		piece_ln = piece_dat_y;
	for (x = 1; x <= 4; x = x + 1)
	{
		d = GetXBlock(x, piece_ln) * color;
		if (d)
			WriteChar(MSG_ONE, TET_BLOCKS + d);
		else
			WriteChar(MSG_ONE, TET_SPACE);
	}
	WriteChar(MSG_ONE, TET_SPACE);	// pad to 6
}
void() Draw_Tetris =
{
	float i;
	msg_entity = self;
	WriteChar(MSG_ONE, SVC_CENTERPRINTa);
	// decoration
	for (i = 1; i <= (TET_WIDTH + 2); i = i + 1)
		WriteChar(MSG_ONE, TET_BORDER);
	p6(' ', ' ', ' ', ' ', ' ', ' ');
	WriteChar(MSG_ONE, 10);
	for (i = 1; i <= TET_LINES; i = i + 1)
	{
		DrawLine(i);
		if (i == 1)
			p6(' ', 'N', 'E', 'X', 'T', ' ');
		else if (i == 3)
			DrawPiece(self.next_piece, 1);
		else if (i == 4)
			DrawPiece(self.next_piece, 2);
		else if (i == 6)
			p6(' ', 'L', 'I', 'N', 'E', 'S');
		else if (i == 7)
			pnum(self.tet_lines, 0);
		else if (i == 9)
			p6(' ', 'S', 'C', 'O', 'R', 'E');
		else if (i == 10)
			pnum(self.tet_score, 0);
		else if (i == 12)
			p6(' ', 'H', 'I', 'G', 'H', ' ');
		else if (i == 13)
			p6(' ', 'S', 'C', 'O', 'R', 'E');
		else if (i == 14)
			pnum(tet_high_score, 0);
		else if (i == 16)
			p6(' ', 'L', 'E', 'V', 'E', 'L');
		else if (i == 17)
			pnum(floor(self.tet_lines / 20)+ 1, 0);
		else
			p6(' ', ' ', ' ', ' ', ' ', ' ');
		WriteChar(MSG_ONE, 10);
	}
	// decoration

	for (i = 1; i <= (TET_WIDTH + 2); i = i + 1)
		WriteChar(MSG_ONE, TET_BORDER);
	p6(' ', ' ', ' ', ' ', ' ', ' ');
	WriteChar(MSG_ONE, 10);
	WriteChar(MSG_ONE, 0);
}
/*
*********************************

Game Functions

*********************************
*/

// reset the game
void() ResetTetris =
{
	float i;

	for (i=1; i<=TET_LINES; i = i + 1)
		SetLine(i, 0);
	self.piece_pos = '0 0 0';
	self.piece_type = 0;
	self.next_piece = self.tet_lines = self.tet_score = 0;

};

void () Tet_GameOver =
{
	centerprint(self, "Game Over");
	self.tetris_on = 0;
	ResetTetris();
	self.movetype = MOVETYPE_WALK;
};



/*
*********************************

Game Mechanics

*********************************
*/
float() RandomPiece =
{
	return floor(random() * PIECES) + 1;
};

void(float n) TetAddScore =
{
	self.tet_score = self.tet_score + n;
	if (self.tet_score > tet_high_score)
		tet_high_score = self.tet_score;
};
float CheckMetrics(float piece, float orgx, float orgy, float rot) =
{
	// check to see if the piece, if moved to the locations will overlap

	float x, y;
	// why did I start counting from 1, damnit
	orgx = orgx - 1;
	orgy = orgy - 1;

	for (y = 1; y < 5; y = y + 1)
	{
		for (x = 1; x < 5; x = x + 1)
		{
			if (PieceMetric(x, y, rot, piece))
			{
				if (GetSquare(x + orgx, y + orgy))
					return FALSE; // uhoh, gonna hit something.
				if (x+orgx<1 || x+orgx > TET_WIDTH || y+orgy<1 || y+orgy> TET_LINES)
					return FALSE; // ouside the level
			}
		}
	}
	return TRUE;
}

void ClearPiece(float piece, float orgx, float orgy, float rot) =
{

	float x, y;
	// why did I start counting from 1, damnit
	orgx = orgx - 1;
	orgy = orgy - 1;

	for (y = 1; y < 5; y = y + 1)
	{
		for (x = 1; x < 5; x = x + 1)
		{
			if (PieceMetric(x, y, rot, piece))
			{
				SetSquare(x + orgx, y + orgy, 0);
			}
		}
	}
}
void CementPiece(float piece, float orgx, float orgy, float rot) =
{
	float color;
	float x, y;
	// why did I start counting from 1, damnit
	orgx = orgx - 1;
	orgy = orgy - 1;

	color = piece & 3;
	if (color == 0) // 4
		color = 1;

	for (y = 1; y < 5; y = y + 1)
	{
		for (x = 1; x < 5; x = x + 1)
		{
			if (PieceMetric(x, y, rot, piece))
			{
				SetSquare(x + orgx, y + orgy, color);
			}
		}
	}
}

float LINE_LOW = 349525;
float LINE_HIGH = 699050; // above number times 2

void() CompletedLines =
{
	float y, cleared, ln;

	cleared = 0;
	y = TET_LINES;
	while(y >= 1)
	{
		ln = GetLine(y);
		if (((ln & LINE_LOW) | ((ln & LINE_HIGH)/2)) == LINE_LOW)
			cleared = cleared + 1;
		else
			y = y - 1;
		ln = GetLine(y - cleared);
		SetLine(y, ln);
	}
	self.tet_lines = self.tet_lines + cleared;
	TetAddScore(cleared * cleared * 10);
};

void(float keyss) HandleGame =
{

	// first off, we need to see if we need a new piece
	vector check_pos;
	float brand_new;
	brand_new = 0;
	if (self.tet_time > time)
		return;
	self.tet_time = time + 0.1;


	if (self.piece_type == 0)
	{
		self.piece_pos = '5 1 0'; // that's about middle top, we count from 1 ARGH
		if (self.next_piece)
			self.piece_type = self.next_piece;
		else
			self.piece_type = RandomPiece();
		self.next_piece =  RandomPiece();
		keyss = 0; // no movement first frame
		self.tet_autodown = time + 0.2;
		brand_new = 1;
	}
	else
		ClearPiece(self.piece_type, self.piece_pos_x, self.piece_pos_y, self.piece_pos_z);

	// next we need to check the piece metrics against what's on the level
	// based on the key order

	check_pos = self.piece_pos;

	if (keyss & TETKEY_RIGHT)
		check_pos_x = check_pos_x + 1;
	else if (keyss & TETKEY_LEFT)
		check_pos_x = check_pos_x - 1;
	else if (keyss & TETKEY_ROTRIGHT)
		check_pos_z = check_pos_z + 1;
	else if (keyss & TETKEY_ROTLEFT)
		check_pos_z = check_pos_z - 1;
	// bounds check
	if (check_pos_z > 3)
		check_pos_z = 0;
	else if (check_pos_z < 0)
		check_pos_z = 3;

	// reality check
	if (CheckMetrics(self.piece_type, check_pos_x, check_pos_y, check_pos_z))
		self.piece_pos = check_pos;
	else if (brand_new)
		Tet_GameOver();
	check_pos = self.piece_pos;
	if (keyss & TETKEY_DOWN)
		check_pos_y = check_pos_y + 1;
	else if (self.tet_autodown < time)
	{
		check_pos_y = check_pos_y + 1;
		self.tet_autodown = time + 1 / (floor(self.tet_lines / 20) + 1);
	}
	if (CheckMetrics(self.piece_type, check_pos_x, check_pos_y, check_pos_z))
		self.piece_pos = check_pos;
	else
	{
		CementPiece(self.piece_type, self.piece_pos_x, self.piece_pos_y, self.piece_pos_z);
		TetAddScore(1);
		CompletedLines();
		self.piece_type = 0;
		return;
	}
	CementPiece(self.piece_type, self.piece_pos_x, self.piece_pos_y, self.piece_pos_z);
};

/*
*********************************

Important Linking Into Quake stuff

*********************************
*/


void() TetrisImpulses =
{
	if (self.impulse == 200)
	{
		self.tetris_on = 1;
		ResetTetris();
		self.tet_org = self.origin;
		self.movetype = MOVETYPE_NOCLIP;
		stuffcmd(self, "cl_bob 0\ncl_rollangle 0\n");
	}
};


float() TetrisPreFrame =
{
	if (!self.tetris_on)
		return 0;

	self.tet_org = self.origin;
	if (self.tet_time > time)
		return 1;
	Draw_Tetris();
	return 1;

};
float(float v) frik_anglemoda =
{
	return v - floor(v/360) * 360;
};
float (float y1, float y2) angcompa =
{
	y1 = frik_anglemoda(y1);
	y2 = frik_anglemoda(y2);

	local float answer;
	answer = y1 - y2;
	if (answer > 180)
		answer = answer - 360;
	else if (answer < -180)
		answer = answer + 360;
	return answer;
};


float() TetrisPostFrame =
{
	vector mov;
	float keysa, norm;

	keysa = 0;

	if (!self.tetris_on)
		return 0;
	if (self.origin != self.tet_org)
	{
		mov = vectoangles(self.origin - self.tet_org);
		self.origin = self.tet_org;

		norm = angcompa(self.v_angle_y, mov_y);

		if (norm > -80 && norm < 80)
			keysa = keysa | TETKEY_UP;
		if (norm > 10 && norm < 170)
			keysa = keysa | TETKEY_RIGHT;
		if (norm > 100  || norm < -260)
			keysa = keysa | TETKEY_DOWN;
		if (norm > -170 && norm < -10)
			keysa = keysa | TETKEY_LEFT;
	}
	if (self.button0)
		keysa = keysa | TETKEY_ROTRIGHT;
	if (self.button2)
		keysa = keysa | TETKEY_ROTLEFT;
	HandleGame(keysa);
	return 1;
};

