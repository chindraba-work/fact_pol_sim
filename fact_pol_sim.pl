#!/usr/bin/env perl

# SPDX-License-Identifier: MIT

########################################################################
#                                                                      #
#  A quick script to roughly simulate the effects of pollution from    #
#  the use of flamethrowers as a defensive line                        #
#                                                                      #
#  Copyright © 2023  Chindraba (Ronald Lamoreaux)                      #
#                    <projects@chindraba.work>                         #
#  - All Rights Reserved                                               #
#                                                                      #
#  Permission is hereby granted, free of charge, to any person         #
#  obtaining a copy of this software and associated documentation      #
#  files (the "Software"), to deal in the Software without             #
#  restriction, including without limitation the rights to use, copy,  #
#  modify, merge, publish, distribute, sublicense, and/or sell copies  #
#  of the Software, and to permit persons to whom the Software is      #
#  furnished to do so, subject to the following conditions:            #
#                                                                      #
#  The above copyright notice and this permission notice shall be      #
#  included in all copies or substantial portions of the Software.     #
#                                                                      #
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,     #
#  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF  #
#  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND               #
#  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS #
#  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN  #
#  ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN   #
#  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE    #
#  SOFTWARE.                                                           #
#                                                                      #
########################################################################


use 5.030000;
use strict;
use warnings;

my $VERSION = '0.0.1';

# Available options for testing
# How many 'minutes' to run the simulation
my $time_limit = 236;
# Number of repeats to call "stable"
my $level_check = 7;
# Number of loops to consider as final
my $loop_check = 2;

# Settings for each round
# Pollution values to work through for each base pollution set
my @battle_set = (0, 60_000, 120_000, 240_000, 500_000, 1_000_000);
# Base pollution sets: make = the active production, base = pre-loaded chunk values
my @data_sets = (
    {
        make => 100_000_000,
        base =>  20_000_010,
    },
    {
        make => 500_000_000,
        base =>  20_000_010,
    },
    {
        make => 500_000_000,
        base => 100_000_010,
    },
    {
        make => 500_000_000,
        base => 500_000_010,
    },
    {
        make => 1_000_000_000,
        base =>    20_000_010,
    },
    {
        make => 1_000_000_000,
        base =>   500_000_010,
    },
    {
        make => 5_000_000_000,
        base =>    20_000_010,
    },
    {
        make => 5_000_000_000,
        base =>   500_000_010,
    },
    {
        make => 10_000_000_000,
        base =>     20_000_010,
    },
    {
        make => 5_000_000_000,
        base =>   500_000_010,
    },
    {
        make => 100_000_000_000,
        base =>     500_000_010,
    },
);
# Operating data for each test from the lists above
my ($base_pollution, $battle_dirt_each, $production);

# Built-in values from the game
my ($absorb_min, $absorb_rate, $diffuse_min, $diffuse_rate, $hidden_dirt, $normal_dirt, $spawn_limit, $spawn_rate);
# NOTE: All pollution values are raised to x10^6 giving six decimal places using integer math

# The minimum pollution in a chunk before spawners will absorb any
$absorb_min = 20_000_000;
# The variable portion of how much a spawner can absorb ber 64-tick cycle
$absorb_rate = 0.01;
# The minimum pollution in a chunk before it can spread pollution by diffusion
$diffuse_min = 15_000_000;
# Pollution diffusion rate
$diffuse_rate = 0.02; # Default game setting is 2%
# Pollution absorbed (scrubbed) by out-of-map chunks, pollution diffusion can "create" new chunks
$hidden_dirt        = 10_923;
# The amount of pollution each chunk will absorb (scrub) in 64-ticks using sand (worst)
$normal_dirt        = 6_335;
# Max biters a spawner can have spawned at any time, built into the game
# I don't have the real number, but observation at 99% evo looks like 7
$spawn_limit = 7;
# Delay between spawner creation of bugs. Unknown value but some observation suggests
# 2 sec after a medium and 7 or 8 sec after a big. Split the difference and use it
# for both med and big
$spawn_rate = 5;

# Counters and progress trackers
my ($attack_force, $battle_dirt, $battle_num, $kills, $long_cycle, $pattern_detected , $produced_dirt, $short_cycle);
# Tally report elements
my (@header_set, @kill_tally, $tally_format);
# Format for lines in the tally table
$tally_format = "%10s: %4s: %4s: %4s: %4s: %4s: %4s: %4s: %4s: %5s: %5s: %6s\n";
# Column headers for the tally table
@header_set = (
    ['Pollution'],
    ['Pol. Base'],
);
# Row labels for the tally table
@kill_tally = (
    ['Laser    0'],
    ['Size'],
    ['Flamer   6'],
    ['Size'],
    ['Flamer  12'],
    ['Size'],
    ['Flamer  24'],
    ['Size'],
    ['Flamer  50'],
    ['Size'],
    ['Flamer 100'],
    ['Size'],
);
# Operational data
my (@chunk_list, @chunks, @kill_record, @spawners);
# Names for the chunks
@chunk_list = (
    'Turret rear',
    'Turret line',
    'Turret zone',
    'Buffer zone',
    '3 spawners',
    '2 spawners',
    '1 spawner',
);

