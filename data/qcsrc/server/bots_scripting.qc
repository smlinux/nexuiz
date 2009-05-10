// NOTE: New commands should be added here. Do not forget to update BOT_CMD_COUNTER
#define BOT_CMD_NULL			0
#define BOT_CMD_PAUSE			1
#define BOT_CMD_CONTINUE		2
#define BOT_CMD_WAIT			3
#define BOT_CMD_TURN			4
#define BOT_CMD_MOVETO			5	// Not implemented yet
#define BOT_CMD_RESETGOAL		6	// Not implemented yet
#define BOT_CMD_CC			7
#define BOT_CMD_IF      		8
#define BOT_CMD_ELSE    		9
#define BOT_CMD_FI      		10
#define BOT_CMD_RESETAIM   		11
#define BOT_CMD_AIM			12
#define BOT_CMD_PRESSKEY		13
#define BOT_CMD_RELEASEKEY		14
#define BOT_CMD_SELECTWEAPON		15
#define BOT_CMD_IMPULSE			16
#define BOT_CMD_WHILE			17	// Not implemented yet
#define BOT_CMD_WEND			18	// Not implemented yet
#define BOT_CMD_CHASE			19	// Not implemented yet
#define BOT_CMD_COUNTER			17

// NOTE: Following commands should be implemented on the bot ai
//		 If a new command should be handled by the target ai(s) please declare it here
.float(vector) cmd_moveto;
.float() cmd_resetgoal;

//
#define BOT_CMD_PARAMETER_NONE		0
#define BOT_CMD_PARAMETER_FLOAT		1
#define BOT_CMD_PARAMETER_STRING	2
#define BOT_CMD_PARAMETER_VECTOR	3

float bot_cmds_initialized;
float bot_cmd_parm_type[BOT_CMD_COUNTER];
string bot_cmd_string[BOT_CMD_COUNTER];

// Bots command queue
entity bot_cmd;				// Current command

.float is_bot_cmd;			// Tells if the entity is a bot command
.float bot_cmd_index;			// Position of the command in the queue
.float bot_cmd_type;			// If of command (see the BOT_CMD_* defines)
.float bot_cmd_parm_float;		// Field to store a float parameter
.string bot_cmd_parm_string;		// Field to store a string parameter
.vector bot_cmd_parm_vector;		// Field to store a vector parameter
.float bot_cmd_execution_counter;	// How many times this command on the queue was executed

.float bot_cmd_execution_index;		// Position in the queue of the command to be executed
.float bot_cmd_queue_index;		// Position of the last command in the queue

