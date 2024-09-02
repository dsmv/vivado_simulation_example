set test_id_val 1
puts ${test_id_val}

if { [info script] eq $::argv0 } {
   puts {In main}
} else {
    puts {Sourcing [info script]}
    close_sim
}
xsim tb_behav -testplusarg test_id=${test_id_val}  -view ./top.wcfg  -view uut.wcfg