sub absorb_dirt {
    return if ( $_[0]->{'threshold'} < $_[0]->{'balance'} );
    my $target =  ( $absorb_min < $_[1]->{'dirt'} )
        ? sprintf( "%d",  $absorb_rate * $_[1]->{'dirt'} + $absorb_min )
        : 0;
    $_[0]->{'balance'}  += $target;
    $_[0]->{'absorbed'} += $target;
    $_[1]->{'dirt'}     -= $target;
    $_[1]->{'asborbed'} += $target;
}

sub diffuse_dirt {
    return unless ( $diffuse_min <= $chunks[$_[0]]->{'history'}[$short_cycle] );
    my $diffusable = sprintf "%d", $diffuse_rate * $chunks[$_[0]]->{'history'}[$short_cycle];
    unless ( 0 == $_[0] ) {
        $chunks[$_[0]]->{'dirt'}     -= $diffusable;
        $chunks[$_[0]-1]->{'dirt'}   += $diffusable;
        $chunks[$_[0]-1]->{'dirty'}  += $diffusable;
        $chunks[$_[0]]->{'diffused'} += $diffusable;
    }
    unless ( $#chunks == $_[0] ) {
        $chunks[$_[0]]->{'dirt'}     -= $diffusable;
        $chunks[$_[0]+1]->{'dirt'}   += $diffusable;
        $chunks[$_[0]+1]->{'dirty'}  += $diffusable;
        $chunks[$_[0]]->{'diffused'} += $diffusable;
    } elsif ( 0 < $diffusable ) {
        $chunks[$_[0]]->{'dirt'}     -= $diffusable;
        push @chunks, make_chunk($diffusable);
        $chunks[$_[0]]->{'diffused'} += $diffusable;
    }
}

sub diffuse_production {
    return unless ( $diffuse_min <= $production );
    my $target = sprintf("%d", $diffuse_rate * $production);
    $chunks[0]->{'dirt'}  += $target;
    $chunks[0]->{'dirty'} += $target;
    $produced_dirt += $target;
}

sub make_chunk {
    my $new_chunk = {
        position => scalar(@chunks),
        label    => (( defined $_[1])? $_[1] : "Added $short_cycle"),
        scrubs   => ( ( defined $_[1] )? $normal_dirt : $hidden_dirt ),
        dirt     => $_[0],
        dirty    => $_[0],
        absorbed => 0,
        srcubbed => 0,
    };
    $new_chunk->{'history'}->[$short_cycle] = $_[0];
    return $new_chunk;
}

sub report_loop {
    printf "Detected attack force size loop between %d and %d.\n",
        $kill_record[2]->{'value'},
        $kill_record[1]->{'value'};
        push @{$kill_tally[$_[0]*2+1]}, $kill_record[1]->{'value'}."+";
}

sub report_stable {
    printf "Detected stabilized attack force size of %d.\n",
        $kill_record[0]->{'value'};
        push @{$kill_tally[$_[0]*2+1]}, $kill_record[0]->{'value'};
}

sub scrub_dirt {
    my $target = ( $_[0]->{'scrubs'} < $_[0]->{'dirt'})? $_[0]->{'scrubs'} : $_[0]->{'dirt'};
    $_[0]->{'scrubbed'} += $target;
    $_[0]->{'dirt'}     -= $target;
}

sub send_one {
    return unless ( $_->{'threshold'} <  $_->{'balance'} && $_->{'available'} );
    $_->{'balance'} -= $_->{'attack_cost'};
    --$_->{'available'};
    ++$_->{'attackers'};
    ++$attack_force;
}

sub show_value {
    return sprintf("%.2f", $_[0]/1_000_000);
}

