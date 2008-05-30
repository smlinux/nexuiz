#!/usr/bin/perl

# Copyright (c) 2008 Rudolf "divVerent" Polzer
# 
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.


# parts copied from rcon2irc

# convert mIRC color codes to DP color codes
our @color_irc2dp_table = (7, 0, 4, 2, 1, 1, 6, 1, 3, 2, 5, 5, 4, 6, 7, 7);
our @color_dp2irc_table = (14, 4, 9, 8, 12, 11, 13, 14, 15, 15); # not accurate, but legible
our @color_dp2ansi_table = ("m", "1;31m", "1;32m", "1;33m", "1;34m", "1;36m", "1;35m", "m", "1m", "1m"); # not accurate, but legible
our %color_team2dp_table = (5 => 1, 14 => 4, 13 => 3, 10 => 6);
our %color_team2irc_table = (5 => 4, 14 => 12, 13 => 8, 10 => 13);
sub color_irc2dp($)
{
	my ($message) = @_;
	$message =~ s/\^/^^/g;
	my $color = 7;
	$message =~ s{\003(\d\d?)(?:,(\d?\d?))?|(\017)}{
		# $1 is FG, $2 is BG, but let's ignore BG
		my $oldcolor = $color;
		if($3)
		{
			$color = 7;
		}
		else
		{
			$color = $color_irc2dp_table[$1];
			$color = $oldcolor if not defined $color;
		}
		($color == $oldcolor) ? '' : '^' . $color;
	}esg;
	$message =~ s{[\000-\037]}{}gs; # kill bold etc. for now
	return $message;
}

our @text_qfont_table = ( # ripped from DP console.c qfont_table
    "\0", '#',  '#',  '#',  '#',  '.',  '#',  '#',
    '#',  9,    10,   '#',  ' ',  13,   '.',  '.',
    '[',  ']',  '0',  '1',  '2',  '3',  '4',  '5',
    '6',  '7',  '8',  '9',  '.',  '<',  '=',  '>',
    ' ',  '!',  '"',  '#',  '$',  '%',  '&',  '\'',
    '(',  ')',  '*',  '+',  ',',  '-',  '.',  '/',
    '0',  '1',  '2',  '3',  '4',  '5',  '6',  '7',
    '8',  '9',  ':',  ';',  '<',  '=',  '>',  '?',
    '@',  'A',  'B',  'C',  'D',  'E',  'F',  'G',
    'H',  'I',  'J',  'K',  'L',  'M',  'N',  'O',
    'P',  'Q',  'R',  'S',  'T',  'U',  'V',  'W',
    'X',  'Y',  'Z',  '[',  '\\', ']',  '^',  '_',
    '`',  'a',  'b',  'c',  'd',  'e',  'f',  'g',
    'h',  'i',  'j',  'k',  'l',  'm',  'n',  'o',
    'p',  'q',  'r',  's',  't',  'u',  'v',  'w',
    'x',  'y',  'z',  '{',  '|',  '}',  '~',  '<',
    '<',  '=',  '>',  '#',  '#',  '.',  '#',  '#',
    '#',  '#',  ' ',  '#',  ' ',  '>',  '.',  '.',
    '[',  ']',  '0',  '1',  '2',  '3',  '4',  '5',
    '6',  '7',  '8',  '9',  '.',  '<',  '=',  '>',
    ' ',  '!',  '"',  '#',  '$',  '%',  '&',  '\'',
    '(',  ')',  '*',  '+',  ',',  '-',  '.',  '/',
    '0',  '1',  '2',  '3',  '4',  '5',  '6',  '7',
    '8',  '9',  ':',  ';',  '<',  '=',  '>',  '?',
    '@',  'A',  'B',  'C',  'D',  'E',  'F',  'G',
    'H',  'I',  'J',  'K',  'L',  'M',  'N',  'O',
    'P',  'Q',  'R',  'S',  'T',  'U',  'V',  'W',
    'X',  'Y',  'Z',  '[',  '\\', ']',  '^',  '_',
    '`',  'a',  'b',  'c',  'd',  'e',  'f',  'g',
    'h',  'i',  'j',  'k',  'l',  'm',  'n',  'o',
    'p',  'q',  'r',  's',  't',  'u',  'v',  'w',
    'x',  'y',  'z',  '{',  '|',  '}',  '~',  '<'
);
sub text_dp2ascii($)
{
	my ($message) = @_;
	$message = join '', map { $text_qfont_table[ord $_] } split //, $message;
}