// Initialize global commands list
// NOTE: New commands should be initialized here
void bot_commands_init()
{
	bot_cmd_string[BOT_CMD_NULL]			= "";
	bot_cmd_parm_type[BOT_CMD_NULL]			= BOT_CMD_PARAMETER_NONE;

	bot_cmd_string[BOT_CMD_PAUSE]			= "pause";
	bot_cmd_parm_type[BOT_CMD_PAUSE]		= BOT_CMD_PARAMETER_NONE;

	bot_cmd_string[BOT_CMD_CONTINUE]		= "continue";
	bot_cmd_parm_type[BOT_CMD_CONTINUE]		= BOT_CMD_PARAMETER_NONE;

	bot_cmd_string[BOT_CMD_WAIT]			= "wait";
	bot_cmd_parm_type[BOT_CMD_WAIT]			= BOT_CMD_PARAMETER_FLOAT;

	bot_cmd_string[BOT_CMD_TURN]			= "turn";
	bot_cmd_parm_type[BOT_CMD_TURN]			= BOT_CMD_PARAMETER_FLOAT;

	bot_cmd_string[BOT_CMD_MOVETO]			= "moveto";
	bot_cmd_parm_type[BOT_CMD_MOVETO]		= BOT_CMD_PARAMETER_VECTOR;

	bot_cmd_string[BOT_CMD_RESETGOAL]		= "resetgoal";
	bot_cmd_parm_type[BOT_CMD_RESETGOAL]		= BOT_CMD_PARAMETER_NONE;

	bot_cmd_string[BOT_CMD_CC]			= "cc";
	bot_cmd_parm_type[BOT_CMD_CC]			= BOT_CMD_PARAMETER_STRING;

	bot_cmd_string[BOT_CMD_IF]			= "if";
	bot_cmd_parm_type[BOT_CMD_IF]			= BOT_CMD_PARAMETER_STRING;

	bot_cmd_string[BOT_CMD_ELSE]			= "else";
	bot_cmd_parm_type[BOT_CMD_ELSE]			= BOT_CMD_PARAMETER_NONE;

	bot_cmd_string[BOT_CMD_FI]			= "fi";
	bot_cmd_parm_type[BOT_CMD_FI]			= BOT_CMD_PARAMETER_NONE;

	bot_cmd_string[BOT_CMD_RESETAIM]		= "resetaim";
	bot_cmd_parm_type[BOT_CMD_RESETAIM]		= BOT_CMD_PARAMETER_NONE;

	bot_cmd_string[BOT_CMD_AIM]			= "aim";
	bot_cmd_parm_type[BOT_CMD_AIM]			= BOT_CMD_PARAMETER_STRING;

	bot_cmd_string[BOT_CMD_PRESSKEY]		= "presskey";
	bot_cmd_parm_type[BOT_CMD_PRESSKEY]		= BOT_CMD_PARAMETER_STRING;

	bot_cmd_string[BOT_CMD_RELEASEKEY]		= "releasekey";
	bot_cmd_parm_type[BOT_CMD_RELEASEKEY]		= BOT_CMD_PARAMETER_STRING;

	bot_cmd_string[BOT_CMD_SELECTWEAPON]		= "selectweapon";
	bot_cmd_parm_type[BOT_CMD_SELECTWEAPON]		= BOT_CMD_PARAMETER_FLOAT;

	bot_cmd_string[BOT_CMD_IMPULSE]			= "impulse";
	bot_cmd_parm_type[BOT_CMD_IMPULSE]		= BOT_CMD_PARAMETER_FLOAT;

	bot_cmds_initialized = TRUE;
}

// Returns first bot with matching name
entity find_bot_by_name(string name)
{
	local entity bot;

	bot = findchainflags(flags, FL_CLIENT);
	while (bot)
	{
		if(clienttype(bot) == CLIENTTYPE_BOT)
		if(bot.netname==name)
			return bot;

		bot = bot.chain;
	}

	return world;
}

// Returns a bot by number on list
entity find_bot_by_number(float number)
{
	local entity bot;
	local float c;

	bot = findchainflags(flags, FL_CLIENT);
	while (bot)
	{
		if(clienttype(bot) == CLIENTTYPE_BOT)
		{
			if(++c==number)
				return bot;
		}
		bot = bot.chain;
	}

	return world;
}

void bot_clearqueue()
{
	entity head, newhead;

	head = findchainfloat(is_bot_cmd, TRUE);
	newhead = head;

	while(newhead)
	{
		newhead = head.chain;

		if(head.owner==self)
			remove(head);

		head = newhead;
	}

	self.bot_cmd_queue_index = 0;
	self.bot_cmd_execution_index = 0;
}

entity bot_spawncmd(entity bot, float type)
{
	entity cmd;

	bot.bot_cmd_queue_index++;

	cmd = spawn();
	cmd.owner = bot;
	cmd.is_bot_cmd = TRUE;
	cmd.bot_cmd_type = type;
	cmd.bot_cmd_index = bot.bot_cmd_queue_index;

	return cmd;
}

void bot_debugcmd(entity cmd)
{
	print(strcat("Owner: ",cmd.owner.netname, "\n"));
	print(strcat("Cmd Type: ",ftos(cmd.bot_cmd_type), "\n"));
	print(strcat("Cmd Index: ",ftos(cmd.bot_cmd_index), "\n"));

	print(strcat("Param Float: ",ftos(cmd.bot_cmd_parm_float), "\n"));
	print(strcat("Param String: ",cmd.bot_cmd_parm_string, "\n"));
	print(strcat("Param Vector: ",vtos(cmd.bot_cmd_parm_vector), "\n"));

	print(strcat("Bot queue index: ",	ftos(cmd.owner.bot_cmd_queue_index), "\n"));
	print(strcat("Bot execution index: ",	ftos(cmd.owner.bot_cmd_execution_index), "\n\n"));
}

