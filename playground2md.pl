#!/usr/bin/perl

#  playground2md.pl
#  FallibleKit
#
#  Created by Brent Royal-Gordon on 6/11/15.
#  Copyright (c) 2015 Architechies. All rights reserved.

use strict;
use warnings;

for my $playground_name(@ARGV) {
    my $in_markdown = 0;
    
    open(my $swift_file, "<", "$playground_name/Contents.swift")
        or die "Can't open $playground_name/Contents.swift: $!";
    
    (my $md_name = $playground_name) =~ s/\.playground$/.md/;
    open(my $md_file, ">", $md_name)
        or die "Can't open $md_name for writing: $!";
    
    while(<$swift_file>) {
        if($in_markdown) {
            # We're in a Markdown section
            if(s(^\*/$)()) {
                # Hit the end
                $in_markdown = 0;
                next;
            }
            # Print verbatim
            print $md_file $_;
        }
        else {
            # We're in a code section
            if(s(^/\*:$)()) {
                # Hit Markdown
                $in_markdown = 1;
                next;
            }
            # Print indented
            
            if(m(\S)) {
                print $md_file "    ", $_;
            }
            else {
                print $md_file $_;
            }
        }
    }
}
