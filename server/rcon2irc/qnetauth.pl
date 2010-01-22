# Nexuiz rcon2irc plugin by Merlijn Hofstra licensed under GPL - qnetauth.pl
# Place this file inside the same directory as rcon2irc.pl and add the full filename to the plugins.

# This plugin will automatically authenticate users who have a login for Quakenet (on the Q bot).
# If you login to the Q bot, this plugin will pick this up and users in the list below can automatically
# execute commands on the rcon2irc bot.
{ my @users = qw{merlijn};

$store{plugin_qnetauth}->{users} = \@users; }

sub out($$@);
sub schedule($$);

if (defined %config) {
	schedule sub {
		my ($timer) = @_;
		out irc => 0, "PRIVMSG Q :users " . $config{irc_channel};
		schedule $timer => 300;;
	} => 1;
}

# Catch joins of people in a channel the bot is in and catch our own joins of a channel
[ irc => q{:(([^! ]*)![^ ]*) JOIN (#.+)} => sub {
	my ($hostmask, $nick, $chan) = @_;
	my $qa = $store{plugin_qnetauth};
	
	if ($nick eq $config{irc_nick}) {
		out irc => 0, "PRIVMSG Q :users $chan"; # get auths for all users
	} else {
		$qa->{hosts}->{$nick} = $hostmask;
		out irc => 0, "PRIVMSG Q :whois $nick"; # get auth for single user
	}
	
	return 0;
} ],

# Catch response of users request
[ irc => q{:Q!TheQBot@CServe.quakenet.org NOTICE [^:]+ :[@\+\s]?(\S+)\s+(\S+)\s*(\S*)\s*\((.*)\)} => sub {
	my ($nick, $username, $flags, $host) = @_;
	my $qa = $store{plugin_qnetauth};
	
	foreach my $user (@{ $qa->{users} }) {
		$store{logins}{"$nick!$host"} = time() + 600 if ($user eq $username);
	}
	
	return 0;
} ],

# Catch response of whois request
[ irc => q{:Q!TheQBot@CServe.quakenet.org NOTICE [^:]+ :-Information for user (.*) \(using account (.*)\):} => sub {
	my ($nick, $username) = @_;
	my $qa = $store{plugin_qnetauth};
	
	foreach my $user (@{ $qa->{users} }) {
		if ($user eq $username) {
			my $hostmask = $qa->{hosts}->{$nick};
			$store{logins}{$hostmask} = time() + 600;
		}
	}
	
	return 0;
} ],