void bot_queuecommand(entity bot, string cmdstring, string parm)
{
	entity cmd;
	local float queue_index, cmd_parm_type, i;

	if not(bot.isbot)
		return;

	if(!bot_cmds_initialized)
		bot_commands_init();

	for(i=1;i<BOT_CMD_COUNTER;++i)
	{
		if(bot_cmd_string[i]!=cmdstring)
			continue;

		cmd_parm_type = bot_cmd_parm_type[i];

		if(cmd_parm_type!=BOT_CMD_PARAMETER_NONE&&parm=="")
		{
			print("ERROR: A parameter is required for this command\n");
			return;
		}

		// Load command into queue
		cmd = bot_spawncmd(bot, i);

		// Attach parameter
		switch(cmd_parm_type)
		{
			case BOT_CMD_PARAMETER_FLOAT:
				cmd.bot_cmd_parm_float = stof(parm);
				break;
			case BOT_CMD_PARAMETER_STRING:
				cmd.bot_cmd_parm_string = strzone(parm);
				break;
			case BOT_CMD_PARAMETER_VECTOR:
				cmd.bot_cmd_parm_vector = stov(parm);
				break;
			default:
				break;
		}
		return;
	}
	print("ERROR: No such command");
}

void bot_cmdhelp(string scmd)
{
	local float i, index, ntype;
	local string stype;

	if(!bot_cmds_initialized)
		bot_commands_init();

	for(i=1;i<BOT_CMD_COUNTER;++i)
	{
		if(bot_cmd_string[i]!=scmd)
			continue;

		ntype = bot_cmd_parm_type[i];

		switch(ntype)
		{
			case BOT_CMD_PARAMETER_FLOAT:
				stype = "float number";
				break;
			case BOT_CMD_PARAMETER_STRING:
				stype = "string";
				break;
			case BOT_CMD_PARAMETER_VECTOR:
				stype = "vector";
				break;
			default:
				stype = "none";
				break;
		}

		print(strcat("Command: ",bot_cmd_string[i],"\nParameter: <",stype,"> \n"));

		print("Description: ");
		switch(i)
		{
			case BOT_CMD_PAUSE:
				print("Stops the bot completely. Any command other than 'continue' will be ignored.");
				break;
			case BOT_CMD_CONTINUE:
				print("Disable paused status");
				break;
			case BOT_CMD_WAIT:
				print("Pause command parsing and bot ai for N seconds. Pressed key will remain pressed");
				break;
			case BOT_CMD_TURN:
				print("Look to the right or left N degrees. For turning to the left use positive numbers.");
				break;
			case BOT_CMD_MOVETO:
				print("Walk to an specific coordinate on the map. Usage: moveto \"x y z\"");
				break;
			case BOT_CMD_RESETGOAL:
				print("Resets the goal stack");
				break;
			case BOT_CMD_CC:
				print("Execute client command. Examples: cc \"say something\"; cc god; cc \"name newnickname\"; cc kill;");
				break;
			case BOT_CMD_IF:
				print("Perform simple conditional execution.\n");
				print("Syntax: \n");
				print("        sv_cmd .. if \"condition\"\n");
				print("        sv_cmd .. 	<instruction if true>\n");
				print("        sv_cmd .. 	<instruction if true>\n");
				print("        sv_cmd .. else\n");
				print("        sv_cmd .. 	<instruction if false>\n");
				print("        sv_cmd .. 	<instruction if false>\n");
				print("        sv_cmd .. fi\n");
				print("Conditions: a=b, a>b, a<b, a\t\t(spaces not allowed)\n");
				print("            Values in conditions can be numbers, cvars in the form cvar.cvar_string or special fields\n");
				print("Fields: health, speed, flagcarrier\n");
				print("Examples: if health>50; if health>cvar.g_balance_laser_primary_damage; if flagcarrier;");
				break;
			case BOT_CMD_RESETAIM:
				print("Points the aim to the coordinates x,y 0,0");
				break;
			case BOT_CMD_AIM:
				print("Move the aim x/y (horizontal/vertical) degrees relatives to the bot\n");
				print("There is a 3rd optional parameter telling in how many seconds the aim has to reach the new position\n");
				print("Examples: aim \"90 0\"	// Turn 90 degrees inmediately (positive numbers move to the left/up)\n");
				print("          aim \"0 90 2\"	// Will gradually look to the sky in the next two seconds");
				break;
			case BOT_CMD_PRESSKEY:
				print("Press one of the following keys: forward, backward, left, right, jump, crouch, attack1, attack2, use\n");
				print("Multiple keys can be pressed at time (with many presskey calls) and it will remain pressed until the command \"releasekey\" is called");
				print("Note: The script will not return the control to the bot ai until all keys are released");
				break;
			case BOT_CMD_RELEASEKEY:
				print("Release previoulsy used keys. Use the parameter \"all\" to release all keys");
				break;
			default:
				print("This command has no description yet.");
				break;
		}
		print("\n");
	}
}