sub color_dp2none($)
{
	my ($message) = @_;
	my $color = -1;
	$message =~ s{\^(.)(?=([0-9,]?))}{
		my $c = $1;
		$c eq '^' ? '^' :
		$c =~ /^[0-9]$/ ? '' : "^$c";
	}esg;
	return text_dp2ascii $message;
}

sub color_dp2irc($)
{
	my ($message) = @_;
	my $color = -1;
	$message =~ s{\^(.)(?=([0-9,]?))}{
		my $c = $1;
		my $f = $2;
		$c eq '^' ? '^' :
		$c =~ /^[0-9]$/ ? do {
			my $oldcolor = $color;
			$c = 0 if $c >= 7; # map 0, 7, 8, 9 to default (no bright white or such stuff)
			$color = $color_dp2irc_table[$c];
			($color == $oldcolor) ? '' :
			$c == 0 ? "\0001" :
			$f eq ',' ? "\0003$color\0002\0002" :
			$f ne ''  ? sprintf "\0003%02d", $color : "\0003$color";
		} : "^$c";
	}esg;
	$message = text_dp2ascii $message;
	$message =~ s/\0001/\017/g;
	$message =~ s/\0002/\002/g;
	$message =~ s/\0003/\003/g;
	return $message;
}

sub color_dp2ansi($)
{
	my ($message) = @_;
	my $color = -1;
	$message =~ s{\^(.)}{
		my $c = $1;
		$c eq '^' ? '^' :
		$c =~ /^[0-9]$/ ? do {
			my $oldcolor = $color;
			$color = $color_dp2ansi_table[$c];
			($color eq $oldcolor) ? '' :
			"\000[${color}" # "
		} : "^$c";
	}esg;
	$message = text_dp2ascii $message;
	$message =~ s/\000/\033/g;
	return $message;
}

sub color_dpfix($)
{
	my ($message) = @_;
	# if the message ends with an odd number of ^, kill one
	chop $message if $message =~ /(?:^|[^\^])\^(\^\^)*$/;
	return $message;
}



# Interfaces:
#   Connection:
#     $conn->sockname() returns a connection type specific representation
#       string of the local address, or undef if not applicable.
#     $conn->send("string") sends something over the connection.
#     $conn->recv() receives a string from the connection, or returns "" if no
#       data is available.
#     $conn->fds() returns all file descriptors used by the connection, so one
#       can use select() on them.
#   Channel:
#     Usually wraps around a connection and implements a command based
#     structure over it. It usually is constructed using new
#     ChannelType($connection, someparameters...)
#     @cmds = $chan->join_commands(@cmds) joins multiple commands to a single
#       command string if the protocol supports it, or does nothing and leaves
#       @cmds unchanged if the protocol does not support that usage (this is
#       meant to save send() invocations).
#     $chan->send($command, $nothrottle) sends a command over the channel. If
#       $nothrottle is sent, the command must not be left out even if the channel
#       is saturated (for example, because of IRC's flood control mechanism).
#     $chan->quote($str) returns a string in a quoted form so it can safely be
#       inserted as a substring into a command, or returns $str as is if not
#       applicable. It is assumed that the result of the quote method is used
#       as part of a quoted string, if the protocol supports that.
#     $chan->recv() returns a list of received commands from the channel, or
#       the empty list if none are available.
#     $conn->fds() returns all file descriptors used by the channel's
#       connections, so one can use select() on them.







# Socket connection.
# Represents a connection over a socket.
# Mainly used to wrap a channel around it for, in this case, line based or rcon-like operation.
package Connection::Socket;
use strict;
use warnings;
use IO::Socket::INET;
use IO::Handle;

# Constructor:
#   my $conn = new Connection::Socket(tcp => "localaddress" => "remoteaddress" => 6667);
# If the remote address does not contain a port number, the numeric port is
# used (it serves as a default port).
sub new($$)
{
	my ($class, $proto, $local, $remote, $defaultport) = @_;
	my $sock = IO::Socket::INET->new(
		Proto => $proto,
		(length($local) ? (LocalAddr => $local) : ()),
		PeerAddr => $remote,
		PeerPort => $defaultport
	) or die "socket $proto/$local/$remote: $!";
	$sock->blocking(0);
	my $you = {
		# Mortal fool! Release me from this wretched tomb! I must be set free
		# or I will haunt you forever! I will hide your keys beneath the
		# cushions of your upholstered furniture... and NEVERMORE will you be
		# able to find socks that match!
		sock => $sock,
		# My demonic powers have made me OMNIPOTENT! Bwahahahahahahaha!
	};
	return
		bless $you, 'Connection::Socket';
}