sub solo_update {
        map { diffuse_dirt $_; } (0..$#chunks);
        diffuse_production;
        map { spawn_one $_; }(@spawners);
        map { absorb_dirt $_, $chunks[$_->{'chunk_id'}]; } (@spawners);
        map { send_one $_; } (@spawners);
        map { scrub_dirt $_; } (@chunks);
}

sub spawn_one {
    return unless ( $_[0]->{'rate_offset'} == $short_cycle % $spawn_rate && $_[0]->{'owned'} < $spawn_limit );
    ++$_[0]->{'owned'};
    ++$_[0]->{'available'};
}

foreach my $data_set (@data_sets) {
    $production = $data_set->{'make'};
    push @{$header_set[0]}, sprintf("%d",show_value( $production ) );
    $base_pollution = $data_set->{'base'};
    push @{$header_set[1]}, sprintf("%d",show_value( $base_pollution ) );
    foreach $battle_num (0..$#battle_set) {
        $battle_dirt_each = $battle_set[$battle_num];
        printf "Testing with:\n\tProduced pollution: %s\n\tChunks pre-loaded with %s pollution\n\tPollution per bug killed: %s\n",
            show_value($production),
            show_value($base_pollution),
            show_value($battle_dirt_each);
        $long_cycle = $short_cycle = $pattern_detected = $attack_force = 0;
        @kill_record = ();
        $kills = 0;
        foreach (1..4) {
            push @kill_record, {
                value => -1,
                began => 0,
            };
        }
        @chunks = map { make_chunk($base_pollution, $_); } @chunk_list;
        @spawners = (
            {
                chunk_id => 3, # medium spitter
                label => "c5 ms1",
                absorbed => 0,
                balance => 0,
                owned => 0,
                available => 0,
                attackers => 0,
                attack_cost => 12_000_000,
                threshold => 90_000_000,
                rate_offset => 0,
            },
            {
                chunk_id => 4, # medium spitter
                label => "c5 ms2",
                absorbed => 0,
                balance => 0,
                owned => 0,
                available => 0,
                attackers => 0,
                attack_cost => 12_000_000,
                threshold => 90_000_000,
                rate_offset => 1,
            },
            {
                chunk_id => 4, # big biter
                label => "c5 bb1",
                absorbed => 0,
                balance => 0,
                owned => 0,
                available => 0,
                attackers => 0,
                attack_cost => 80_000_000,
                threshold => 240_000_000,
                rate_offset => 2,
            },
            {
                chunk_id => 5, # big spitter
                label => "c5 bs1",
                absorbed => 0,
                balance => 0,
                owned => 0,
                available => 0,
                attackers => 0,
                attack_cost => 30_000_000,
                threshold => 90_000_000,
                rate_offset => 3,
            },
            {
                chunk_id => 5, # medium biter
                label => "c6 mb1",
                absorbed => 0,
                balance => 0,
                owned => 0,
                available => 0,
                attackers => 0,
                attack_cost => 20_000_000,
                threshold => 240_000_000,
                rate_offset => 4,
            },
            {
                chunk_id => 6, # big biter
                label => "c7 bb2",
                absorbed => 0,
                balance => 0,
                owned => 0,
                available => 0,
                attackers => 0,
                attack_cost => 80_000_000,
                threshold => 240_000_000,
                rate_offset => 3,
            },
        );
        while ( $time_limit > $long_cycle ) {
            map { diffuse_dirt $_; } (0..$#chunks);
            diffuse_production;
            map { spawn_one $_; }(@spawners);
            map { absorb_dirt $_, $chunks[$_->{'chunk_id'}]; } (@spawners);
            map { send_one $_; } (@spawners);
            map { scrub_dirt $_; } (@chunks);
            #solo_update;
            ++$short_cycle;
            if ( 0 == $short_cycle % 57 ) {
                my $dirt += $attack_force * $battle_dirt_each;
                $battle_dirt += $dirt;
                $chunks[2]->{'dirt'} += $dirt;
                $chunks[2]->{'dirty'} += $dirt;
                $kills += $attack_force;
                map { $_->{'owned'} -= $_->{'attackers'}; $_->{'attackers'} = 0; } (@spawners);
                ++$long_cycle;
                unless ( $pattern_detected ) {
                    if ( $attack_force == $kill_record[0]->{'value'} ) {
                        if ( $level_check == $long_cycle - $kill_record[0]->{'began'} ) {
                            report_stable $battle_num;
                            $pattern_detected = 1;
                        }
                    } elsif ( $attack_force != $kill_record[1]->{'value'}
                            || $kill_record[0]->{'value'} != $kill_record[2]->{'value'} ) {
                        $kill_record[2] = $kill_record[1];
                        $kill_record[1] = $kill_record[0];
                        $kill_record[0] = { value => $attack_force, began => $long_cycle, };
                        $kill_record[3]->{'value'} = -1;
                    } elsif ( $kill_record[3]->{'value'} == $loop_check ) { 
                        report_loop $battle_num;
                        $pattern_detected = 1;
                    } elsif ( $kill_record[0] == -1 ) {
                        $kill_record[3]->{'began'} = $long_cycle;
                        ++$kill_record[3]->{'value'};
                    } else {
                        ++$kill_record[3]->{'value'};
                    }
                }
                $attack_force = 0;
            }
            map { $chunks[$_]->{'history'}[$short_cycle] = $chunks[$_]->{'dirt'}; } (0..$#chunks);
        }
        say "\tAfter $time_limit cycles total kills are ".$kills;
        say "********************************************************************************";
        push @{$kill_tally[$battle_num*2]}, $kills;
        push( @{$kill_tally[$battle_num*2+1]}, "-".$kill_record[0] ) unless ( $pattern_detected );
    }
}
foreach (@header_set) {
    printf $tally_format, (@{$_});
}
say "--------------------------------------------------------------------------------";
foreach (@kill_tally) {
    printf $tally_format, (@{$_});
}
say "================================================================================";

1;