void bot_list_commands()
{
	local float i;
	local string ptype;

	if(!bot_cmds_initialized)
		bot_commands_init();

	print("List of all available commands:\n");
	print(" Command\t\t\t\tParameter Type\n");

	for(i=1;i<BOT_CMD_COUNTER;++i)
	{
		switch(bot_cmd_parm_type[i])
		{
			case BOT_CMD_PARAMETER_FLOAT:
				ptype = "float number";
				break;
			case BOT_CMD_PARAMETER_STRING:
				ptype = "string";
				break;
			case BOT_CMD_PARAMETER_VECTOR:
				ptype = "vector";
				break;
			default:
				ptype = "none";
				break;
		}
		print(strcat(" ",bot_cmd_string[i],"\t\t\t\t<",ptype,"> \n"));
	}
}

// Commands code
.float bot_exec_status;

#define BOT_EXEC_STATUS_IDLE	0
#define BOT_EXEC_STATUS_PAUSED	1
#define BOT_EXEC_STATUS_WAITING	2

#define CMD_STATUS_EXECUTING	0
#define CMD_STATUS_FINISHED	1
#define CMD_STATUS_ERROR	2

float bot_cmd_cc()
{
	clientcommand(self,bot_cmd.bot_cmd_parm_string);
	return CMD_STATUS_FINISHED;
}

float bot_cmd_impulse()
{
	self.impulse = bot_cmd.bot_cmd_parm_float;
	return CMD_STATUS_FINISHED;
}

float bot_cmd_continue()
{
	self.bot_exec_status &~= BOT_EXEC_STATUS_PAUSED;
	return CMD_STATUS_FINISHED;
}

.float bot_cmd_wait_time;
float bot_cmd_wait()
{
	if(self.bot_exec_status & BOT_EXEC_STATUS_WAITING)
	{
		if(time>=self.bot_cmd_wait_time)
		{
			self.bot_exec_status &~= BOT_EXEC_STATUS_WAITING;
			return CMD_STATUS_FINISHED;
		}
		else
			return CMD_STATUS_EXECUTING;
	}

	self.bot_cmd_wait_time = time + bot_cmd.bot_cmd_parm_float;
	self.bot_exec_status |= BOT_EXEC_STATUS_WAITING;
	return CMD_STATUS_EXECUTING;
}

float bot_cmd_turn()
{
	self.v_angle_y = self.v_angle_y + bot_cmd.bot_cmd_parm_float;
	self.v_angle_y = self.v_angle_y - floor(self.v_angle_y / 360) * 360;
	return CMD_STATUS_FINISHED;
}

float bot_cmd_select_weapon()
{
	local float id;

	id = bot_cmd.bot_cmd_parm_float;

	if(id < WEP_FIRST || id > WEP_LAST)
		return CMD_STATUS_ERROR;

	if(client_hasweapon(self, id, TRUE, FALSE))
		self.switchweapon = id;

	return CMD_STATUS_FINISHED;
}

.float bot_cmd_condition_status;

#define CMD_CONDITION_NONE		0
#define CMD_CONDITION_TRUE		1
#define CMD_CONDITION_FALSE		2
#define CMD_CONDITION_TRUE_BLOCK	4
#define CMD_CONDITION_FALSE_BLOCK	8

