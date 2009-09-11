/*

Installation:

compile with -DTETRIS

*/

#ifdef TETRIS

.vector tet_org;

float tet_vs_current_id;
float tet_vs_current_timeout;
.float tet_vs_id, tet_vs_addlines;
.float tet_highest_line;
.float tetris_on, tet_gameovertime, tet_drawtime, tet_autodown;
.vector piece_pos;
.float piece_type, next_piece, tet_score, tet_lines;
.float tet_piece_bucket;

// tetris_on states:
//   1 = running
//   2 = game over
//   3 = waiting for VS players

var float tet_high_score = 0;

float TET_LINES = 20;
float TET_WIDTH = 10;
//character values
float TET_BORDER = 139;
float TET_BLOCK = 133;
float TET_SPACE = 160; // blankness



float TETKEY_UP = 1;
float TETKEY_DOWN = 2;
float TETKEY_LEFT = 4;
float TETKEY_RIGHT = 8;
float TETKEY_ROTLEFT = 16;
float TETKEY_ROTRIGHT = 32;
float TETKEY_DROP = 64;
string TET_PADDING_RIGHT = "\xA0\xA0\xA0\xA0\xA0\xA0\xA0\xA0\xA0\xA0\xA0\xA0\xA0\xA0"; // get away from crosshair

float PIECES = 7;

.float line1, line2, line3, line4, line5, line6, line7,
line8, line9, line10, line11, line12, line13, line14, line15,
line16, line17, line18, line19, line20;


float	SVC_CENTERPRINTa		= 26;

float Tetris_Level()
{
	return ((floor((self.tet_lines / 10)) + 1));
};

void tetsnd(string snd)
{
	play2(self, strcat("sounds/tetris/", snd));
}

/*
*********************************

Library Functions

*********************************
*/
void SetLine(float ln, float vl)
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

float GetLine(float ln)
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

float GetXBlock(float x, float dat)
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

float SetXBlock(float x, float dat, float new)
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


float GetSquare(float x, float y)
{
	return GetXBlock(x,  GetLine(y));
};

void SetSquare(float x, float y, float val)
{
	float dat;

	dat = GetLine(y);
	dat  = SetXBlock(x, dat, val & 3);
	SetLine(y, dat);
};

vector PieceShape(float pc)
{
	if (pc == 1)
		return '5 5 0'; // O
	else if (pc == 2)
		return '1 21 0'; // J
	else if (pc == 3)
		return '21 1 0'; // L
	else if (pc == 4)
		return '85 0 0'; // I
	else if (pc == 5)
		return '5 20 0'; // Z
	else if (pc == 6)
		return '20 5 0'; // S
	else if (pc == 7)
		return '4 21 0'; // T
	else
		return '0 0 0';
}

vector PieceCenter(float pc)
{
	if(pc == 1)
		return '1.5 1.5 0'; // O
	else if (pc == 2)
		return '2 2 0'; // J
	else if (pc == 3)
		return '2 1 0'; // L
	else if (pc == 4)
		return '2.5 1.5 0'; // I
	else if (pc == 5)
		return '2 2 0'; // Z
	else if (pc == 6)
		return '2 2 0'; // S
	else if (pc == 7)
		return '2 2 0'; // T
	else
		return '0 0 0';
}