# $sock->sockname() returns the local address of the socket.
sub sockname($)
{
	my ($self) = @_;
	my ($port, $addr) = sockaddr_in $self->{sock}->sockname();
	return "@{[inet_ntoa $addr]}:$port";
}

# $sock->send($data) sends some data over the socket; on success, 1 is returned.
sub send($$)
{
	my ($self, $data) = @_;
	return 1
		if not length $data;
	if(not eval { $self->{sock}->send($data); })
	{
		warn "$@";
		return 0;
	}
	return 1;
}

# $sock->recv() receives as much as possible from the socket (or at most 32k). Returns "" if no data is available.
sub recv($)
{
	my ($self) = @_;
	my $data = "";
	$self->{sock}->recv($data, 32768, 0);
	return $data;
}

# $sock->fds() returns the socket file descriptor.
sub fds($)
{
	my ($self) = @_;
	return fileno $self->{sock};
}







# QW rcon protocol channel.
# Wraps around a UDP based Connection and sends commands as rcon commands as
# well as receives rcon replies. The quote and join_commands methods are using
# DarkPlaces engine specific rcon protocol extensions.
package Channel::QW;
use strict;
use warnings;

# Constructor:
#   my $chan = new Channel::QW($connection, "password");
sub new($$)
{
	my ($class, $conn, $password) = @_;
	my $you = {
		connector => $conn,
		password => $password,
		recvbuf => "",
	};
	return
		bless $you, 'Channel::QW';
}

# Note: multiple commands in one rcon packet is a DarkPlaces extension.
sub join_commands($@)
{
	my ($self, @data) = @_;
	return join "\0", @data;
}

sub send($$$)
{
	my ($self, $line, $nothrottle) = @_;
	return $self->{connector}->send("\377\377\377\377rcon $self->{password} $line");
}

# Note: backslash and quotation mark escaping is a DarkPlaces extension.
sub quote($$)
{
	my ($self, $data) = @_;
	$data =~ s/[\000-\037]//g;
	$data =~ s/([\\"])/\\$1/g;
	$data =~ s/\$/\$\$/g;
	return $data;
}

sub recv($)
{
	my ($self) = @_;
	for(;;)
	{
		length(my $s = $self->{connector}->recv())
			or last;
		next
			if $s !~ /^\377\377\377\377n(.*)$/s;
		$self->{recvbuf} .= $1;
	}
	my @out = ();
	while($self->{recvbuf} =~ s/^(.*?)(?:\r\n?|\n)//)
	{
		push @out, $1;
	}
	return @out;
}

sub fds($)
{
	my ($self) = @_;
	return $self->{connector}->fds();
}







package main;
use strict;
use warnings;
use IO::Select;

sub default($$)
{
	my ($default, $value) = @_;
	return $value if defined $value;
	return $default;
}

my $server   = default '',  $ENV{rcon_address};
my $password = default '',  $ENV{rcon_password};
my $timeout  = default '5', $ENV{rcon_timeout};
my $colors   = default '0', $ENV{rcon_colorcodes_raw};

if(!length $server)
{
	print STDERR "Usage: rcon_address=SERVERIP:PORT rcon_password=PASSWORD $0 rconcommands...\n";
	print STDERR "Optional: rcon_timeout=... (default: 5)\n";
	print STDERR "          rcon_colorcodes_raw=1 (to disable color codes translation)\n";
	exit 0;
}

my $connection = Connection::Socket->new("udp", "", $server, 26000);
my $rcon = Channel::QW->new($connection, $password);

if(!$rcon->send($rcon->join_commands(@ARGV)))
{
	die "send: $!";
}

if($timeout)
{
	my $sel = IO::Select->new($rcon->fds());
	if($sel->can_read($timeout))
	{
		for($rcon->recv())
		{
			$_ = (color_dp2ansi $_) . "\033[m" unless $colors;
			print "$_\n"
		}
	}
}