float bot_cmd_eval(string expr)
{
	// Search for numbers
	if(strstrofs("0123456789", substring(expr, 0, 1), 0) >= 0)
	{
		return stof(expr);
	}

	// Search for cvars
	if(substring(expr, 0, 5)=="cvar.")
	{
		return cvar(substring(expr, 5, strlen(expr)));
	}

	// Search for fields
	switch(expr)
	{
		case "health":
			return self.health;
		case "speed":
			return vlen(self.velocity);
		case "flagcarrier":
			return ((self.flagcarried!=world));
	}

	print(strcat("ERROR: Unable to convert the expression '",expr,"' into a numeric value\n"));
	return 0;
}

float bot_cmd_if()
{
	local string expr, val_a, val_b;
	local float cmpofs;

	if(self.bot_cmd_condition_status != CMD_CONDITION_NONE)
	{
		// Only one "if" block is allowed at time
		print("ERROR: Only one conditional block can be processed at time");
		bot_clearqueue();
		return CMD_STATUS_ERROR;
	}

	self.bot_cmd_condition_status |= CMD_CONDITION_TRUE_BLOCK;

	// search for operators
	expr = bot_cmd.bot_cmd_parm_string;

	cmpofs = strstrofs(expr,"=",0);

	if(cmpofs>0)
	{
		val_a = substring(expr,0,cmpofs);
		val_b = substring(expr,cmpofs+1,strlen(expr));

		if(bot_cmd_eval(val_a)==bot_cmd_eval(val_b))
			self.bot_cmd_condition_status |= CMD_CONDITION_TRUE;
		else
			self.bot_cmd_condition_status |= CMD_CONDITION_FALSE;

  		return CMD_STATUS_FINISHED;
	}

	cmpofs = strstrofs(expr,">",0);

	if(cmpofs>0)
	{
		val_a = substring(expr,0,cmpofs);
		val_b = substring(expr,cmpofs+1,strlen(expr));

		if(bot_cmd_eval(val_a)>bot_cmd_eval(val_b))
			self.bot_cmd_condition_status |= CMD_CONDITION_TRUE;
		else
			self.bot_cmd_condition_status |= CMD_CONDITION_FALSE;

		return CMD_STATUS_FINISHED;
	}

	cmpofs = strstrofs(expr,"<",0);

	if(cmpofs>0)
	{
		val_a = substring(expr,0,cmpofs);
		val_b = substring(expr,cmpofs+1,strlen(expr));

		if(bot_cmd_eval(val_a)<bot_cmd_eval(val_b))
			self.bot_cmd_condition_status |= CMD_CONDITION_TRUE;
		else
			self.bot_cmd_condition_status |= CMD_CONDITION_FALSE;

  		return CMD_STATUS_FINISHED;
	}

	if(bot_cmd_eval(expr))
		self.bot_cmd_condition_status |= CMD_CONDITION_TRUE;
	else
		self.bot_cmd_condition_status |= CMD_CONDITION_FALSE;

  	return CMD_STATUS_FINISHED;
}

float bot_cmd_else()
{
	self.bot_cmd_condition_status &~= CMD_CONDITION_TRUE_BLOCK;
	self.bot_cmd_condition_status |= CMD_CONDITION_FALSE_BLOCK;
	return CMD_STATUS_FINISHED;
}

float bot_cmd_fi()
{
	self.bot_cmd_condition_status = CMD_CONDITION_NONE;
	return CMD_STATUS_FINISHED;
}

float bot_cmd_resetaim()
{
	self.v_angle = '0 0 0';
	return CMD_STATUS_FINISHED;
}

.float bot_cmd_aim_begintime;
.float bot_cmd_aim_endtime;
.vector bot_cmd_aim_begin;
.vector bot_cmd_aim_end;

