onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_mididecoder/t_clk
add wave -noupdate /tb_mididecoder/t_reset_n
add wave -noupdate /tb_mididecoder/t_data
add wave -noupdate /tb_mididecoder/t_dataEN
add wave -noupdate /tb_mididecoder/t_noteOnOff
add wave -noupdate /tb_mididecoder/t_note
add wave -noupdate /tb_mididecoder/t_noteEn
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 238
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {4160 ns} {5339 ns}
