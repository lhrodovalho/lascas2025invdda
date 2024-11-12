#!/usr/bin/tclsh

set fnList [glob *.dat0]
foreach fn $fnList {
  set fp [open "$fn" r]
  set lines [read -nonewline $fp]
  close $fp
  puts "$lines"
}