float bot_cmd_aim()
{
	// Current direction
	if(self.bot_cmd_aim_endtime)
	{
		local float progress;

		progress = min(1 - (self.bot_cmd_aim_endtime - time) / (self.bot_cmd_aim_endtime - self.bot_cmd_aim_begintime),1);
		self.v_angle = self.bot_cmd_aim_begin + ((self.bot_cmd_aim_end - self.bot_cmd_aim_begin) * progress);

		if(time>=self.bot_cmd_aim_endtime)
		{
			self.bot_cmd_aim_endtime = 0;
			return CMD_STATUS_FINISHED;
		}
		else
			return CMD_STATUS_EXECUTING;
	}

	// New aiming direction
	local string parms;
	local float tokens, step;

	parms = bot_cmd.bot_cmd_parm_string;

	tokens = tokenizebyseparator(parms, " ");

	if(tokens==2)
	{
		self.v_angle_x -= stof(argv(1));
		self.v_angle_y += stof(argv(0));
		return CMD_STATUS_FINISHED;
	}

	if(tokens<1||tokens>3)
		return CMD_STATUS_ERROR;

	step = stof(argv(2));

	self.bot_cmd_aim_begin = self.v_angle;

	self.bot_cmd_aim_end_x = self.v_angle_x - stof(argv(1));
	self.bot_cmd_aim_end_y = self.v_angle_y + stof(argv(0));
	self.bot_cmd_aim_end_z = 0;

	self.bot_cmd_aim_begintime = time;
	self.bot_cmd_aim_endtime = time + step;

	return CMD_STATUS_EXECUTING;
}

.float bot_cmd_keys;

#define BOT_CMD_KEY_NONE	0
#define BOT_CMD_KEY_FORWARD 	1
#define BOT_CMD_KEY_BACKWARD	2
#define BOT_CMD_KEY_RIGHT	4
#define BOT_CMD_KEY_LEFT	8
#define BOT_CMD_KEY_JUMP	16
#define BOT_CMD_KEY_ATTACK1 	32
#define BOT_CMD_KEY_ATTACK2 	64
#define BOT_CMD_KEY_USE		128
#define BOT_CMD_KEY_HOOK	256
#define BOT_CMD_KEY_CROUCH	512

float bot_presskeys()
{
	self.movement = '0 0 0';

	if(self.bot_cmd_keys == BOT_CMD_KEY_NONE)
		return FALSE;

	if(self.bot_cmd_keys & BOT_CMD_KEY_FORWARD)
		self.movement_x = cvar("sv_maxspeed");
	else if(self.bot_cmd_keys & BOT_CMD_KEY_BACKWARD)
		self.movement_x = -cvar("sv_maxspeed");

	if(self.bot_cmd_keys & BOT_CMD_KEY_RIGHT)
		self.movement_y = cvar("sv_maxspeed");
	else if(self.bot_cmd_keys & BOT_CMD_KEY_LEFT)
		self.movement_y = -cvar("sv_maxspeed");

	if(self.bot_cmd_keys & BOT_CMD_KEY_JUMP)
		self.BUTTON_JUMP = TRUE;

	if(self.bot_cmd_keys & BOT_CMD_KEY_CROUCH)
		self.BUTTON_CROUCH = TRUE;

	if(self.bot_cmd_keys & BOT_CMD_KEY_ATTACK1)
		self.BUTTON_ATCK = TRUE;

	if(self.bot_cmd_keys & BOT_CMD_KEY_ATTACK2)
		self.BUTTON_ATCK2 = TRUE;

	if(self.bot_cmd_keys & BOT_CMD_KEY_USE)
		self.BUTTON_USE = TRUE;

	return TRUE;
}