// do x 1..4 and y 1..4 in case of rotation
float PieceMetric(float x, float y, float rot, float pc)
{
	float t;
	vector piece_dat;
	float wid;

	// return bits of a piece
	wid = piece_dat_z + 1;
	piece_dat = PieceCenter(pc);
	if (rot == 1) // 90 degrees
	{
		// x+cx, y+cy -> -y+cx, x+cy
		// X, Y       -> -Y+cy+cx, X-cx+cy
		//   x = X-cx
		//   y = Y-cy
		t = y;
		y = x - piece_dat_x + piece_dat_y;
		x = -t + piece_dat_x + piece_dat_y;
	}
	else if (rot == 2)//180
	{
		x = 2 * piece_dat_x - x;
		y = 2 * piece_dat_y - y;
	}
	else if (rot == 3) // 270
	{
		// x+cx, y+cy -> y+cx, -x+cy
		// X, Y       -> Y-cy+cx, -X+cx+cy
		//   x = X-cx
		//   y = Y-cy
		t = y;
		y = -x + piece_dat_y + piece_dat_x;
		x =  t - piece_dat_y + piece_dat_x;
	}
	if (x < 1 || y < 1 || x > 4 || y > 2)
		return 0;
	piece_dat = PieceShape(pc);
	if (y == 1)
		return GetXBlock(x, piece_dat_x); // first row
	else if (y == 2)
		return GetXBlock(x, piece_dat_y); // second row
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

void WriteTetrisString(string s)
{
	WriteUnterminatedString(MSG_ONE, strconv(0, 2, 2, s));
}

float pnum(float num, float dig)
{
	local float f, i;
	if (num < 0)
	{
		WriteChar(MSG_ONE, 173);
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
	WriteChar(MSG_ONE, 176 + num);
	return dig;
};

void DrawLine(float ln)
{
	float x, d;
	WriteChar(MSG_ONE, TET_BORDER);

	for (x = 1; x <= TET_WIDTH; x = x + 1)
	{
		d = GetSquare(x, ln);
		if (d)
		{
			WriteChar(MSG_ONE, '^');
			WriteChar(MSG_ONE, d * d - 2 * d + 50); // 1, 2, 5
			WriteChar(MSG_ONE, TET_BLOCK);
		}
		else
			WriteChar(MSG_ONE, TET_SPACE);
	}
	WriteChar(MSG_ONE, '^');
	WriteChar(MSG_ONE, '7');
	WriteChar(MSG_ONE, TET_BORDER);
}

void DrawPiece(float pc, float ln)
{
	float x, d, piece_ln, pcolor;
	vector piece_dat;
	pcolor = mod(pc, 3) + 1;
	WriteChar(MSG_ONE, TET_SPACE); // pad to 6

	piece_dat = PieceShape(pc);
	if (ln == 1)
		piece_ln = piece_dat_x;
	else
		piece_ln = piece_dat_y;
	for (x = 1; x <= 4; x = x + 1)
	{
		d = GetXBlock(x, piece_ln) * pcolor;
		if (d)
		{
			WriteChar(MSG_ONE, '^');
			WriteChar(MSG_ONE, d * d - 2 * d + 50); // 1, 2, 5
			WriteChar(MSG_ONE, TET_BLOCK);
		}
		else
			WriteChar(MSG_ONE, TET_SPACE);
	}
	WriteChar(MSG_ONE, TET_SPACE);	// pad to 6
}
void Draw_Tetris()
{
	float i;
	entity head;
	msg_entity = self;
	WriteChar(MSG_ONE, SVC_CENTERPRINTa);
	// decoration
	for (i = 1; i <= (TET_WIDTH + 2); i = i + 1)
		WriteChar(MSG_ONE, TET_BORDER);
	WriteTetrisString("      ");
	WriteUnterminatedString(MSG_ONE, TET_PADDING_RIGHT);
	WriteChar(MSG_ONE, 10);
	for (i = 1; i <= TET_LINES; i = i + 1)
	{
		if(self.tetris_on == 2)
			WriteTetrisString(" GAME  OVER ");
		else if(self.tetris_on == 3)
			WriteTetrisString("PLEASE  WAIT");
		else
			DrawLine(i);
		if (i == 1)
			WriteTetrisString(" NEXT ");
		else if (i == 3)
			DrawPiece(self.next_piece, 1);
		else if (i == 4)
			DrawPiece(self.next_piece, 2);
		else if (i == 6)
			WriteTetrisString(" LINES");
		else if (i == 7)
			pnum(self.tet_lines, 0);
		else if (i == 9)
			WriteTetrisString(" SCORE");
		else if (i == 10)
			pnum(self.tet_score, 0);
		else if (i == 12)
			WriteTetrisString(" HIGH ");
		else if (i == 13)
			WriteTetrisString(" SCORE");
		else if (i == 14)
			pnum(tet_high_score, 0);
		else if (i == 16)
			WriteTetrisString(" LEVEL");
		else if (i == 17)
			pnum(Tetris_Level(), 0);
		else
			WriteTetrisString("      ");
		WriteUnterminatedString(MSG_ONE, TET_PADDING_RIGHT);
		WriteChar(MSG_ONE, 10);
	}
	// decoration

	for (i = 1; i <= (TET_WIDTH + 2); i = i + 1)
		WriteChar(MSG_ONE, TET_BORDER);
	WriteTetrisString("      ");
	WriteUnterminatedString(MSG_ONE, TET_PADDING_RIGHT);
	WriteChar(MSG_ONE, 10);

	// VS game status
	if(self.tet_vs_id)
	{
		WriteChar(MSG_ONE, 10);
		WriteChar(MSG_ONE, 10);
		if(self.tetris_on == 3)
		{
			WriteUnterminatedString(MSG_ONE, strcat("WAITING FOR OTHERS (", ftos(ceil(tet_vs_current_timeout - time)), " SEC)\n"));
		}

		WriteChar(MSG_ONE, 10);
		FOR_EACH_REALCLIENT(head) if(head.tetris_on) if(head.tet_vs_id == self.tet_vs_id)
		{
			if(head == self)
				WriteUnterminatedString(MSG_ONE, ">");
			else
				WriteUnterminatedString(MSG_ONE, " ");
			if(head.tetris_on == 2)
				WriteUnterminatedString(MSG_ONE, "   X_X");
			else
				pnum(head.tet_highest_line, 0);
			WriteUnterminatedString(MSG_ONE, " ");
			WriteUnterminatedString(MSG_ONE, head.netname);
			WriteChar(MSG_ONE, 10);
		}
	}

	WriteChar(MSG_ONE, 0);
}
/*
*********************************

Game Functions

*********************************
*/

// reset the game
void ResetTetris()
{
	float i;

	for (i=1; i<=TET_LINES; i = i + 1)
		SetLine(i, 0);
	self.piece_pos = '0 0 0';
	self.piece_type = 0;
	self.next_piece = self.tet_lines = self.tet_score = 0;
	self.tet_piece_bucket = 0;
};

void Tet_GameExit()
{
	centerprint(self, " ");
	self.tetris_on = 0;
	self.tet_vs_id = 0;
	ResetTetris();
	self.movetype = MOVETYPE_WALK;
};



/*
*********************************

Game Mechanics

*********************************
*/
.float tet_piece_bucket;
float RandomPiece()
{
	float i, j;
	float p, q;
	float b;
	float seen;
	if(self.tet_piece_bucket > 1)
	{
		p = mod(self.tet_piece_bucket, 7);
		self.tet_piece_bucket = floor(self.tet_piece_bucket / 7);
		return p + 1;
	}
	else
	{
		p = floor(random() * 7);
		seen = pow(2, p);
		b = 1;
		for(i = 6; i > 0; --i)
		{
			q = floor(random() * i);
			for(j = 0; j <= q; ++j)
				if(seen & pow(2, j))
					++q;
			if(seen & pow(2, q))
				error("foo 1");
			if(q >= 7)
				error("foo 2");
			seen |= pow(2, q);
			b *= 7;
			b += q;
		}
		self.tet_piece_bucket = b;
		return p + 1;
	}
};

void TetAddScore(float n)
{
	self.tet_score = self.tet_score + n * Tetris_Level();
	if (self.tet_score > tet_high_score)
		tet_high_score = self.tet_score;
};
float CheckMetrics(float piece, float orgx, float orgy, float rot) /*FIXDECL*/
{
	// check to see if the piece, if moved to the locations will overlap

	float x, y;
	// why did I start counting from 1, damnit
	orgx = orgx - 1;
	orgy = orgy - 1;

	for (y = 0; y < 5; y = y + 1)
	{
		for (x = 0; x < 5; x = x + 1)
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

void ClearPiece(float piece, float orgx, float orgy, float rot) /*FIXDECL*/
{

	float x, y;
	// why did I start counting from 1, damnit
	orgx = orgx - 1;
	orgy = orgy - 1;

	for (y = 0; y < 5; y = y + 1)
	{
		for (x = 0; x < 5; x = x + 1)
		{
			if (PieceMetric(x, y, rot, piece))
			{
				SetSquare(x + orgx, y + orgy, 0);
			}
		}
	}
}
void CementPiece(float piece, float orgx, float orgy, float rot) /*FIXDECL*/
{
	float pcolor;
	float x, y;
	// why did I start counting from 1, damnit
	orgx = orgx - 1;
	orgy = orgy - 1;

	pcolor = mod(piece, 3) + 1;

	for (y = 0; y < 5; y = y + 1)
	{
		for (x = 0; x < 5; x = x + 1)
		{
			if (PieceMetric(x, y, rot, piece))
			{
				SetSquare(x + orgx, y + orgy, pcolor);
			}
		}
	}
}

float LINE_LOW = 349525;
float LINE_HIGH = 699050; // above number times 2

void AddLines(float n)
{
	entity head;
	if(!self.tet_vs_id)
		return;
	FOR_EACH_REALCLIENT(head) if(head != self) if(head.tetris_on) if(head.tet_vs_id == self.tet_vs_id)
		head.tet_vs_addlines += n;
}

void CompletedLines()
{
	float y, cleared, ln, added, pos, i;

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

	if(cleared >= 4)
		AddLines(cleared);
	else if(cleared >= 1)
		AddLines(cleared - 1);

	self.tet_lines = self.tet_lines + cleared;
	TetAddScore(cleared * cleared * 10);

	added = self.tet_vs_addlines;
	self.tet_vs_addlines = 0;

	if(added)
	{
		for(y = 1; y <= TET_LINES - added; ++y)
		{
			SetLine(y, GetLine(y + added));
		}
		for(y = max(1, TET_LINES - added + 1); y <= TET_LINES; ++y)
		{
			pos = floor(random() * TET_WIDTH);
			ln = 0;
			for(i = 1; i <= TET_WIDTH; ++i)
				if(i != pos)
					ln = SetXBlock(i, ln, floor(random() * 3 + 1));
			SetLine(y, ln);
		}
	}

	self.tet_highest_line = 0;
	for(y = 1; y <= TET_LINES; ++y)
		if(GetLine(y) != 0)
		{
			self.tet_highest_line = TET_LINES + 1 - y;
			break;
		}

	if(added)
		tetsnd("tetadd");
	else if(cleared >= 4)
		tetsnd("tetris");
	else if(cleared)
		tetsnd("tetline");
	else
		tetsnd("tetland");
};

void HandleGame(float keyss)
{

	// first off, we need to see if we need a new piece
	vector piece_data;
	vector check_pos;
	vector old_pos;
	float brand_new;
	float i;
	brand_new = 0;


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

	old_pos = check_pos = self.piece_pos;

	float nudge;
	nudge = 0;
	if (keyss & TETKEY_RIGHT)
	{
		check_pos_x = check_pos_x + 1;
		tetsnd("tetmove");
	}
	else if (keyss & TETKEY_LEFT)
	{
		check_pos_x = check_pos_x - 1;
		tetsnd("tetmove");
	}
	else if (keyss & TETKEY_ROTRIGHT)
	{
		check_pos_z = check_pos_z + 1;
		piece_data = PieceShape(self.piece_type);
		nudge = 1;
		tetsnd("tetrot");
	}
	else if (keyss & TETKEY_ROTLEFT)
	{
		check_pos_z = check_pos_z - 1;
		piece_data = PieceShape(self.piece_type);
		nudge = 1;
		tetsnd("tetrot");
	}
	// bounds check
	if (check_pos_z > 3)
		check_pos_z = 0;
	else if (check_pos_z < 0)
		check_pos_z = 3;

	// reality check
	if (CheckMetrics(self.piece_type, check_pos_x, check_pos_y, check_pos_z))
		self.piece_pos = check_pos;
	else if (brand_new)
	{
		self.tetris_on = 2;
		self.tet_gameovertime = time + 5;
		return;
	}
	else
	{
		for(i = 1; i <= nudge; ++i)
		{
			if(CheckMetrics(self.piece_type, check_pos_x + i, check_pos_y, check_pos_z))
				self.piece_pos = check_pos + '1 0 0' * i;
			else if(CheckMetrics(self.piece_type, check_pos_x - i, check_pos_y, check_pos_z))
				self.piece_pos = check_pos - '1 0 0' * i;
			else
				continue;
			break;
		}
	}
	check_pos = self.piece_pos;
	if(keyss & TETKEY_DROP)
	{
		// drop to bottom, but do NOT cement it yet
		// this allows sliding it
		++check_pos_y;
		while(CheckMetrics(self.piece_type, check_pos_x, check_pos_y + 1, check_pos_z))
			++check_pos_y;
		self.tet_autodown = time + 2 / (1 + Tetris_Level());
	}
	else if (keyss & TETKEY_DOWN)
	{
		check_pos_y = check_pos_y + 1;
		self.tet_autodown = time + 2 / (1 + Tetris_Level());
	}
	else if (self.tet_autodown < time)
	{
		check_pos_y = check_pos_y + 1;
		self.tet_autodown = time + 2 / (1 + Tetris_Level());
	}
	if (CheckMetrics(self.piece_type, check_pos_x, check_pos_y, check_pos_z))
	{
		if(old_pos != check_pos)
			self.tet_drawtime = 0;
		self.piece_pos = check_pos;
	}
	else
	{
		CementPiece(self.piece_type, self.piece_pos_x, self.piece_pos_y, self.piece_pos_z);
		TetAddScore(1);
		CompletedLines();
		self.piece_type = 0;
		self.tet_drawtime = 0;
		return;
	}
	CementPiece(self.piece_type, self.piece_pos_x, self.piece_pos_y, self.piece_pos_z);
};

/*
*********************************

Important Linking Into Quake stuff

*********************************
*/


void TetrisImpulse()
{
	if(self.tetris_on == 0 || self.tetris_on == 2) // from "off" or "game over"
	{
		self.tetris_on = 3;

		if(time < tet_vs_current_timeout)
		{
			// join VS game
			self.tet_vs_id = tet_vs_current_id;
		}
		else
		{
			// start new VS game
			++tet_vs_current_id;
			tet_vs_current_timeout = time + 15;
			self.tet_vs_id = tet_vs_current_id;
			bprint("^1TET^7R^1IS: ", self.netname, "^1 started a new game. Do ^7impulse 100^1 to join.\n");
		}
		self.tet_highest_line = 0;
		ResetTetris();
		self.tet_org = self.origin;
		self.movetype = MOVETYPE_NOCLIP;
	}
	else if(self.tetris_on == 1) // from "on"
	{
		Tet_GameExit();
		self.impulse = 0;
	}
};


float TetrisPreFrame()
{
	if (!self.tetris_on)
		return 0;

	self.tet_org = self.origin;
	if (self.tet_drawtime > time)
		return 1;
	Draw_Tetris();
	if(self.tetris_on == 3)
		self.tet_drawtime = ceil(time - tet_vs_current_timeout + 0.1) + tet_vs_current_timeout;
	else
		self.tet_drawtime = time + 0.5;
	return 1;
};
float frik_anglemoda(float v)
{
	return v - floor(v/360) * 360;
};
float angcompa(float y1, float y2)
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

.float tetkey_down, tetkey_rotright, tetkey_left, tetkey_right, tetkey_rotleft, tetkey_drop;

float TetrisKeyRepeat(.float fld, float f)
{
	if(f)
	{
		if(self.fld == 0) // initial key press
		{
			self.fld = time + 0.3;
			return 1;
		}
		else if(time > self.fld)
		{
			self.fld = time + 0.1;
			return 1;
		}
		else
		{
			// repeating too fast
			return 0;
		}
	}
	else
	{
		self.fld = 0;
		return 0;
	}
}

float TetrisPostFrame()
{
	float keysa;

	keysa = 0;

	if (!self.tetris_on)
		return 0;

	if(self.tetris_on == 2 && time > self.tet_gameovertime)
	{
		Tet_GameExit();
		return 0;
	}

	if(self.tetris_on == 3 && time > tet_vs_current_timeout)
	{
		self.tetris_on = 1; // start VS game
		self.tet_drawtime = 0;
	}

	setorigin(self, self.tet_org);
	self.movetype = MOVETYPE_NONE;

	if(self.tetris_on == 1)
	{
		if(TetrisKeyRepeat(tetkey_down, self.movement_x < 0))
			keysa |= TETKEY_DOWN;

		if(TetrisKeyRepeat(tetkey_rotright, self.movement_x > 0))
			keysa |= TETKEY_ROTRIGHT;

		if(TetrisKeyRepeat(tetkey_left, self.movement_y < 0))
			keysa |= TETKEY_LEFT;

		if(TetrisKeyRepeat(tetkey_right, self.movement_y > 0))
			keysa |= TETKEY_RIGHT;

		if(TetrisKeyRepeat(tetkey_rotleft, self.BUTTON_CROUCH))
			keysa |= TETKEY_ROTLEFT;

		if(TetrisKeyRepeat(tetkey_drop, self.BUTTON_JUMP))
			keysa |= TETKEY_DROP;

		HandleGame(keysa);
	}

	return 1;
};

#endif
