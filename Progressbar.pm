package Progressbar;

use strict;
use warnings;
use Term::ReadKey;

$| = 1;

sub new {
	my $class = shift;
	my %self = (
			this => 0,
			total => 10,
			width => 'auto',
			show_percent => 1,
			@_
		);

	return bless \%self, $class;
}

sub update {
	my $self = shift;
	my $key = shift;
	$self->{$key} = shift;
	return $self;
}

sub print_progressbar {
	my $self = shift;

	my $width = $self->{width};

	if($self->{width} eq 'auto') {
		my ($wchar) = GetTerminalSize();
		$width = $wchar * 0.5;
	}

	my $total = $self->{total};
	my $this = $self->{this};

	my $percent = ($self->{this} / $self->{total});
	my $string = '>'.('=' x int($width * $percent)).(' ' x ($width - int($width * $percent))).'<';

	my $tmp_preprint = '';
	if($self->{preprint}) {
		$tmp_preprint = $self->preprint();
	}

	if($self->{show_percent}) {
		my @spl = split(//, $string);
		my $percent_full = int($percent * 100);

		if(length($percent_full) % 2 == 0) {
			$percent_full .= ' ';
		}
		$percent_full = " $percent_full% ";
		substr($string, (($#spl / 2) - (length($percent_full) / 2)), length($percent_full), $percent_full);
	}

	redo_print($tmp_preprint.$string);
}

sub preprint {
	my $self = shift;

	my $preprint = $self->{preprint};

	my @spl = split(//, $preprint);
	my $started_variable = 0;

	my @parsed = ('');

	my $i = 0;

	while ($i <= $#spl) {
		my $this_item = $spl[$i];

		if($started_variable) {
			my $this_length;
			my $this_name;
			while ($spl[$i] ne ',') {
				$this_length .= $spl[$i];
				$i++;
			}

			$i++;

			while ($spl[$i] ne '}') {
				$this_name .= $spl[$i];
				$i++;
			}
			$started_variable = 0;
			push @parsed, { length => $this_length, name => $this_name }, '';
		} elsif($this_item eq '{' && (($i > 0 && $spl[$i - 1] ne '\\') || $i == 0)) {
			$started_variable = 1;
		} else {
			$parsed[$#parsed] .= $spl[$i];
		}
		$i++;
	}

	delete $parsed[$#parsed] if $parsed[$#parsed] eq '';

	my $output = '';

	foreach (@parsed) {
		if(ref($_) eq 'HASH') {
			my $this_length = $_->{length};
			my $this_value = $self->{$_->{name}};

			my $around = ($this_length - length($this_value));
			if($around % 2 == 0) {
				$output .= (' ' x ($around / 2).$this_value.' ' x ($around / 2));
			} else {
				$output .= ' '.(' ' x (($around - 1)/ 2).$this_value.' ' x (($around - 1)/ 2));
			}
		} else {
			$output .= $_;
		}
	}
	return $output;
}

sub redo_print {
	my $print = shift;

	my ($wchar, $hchar, $wpixels, $hpixels) = GetTerminalSize();

	my $backspace = chr(0x08);
	print $backspace x $wchar;
	print $print.(' ' x ($wchar - length($print)));
}

1;