float bot_cmd_keypress_handler(string key, float enabled)
{
	switch(key)
	{
		case "all":
			if(enabled)
				self.bot_cmd_keys = power2of(20) - 1; // >:)
			else
				self.bot_cmd_keys = BOT_CMD_KEY_NONE;
		case "forward":
			if(enabled)
			{
				self.bot_cmd_keys |= BOT_CMD_KEY_FORWARD;
				self.bot_cmd_keys &~= BOT_CMD_KEY_BACKWARD;
			}
			else
				self.bot_cmd_keys &~= BOT_CMD_KEY_FORWARD;
			break;
		case "backward":
			if(enabled)
			{
				self.bot_cmd_keys |= BOT_CMD_KEY_BACKWARD;
				self.bot_cmd_keys &~= BOT_CMD_KEY_FORWARD;
			}
			else
				self.bot_cmd_keys &~= BOT_CMD_KEY_BACKWARD;
			break;
		case "left":
			if(enabled)
			{
				self.bot_cmd_keys |= BOT_CMD_KEY_LEFT;
				self.bot_cmd_keys &~= BOT_CMD_KEY_RIGHT;
			}
			else
				self.bot_cmd_keys &~= BOT_CMD_KEY_LEFT;
			break;
		case "right":
			if(enabled)
			{
				self.bot_cmd_keys |= BOT_CMD_KEY_RIGHT;
				self.bot_cmd_keys &~= BOT_CMD_KEY_LEFT;
			}
			else
				self.bot_cmd_keys &~= BOT_CMD_KEY_RIGHT;
			break;
		case "jump":
			if(enabled)
				self.bot_cmd_keys |= BOT_CMD_KEY_JUMP;
			else
				self.bot_cmd_keys &~= BOT_CMD_KEY_JUMP;
			break;
		case "crouch":
			if(enabled)
				self.bot_cmd_keys |= BOT_CMD_KEY_CROUCH;
			else
				self.bot_cmd_keys &~= BOT_CMD_KEY_CROUCH;
			break;
		case "attack1":
			if(enabled)
				self.bot_cmd_keys |= BOT_CMD_KEY_ATTACK1;
			else
				self.bot_cmd_keys &~= BOT_CMD_KEY_ATTACK1;
			break;
		case "attack2":
			if(enabled)
				self.bot_cmd_keys |= BOT_CMD_KEY_ATTACK2;
			else
				self.bot_cmd_keys &~= BOT_CMD_KEY_ATTACK2;
			break;
		case "use":
			if(enabled)
				self.bot_cmd_keys |= BOT_CMD_KEY_USE;
			else
				self.bot_cmd_keys &~= BOT_CMD_KEY_USE;
			break;
		default:
			break;
	}

	return CMD_STATUS_FINISHED;
}

float bot_cmd_presskey()
{
	local string key;

	key = bot_cmd.bot_cmd_parm_string;

	bot_cmd_keypress_handler(key,TRUE);

	return CMD_STATUS_FINISHED;
}

float bot_cmd_releasekey()
{
	local string key;

	key = bot_cmd.bot_cmd_parm_string;

	return bot_cmd_keypress_handler(key,FALSE);
}

float bot_cmd_pause()
{
	self.button1        = 0;
	self.button8        = 0;
	self.BUTTON_USE     = 0;
	self.BUTTON_ATCK    = 0;
	self.BUTTON_JUMP    = 0;
	self.BUTTON_HOOK    = 0;
	self.BUTTON_CHAT    = 0;
	self.BUTTON_ATCK2   = 0;
	self.BUTTON_CROUCH  = 0;

	self.movement = '0 0 0';
	self.bot_cmd_keys = BOT_CMD_KEY_NONE;

	self.bot_exec_status = self.bot_exec_status | BOT_EXEC_STATUS_PAUSED;
	return CMD_STATUS_FINISHED;
}

float bot_cmd_moveto()
{
	return self.cmd_moveto(bot_cmd.bot_cmd_parm_vector);
}

float bot_cmd_resetgoal()
{
	return self.cmd_resetgoal();
}

void bot_command_executed(float rm)
{
	entity cmd;

	cmd = bot_cmd;

	self.bot_cmd_execution_index++;

	if(rm)
	{
		if(bot_cmd_parm_type[cmd.bot_cmd_type]==BOT_CMD_PARAMETER_STRING)
		{
			strunzone(cmd.bot_cmd_parm_string);
		}
		remove(cmd);
		return;
	}

	cmd.bot_cmd_execution_counter++;
}

void bot_setcurrentcommand()
{
	entity cmd;

	bot_cmd = world;

	if(self.bot_cmd_execution_index==0)
		self.bot_cmd_execution_index=1;

	for (cmd = findchainfloat(bot_cmd_index, self.bot_cmd_execution_index); cmd; cmd = cmd.chain)
	{
		if(cmd.owner==self)
		{
			bot_cmd = cmd;
			return;
		}
	}
}

// This function should be (the only) called directly from the bot ai loop
// It maps commands to functions and deal with complex interactions between commands and execution states
// NOTE: Of course you need to include your commands here too :)
float bot_execute_commands()
{
	local float status, index, ispressingkey;
	local entity cmd;

	// Find command
	bot_setcurrentcommand();

	// Keep pressing keys raised by the "presskey" command
	ispressingkey = bot_presskeys();

	if(bot_cmd==world)
		return ispressingkey;

	// Ignore all commands except continue when the bot is paused
	if(self.bot_exec_status & BOT_EXEC_STATUS_PAUSED)
	if(bot_cmd.bot_cmd_type!=BOT_CMD_CONTINUE)
	{
		if(bot_cmd.bot_cmd_type!=BOT_CMD_NULL)
		{
			bot_command_executed(TRUE);
			print( "WARNING: Commands are ignored while the bot is paused. Use the command 'continue' instead.\n");
		}
		return TRUE;
	}

	// Handle conditions
	if not(bot_cmd.bot_cmd_type==BOT_CMD_FI||bot_cmd.bot_cmd_type==BOT_CMD_ELSE)
	if(self.bot_cmd_condition_status & CMD_CONDITION_TRUE && self.bot_cmd_condition_status & CMD_CONDITION_FALSE_BLOCK)
	{
		bot_command_executed(TRUE);
		return TRUE;
	}
	else if(self.bot_cmd_condition_status & CMD_CONDITION_FALSE && self.bot_cmd_condition_status & CMD_CONDITION_TRUE_BLOCK)
	{
		bot_command_executed(TRUE);
		return TRUE;
	}

	// Map commands to functions
	switch(bot_cmd.bot_cmd_type)
	{
		case BOT_CMD_NULL:
			return ispressingkey;
			break;
		case BOT_CMD_PAUSE:
			status = bot_cmd_pause();
			break;
		case BOT_CMD_CONTINUE:
			status = bot_cmd_continue();
			break;
		case BOT_CMD_WAIT:
			status = bot_cmd_wait();
			break;
		case BOT_CMD_TURN:
			status = bot_cmd_turn();
			break;
		case BOT_CMD_MOVETO:
			status = bot_cmd_moveto();
			break;
		case BOT_CMD_RESETGOAL:
			status = bot_cmd_resetgoal();
			break;
		case BOT_CMD_CC:
			status = bot_cmd_cc();
			break;
		case BOT_CMD_IF:
			status = bot_cmd_if();
			break;
		case BOT_CMD_ELSE:
			status = bot_cmd_else();
			break;
		case BOT_CMD_FI:
			status = bot_cmd_fi();
			break;
		case BOT_CMD_RESETAIM:
			status = bot_cmd_resetaim();
			break;
		case BOT_CMD_AIM:
			status = bot_cmd_aim();
			break;
		case BOT_CMD_PRESSKEY:
			status = bot_cmd_presskey();
			break;
		case BOT_CMD_RELEASEKEY:
			status = bot_cmd_releasekey();
			break;
		case BOT_CMD_SELECTWEAPON:
			status = bot_cmd_select_weapon();
			break;
		case BOT_CMD_IMPULSE:
			status = bot_cmd_impulse();
			break;
		default:
			print(strcat("ERROR: Invalid command on queue with id '",ftos(bot_cmd.bot_cmd_type),"'\n"));
			return FALSE;
	}

	if (status==CMD_STATUS_ERROR)
		print(strcat("ERROR: The command '",bot_cmd_string[bot_cmd.bot_cmd_type],"' returned an error status\n"));

	// Move execution pointer
	if not(status==CMD_STATUS_EXECUTING)
	{
		if(cvar("g_debug_bot_commands"))
		{
			local string parms;

			switch(bot_cmd_parm_type[bot_cmd.bot_cmd_type])
			{
				case BOT_CMD_PARAMETER_FLOAT:
					parms = ftos(bot_cmd.bot_cmd_parm_float);
					break;
				case BOT_CMD_PARAMETER_STRING:
					parms = bot_cmd.bot_cmd_parm_string;
					break;
				case BOT_CMD_PARAMETER_VECTOR:
					parms = vtos(bot_cmd.bot_cmd_parm_vector);
					break;
				default:
					parms = "";
					break;
			}
			clientcommand(self,strcat("say ^7", bot_cmd_string[bot_cmd.bot_cmd_type]," ",parms,"\n"));
		}

		bot_command_executed(TRUE);
	}

	return TRUE;
}
