# Begin_DVE_Session_Save_Info
# DVE full session
# Saved on Fri Dec 6 20:33:54 2019
# Designs open: 1
#   Sim: simv
# Toplevel windows open: 2
# 	TopLevel.1
# 	TopLevel.2
#   Source.1: _vcs_unit__358072738
#   Wave.1: 501 signals
#   Group count = 22
#   Group vc0 signal count = 20
#   Group ssrrat0 signal count = 11
#   Group sq0 signal count = 39
#   Group rs0 signal count = 33
#   Group robss signal count = 25
#   Group rf signal count = 6
#   Group ras1 signal count = 18
#   Group r0 signal count = 26
#   Group prf0 signal count = 22
#   Group predictor signal count = 9
#   Group mt_ss signal count = 19
#   Group if_stage_0 signal count = 25
#   Group icache_mem signal count = 25
#   Group icache_control signal count = 27
#   Group i0 signal count = 15
#   Group fl1 signal count = 15
#   Group ex_out signal count = 71
#   Group disp0 signal count = 13
#   Group dcache_mem signal count = 20
#   Group dcache_control signal count = 36
#   Group c0 signal count = 8
#   Group btb signal count = 18
# End_DVE_Session_Save_Info

# DVE version: N-2017.12-SP2-1_Full64
# DVE build date: Jul 14 2018 20:58:30


#<Session mode="Full" path="/afs/umich.edu/user/r/i/rishank/Downloads/Rishank/Project4/6thDec/group5f19/testing2.vpd.tcl" type="Debug">

gui_set_loading_session_type Post
gui_continuetime_set

# Close design
if { [gui_sim_state -check active] } {
    gui_sim_terminate
}
gui_close_db -all
gui_expr_clear_all

# Close all windows
gui_close_window -type Console
gui_close_window -type Wave
gui_close_window -type Source
gui_close_window -type Schematic
gui_close_window -type Data
gui_close_window -type DriverLoad
gui_close_window -type List
gui_close_window -type Memory
gui_close_window -type HSPane
gui_close_window -type DLPane
gui_close_window -type Assertion
gui_close_window -type CovHier
gui_close_window -type CoverageTable
gui_close_window -type CoverageMap
gui_close_window -type CovDetail
gui_close_window -type Local
gui_close_window -type Stack
gui_close_window -type Watch
gui_close_window -type Group
gui_close_window -type Transaction



# Application preferences
gui_set_pref_value -key app_default_font -value {Helvetica,10,-1,5,50,0,0,0,0,0}
gui_src_preferences -tabstop 8 -maxbits 24 -windownumber 1
#<WindowLayout>

# DVE top-level session


# Create and position top-level window: TopLevel.1

if {![gui_exist_window -window TopLevel.1]} {
    set TopLevel.1 [ gui_create_window -type TopLevel \
       -icon $::env(DVE)/auxx/gui/images/toolbars/dvewin.xpm] 
} else { 
    set TopLevel.1 TopLevel.1
}
gui_show_window -window ${TopLevel.1} -show_state maximized -rect {{1 38} {2560 1378}}

# ToolBar settings
gui_set_toolbar_attributes -toolbar {TimeOperations} -dock_state top
gui_set_toolbar_attributes -toolbar {TimeOperations} -offset 0
gui_show_toolbar -toolbar {TimeOperations}
gui_hide_toolbar -toolbar {&File}
gui_set_toolbar_attributes -toolbar {&Edit} -dock_state top
gui_set_toolbar_attributes -toolbar {&Edit} -offset 0
gui_show_toolbar -toolbar {&Edit}
gui_hide_toolbar -toolbar {CopyPaste}
gui_set_toolbar_attributes -toolbar {&Trace} -dock_state top
gui_set_toolbar_attributes -toolbar {&Trace} -offset 0
gui_show_toolbar -toolbar {&Trace}
gui_hide_toolbar -toolbar {TraceInstance}
gui_hide_toolbar -toolbar {BackTrace}
gui_set_toolbar_attributes -toolbar {&Scope} -dock_state top
gui_set_toolbar_attributes -toolbar {&Scope} -offset 0
gui_show_toolbar -toolbar {&Scope}
gui_set_toolbar_attributes -toolbar {&Window} -dock_state top
gui_set_toolbar_attributes -toolbar {&Window} -offset 0
gui_show_toolbar -toolbar {&Window}
gui_set_toolbar_attributes -toolbar {Signal} -dock_state top
gui_set_toolbar_attributes -toolbar {Signal} -offset 0
gui_show_toolbar -toolbar {Signal}
gui_set_toolbar_attributes -toolbar {Zoom} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom} -offset 0
gui_show_toolbar -toolbar {Zoom}
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -offset 0
gui_show_toolbar -toolbar {Zoom And Pan History}
gui_set_toolbar_attributes -toolbar {Grid} -dock_state top
gui_set_toolbar_attributes -toolbar {Grid} -offset 0
gui_show_toolbar -toolbar {Grid}
gui_set_toolbar_attributes -toolbar {Simulator} -dock_state top
gui_set_toolbar_attributes -toolbar {Simulator} -offset 0
gui_show_toolbar -toolbar {Simulator}
gui_set_toolbar_attributes -toolbar {Interactive Rewind} -dock_state top
gui_set_toolbar_attributes -toolbar {Interactive Rewind} -offset 0
gui_show_toolbar -toolbar {Interactive Rewind}
gui_set_toolbar_attributes -toolbar {Testbench} -dock_state top
gui_set_toolbar_attributes -toolbar {Testbench} -offset 0
gui_show_toolbar -toolbar {Testbench}

# End ToolBar settings

# Docked window settings
set HSPane.1 [gui_create_window -type HSPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 470]
catch { set Hier.1 [gui_share_window -id ${HSPane.1} -type Hier] }
gui_set_window_pref_key -window ${HSPane.1} -key dock_width -value_type integer -value 470
gui_set_window_pref_key -window ${HSPane.1} -key dock_height -value_type integer -value -1
gui_set_window_pref_key -window ${HSPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${HSPane.1} {{left 0} {top 0} {width 469} {height 1160} {dock_state left} {dock_on_new_line true} {child_hier_colhier 312} {child_hier_coltype 186} {child_hier_colpd 0} {child_hier_col1 0} {child_hier_col2 1} {child_hier_col3 -1}}
set DLPane.1 [gui_create_window -type DLPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 315]
catch { set Data.1 [gui_share_window -id ${DLPane.1} -type Data] }
gui_set_window_pref_key -window ${DLPane.1} -key dock_width -value_type integer -value 315
gui_set_window_pref_key -window ${DLPane.1} -key dock_height -value_type integer -value 1160
gui_set_window_pref_key -window ${DLPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${DLPane.1} {{left 0} {top 0} {width 314} {height 1160} {dock_state left} {dock_on_new_line true} {child_data_colvariable 249} {child_data_colvalue 80} {child_data_coltype 159} {child_data_col1 0} {child_data_col2 1} {child_data_col3 2}}
set Console.1 [gui_create_window -type Console -parent ${TopLevel.1} -dock_state bottom -dock_on_new_line true -dock_extent 105]
gui_set_window_pref_key -window ${Console.1} -key dock_width -value_type integer -value 2559
gui_set_window_pref_key -window ${Console.1} -key dock_height -value_type integer -value 105
gui_set_window_pref_key -window ${Console.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${Console.1} {{left 0} {top 0} {width 2559} {height 105} {dock_state bottom} {dock_on_new_line true}}
#### Start - Readjusting docked view's offset / size
set dockAreaList { top left right bottom }
foreach dockArea $dockAreaList {
  set viewList [gui_ekki_get_window_ids -active_parent -dock_area $dockArea]
  foreach view $viewList {
      if {[lsearch -exact [gui_get_window_pref_keys -window $view] dock_width] != -1} {
        set dockWidth [gui_get_window_pref_value -window $view -key dock_width]
        set dockHeight [gui_get_window_pref_value -window $view -key dock_height]
        set offset [gui_get_window_pref_value -window $view -key dock_offset]
        if { [string equal "top" $dockArea] || [string equal "bottom" $dockArea]} {
          gui_set_window_attributes -window $view -dock_offset $offset -width $dockWidth
        } else {
          gui_set_window_attributes -window $view -dock_offset $offset -height $dockHeight
        }
      }
  }
}
#### End - Readjusting docked view's offset / size
gui_sync_global -id ${TopLevel.1} -option true

# MDI window settings
set Source.1 [gui_create_window -type {Source}  -parent ${TopLevel.1}]
gui_show_window -window ${Source.1} -show_state maximized
gui_update_layout -id ${Source.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false}}

# End MDI window settings


# Create and position top-level window: TopLevel.2

if {![gui_exist_window -window TopLevel.2]} {
    set TopLevel.2 [ gui_create_window -type TopLevel \
       -icon $::env(DVE)/auxx/gui/images/toolbars/dvewin.xpm] 
} else { 
    set TopLevel.2 TopLevel.2
}
gui_show_window -window ${TopLevel.2} -show_state maximized -rect {{0 66} {2559 1406}}

# ToolBar settings
gui_set_toolbar_attributes -toolbar {TimeOperations} -dock_state top
gui_set_toolbar_attributes -toolbar {TimeOperations} -offset 0
gui_show_toolbar -toolbar {TimeOperations}
gui_hide_toolbar -toolbar {&File}
gui_set_toolbar_attributes -toolbar {&Edit} -dock_state top
gui_set_toolbar_attributes -toolbar {&Edit} -offset 0
gui_show_toolbar -toolbar {&Edit}
gui_hide_toolbar -toolbar {CopyPaste}
gui_set_toolbar_attributes -toolbar {&Trace} -dock_state top
gui_set_toolbar_attributes -toolbar {&Trace} -offset 0
gui_show_toolbar -toolbar {&Trace}
gui_hide_toolbar -toolbar {TraceInstance}
gui_hide_toolbar -toolbar {BackTrace}
gui_set_toolbar_attributes -toolbar {&Scope} -dock_state top
gui_set_toolbar_attributes -toolbar {&Scope} -offset 0
gui_show_toolbar -toolbar {&Scope}
gui_set_toolbar_attributes -toolbar {&Window} -dock_state top
gui_set_toolbar_attributes -toolbar {&Window} -offset 0
gui_show_toolbar -toolbar {&Window}
gui_set_toolbar_attributes -toolbar {Signal} -dock_state top
gui_set_toolbar_attributes -toolbar {Signal} -offset 0
gui_show_toolbar -toolbar {Signal}
gui_set_toolbar_attributes -toolbar {Zoom} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom} -offset 0
gui_show_toolbar -toolbar {Zoom}
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -offset 0
gui_show_toolbar -toolbar {Zoom And Pan History}
gui_set_toolbar_attributes -toolbar {Grid} -dock_state top
gui_set_toolbar_attributes -toolbar {Grid} -offset 0
gui_show_toolbar -toolbar {Grid}
gui_set_toolbar_attributes -toolbar {Simulator} -dock_state top
gui_set_toolbar_attributes -toolbar {Simulator} -offset 0
gui_show_toolbar -toolbar {Simulator}
gui_set_toolbar_attributes -toolbar {Interactive Rewind} -dock_state top
gui_set_toolbar_attributes -toolbar {Interactive Rewind} -offset 0
gui_show_toolbar -toolbar {Interactive Rewind}
gui_set_toolbar_attributes -toolbar {Testbench} -dock_state top
gui_set_toolbar_attributes -toolbar {Testbench} -offset 0
gui_show_toolbar -toolbar {Testbench}

# End ToolBar settings

# Docked window settings
gui_sync_global -id ${TopLevel.2} -option true

# MDI window settings
set Wave.1 [gui_create_window -type {Wave}  -parent ${TopLevel.2}]
gui_show_window -window ${Wave.1} -show_state maximized
gui_update_layout -id ${Wave.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false} {child_wave_left 743} {child_wave_right 1811} {child_wave_colname 369} {child_wave_colvalue 369} {child_wave_col1 0} {child_wave_col2 1}}

# End MDI window settings

gui_set_env TOPLEVELS::TARGET_FRAME(Source) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(Schematic) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(PathSchematic) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(Wave) none
gui_set_env TOPLEVELS::TARGET_FRAME(List) none
gui_set_env TOPLEVELS::TARGET_FRAME(Memory) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(DriverLoad) none
gui_update_statusbar_target_frame ${TopLevel.1}
gui_update_statusbar_target_frame ${TopLevel.2}

#</WindowLayout>

#<Database>

# DVE Open design session: 

if { [llength [lindex [gui_get_db -design Sim] 0]] == 0 } {
gui_set_env SIMSETUP::SIMARGS {{}}
gui_set_env SIMSETUP::SIMEXE {./simv}
gui_set_env SIMSETUP::ALLOW_POLL {0}
if { ![gui_is_db_opened -db {simv}] } {
gui_sim_run Ucli -exe simv -args { -ucligui} -dir ../group5f19 -nosource
}
}
if { ![gui_sim_state -check active] } {error "Simulator did not start correctly" error}
gui_set_precision 100ps
gui_set_time_units 100ps
#</Database>

# DVE Global setting session: 


# Global: Breakpoints

# Global: Bus

# Global: Expressions

# Global: Signal Time Shift

# Global: Signal Compare

# Global: Signal Groups
gui_load_child_values {testbench.core.btb}
gui_load_child_values {testbench.core.c0}
gui_load_child_values {testbench.core.robss}
gui_load_child_values {testbench.core.ssrrat0}
gui_load_child_values {testbench.core.icache_control}
gui_load_child_values {testbench.core.prf0}
gui_load_child_values {testbench.core.sq0}
gui_load_child_values {testbench.core.rf}
gui_load_child_values {testbench.core.rs0}
gui_load_child_values {testbench.core.dcache_control}
gui_load_child_values {testbench.core.predictor}
gui_load_child_values {testbench.core.disp0}
gui_load_child_values {testbench.core.if_stage_0}
gui_load_child_values {testbench.core.vc0}
gui_load_child_values {testbench.core.i0}
gui_load_child_values {testbench.core.ex_out}
gui_load_child_values {testbench.core.fl1}
gui_load_child_values {testbench.core.icache_mem}
gui_load_child_values {testbench.core.mt_ss}
gui_load_child_values {testbench.core.ras1}
gui_load_child_values {testbench.core.r0}
gui_load_child_values {testbench.core.dcache_mem}


set _session_group_1 vc0
gui_sg_create "$_session_group_1"
set vc0 "$_session_group_1"

gui_sg_addsignal -group "$_session_group_1" { testbench.core.vc0.swap_tag testbench.core.vc0.valids testbench.core.vc0.clock testbench.core.vc0.reset testbench.core.vc0.wr_idx testbench.core.vc0.pos testbench.core.vc0.data testbench.core.vc0.rd_valid testbench.core.vc0.wr_en testbench.core.vc0.tags testbench.core.vc0.swap_en testbench.core.vc0.swap_idx testbench.core.vc0.wr_tag testbench.core.vc0.rd_data testbench.core.vc0.swap testbench.core.vc0.index testbench.core.vc0.victim {testbench.core.vc0.$unit} testbench.core.vc0.swap_data testbench.core.vc0.pointers }

set _session_group_2 ssrrat0
gui_sg_create "$_session_group_2"
set ssrrat0 "$_session_group_2"

gui_sg_addsignal -group "$_session_group_2" { testbench.core.ssrrat0.rs2_tag testbench.core.ssrrat0.clock testbench.core.ssrrat0.store_rs2_tag testbench.core.ssrrat0.P_value testbench.core.ssrrat0.reset testbench.core.ssrrat0.rrat_table testbench.core.ssrrat0.retire_en testbench.core.ssrrat0.retire_dest testbench.core.ssrrat0.map_memory testbench.core.ssrrat0.store_rs2 {testbench.core.ssrrat0.$unit} }

set _session_group_3 sq0
gui_sg_create "$_session_group_3"
set sq0 "$_session_group_3"

gui_sg_addsignal -group "$_session_group_3" { testbench.core.sq0.clock testbench.core.sq0.reset testbench.core.sq0.rollback testbench.core.sq0.tags testbench.core.sq0.is_store testbench.core.sq0.is_load testbench.core.sq0.mem_size testbench.core.sq0.cdb testbench.core.sq0.result testbench.core.sq0.load_tags testbench.core.sq0.load_issue testbench.core.sq0.ex_addr testbench.core.sq0.ex_st_tags testbench.core.sq0.mem_size_ex_stage testbench.core.sq0.is_ex_load testbench.core.sq0.retire_en testbench.core.sq0.retire_load testbench.core.sq0.retire_tag testbench.core.sq0.st_value_valid testbench.core.sq0.st_value testbench.core.sq0.load_issue_PC testbench.core.sq0.load_issue_permit testbench.core.sq0.sc_status testbench.core.sq0.s_queue testbench.core.sq0.s_data testbench.core.sq0.s_addr testbench.core.sq0.l_queue testbench.core.sq0.l_pointer testbench.core.sq0.tail testbench.core.sq0.sc_pointer testbench.core.sq0.l_tail testbench.core.sq0.nsc_pointer testbench.core.sq0.counter testbench.core.sq0.counter_two testbench.core.sq0.retire_load_queue testbench.core.sq0.s_queue_busybit testbench.core.sq0.S_queue_mem_size testbench.core.sq0.size_check {testbench.core.sq0.$unit} }

set _session_group_4 rs0
gui_sg_create "$_session_group_4"
set rs0 "$_session_group_4"

gui_sg_addsignal -group "$_session_group_4" { testbench.core.rs0.reset testbench.core.rs0.clock testbench.core.rs0.rollback_en testbench.core.rs0.id_packet testbench.core.rs0.write_true testbench.core.rs0.PA_ready testbench.core.rs0.PB_ready testbench.core.rs0.PA testbench.core.rs0.PB testbench.core.rs0.load_issue_PC testbench.core.rs0.load_issue_permit testbench.core.rs0.free_register testbench.core.rs0.cdb testbench.core.rs0.delete_confirm testbench.core.rs0.ld_in_ex testbench.core.rs0.regA testbench.core.rs0.regB testbench.core.rs0.issue_packet testbench.core.rs0.load_PC testbench.core.rs0.load_issue testbench.core.rs0.full testbench.core.rs0.OBJ testbench.core.rs0.N_OBJ testbench.core.rs0.prev_issue testbench.core.rs0.del testbench.core.rs0.issue_idx testbench.core.rs0.issue_entry testbench.core.rs0.entry_filled testbench.core.rs0.count testbench.core.rs0.count_inst testbench.core.rs0.load_cnt testbench.core.rs0.issue_is_ld {testbench.core.rs0.$unit} }
gui_set_radix -radix {decimal} -signals {Sim:testbench.core.rs0.count}
gui_set_radix -radix {twosComplement} -signals {Sim:testbench.core.rs0.count}

set _session_group_5 robss
gui_sg_create "$_session_group_5"
set robss "$_session_group_5"

gui_sg_addsignal -group "$_session_group_5" { testbench.core.robss.clk testbench.core.robss.reset testbench.core.robss.dispatch_en testbench.core.robss.packet testbench.core.robss.tag_old testbench.core.robss.free_reg testbench.core.robss.retire_en testbench.core.robss.cdb testbench.core.robss.mismatch_en testbench.core.robss.mismatch_tag testbench.core.robss.alu_result testbench.core.robss.dest_reg testbench.core.robss.rob_hazard testbench.core.robss.ready_to_retire testbench.core.robss.retire_entry testbench.core.robss.rollback testbench.core.robss.exception_pc testbench.core.robss.rewind_head testbench.core.robss.Rob_table testbench.core.robss.tail_cntr testbench.core.robss.head_cntr testbench.core.robss.diff testbench.core.robss.tag testbench.core.robss.double_store {testbench.core.robss.$unit} }

set _session_group_6 rf
gui_sg_create "$_session_group_6"
set rf "$_session_group_6"

gui_sg_addsignal -group "$_session_group_6" { testbench.core.rf.wr_clk testbench.core.rf.wr_idx testbench.core.rf.wr_data testbench.core.rf.wr_en testbench.core.rf.registers {testbench.core.rf.$unit} }

set _session_group_7 ras1
gui_sg_create "$_session_group_7"
set ras1 "$_session_group_7"

gui_sg_addsignal -group "$_session_group_7" { testbench.core.ras1.clock testbench.core.ras1.reset testbench.core.ras1.if_packet testbench.core.ras1.is_jump testbench.core.ras1.rollback_en testbench.core.ras1.return_addr testbench.core.ras1.valid_ret_addr testbench.core.ras1.ras testbench.core.ras1.head testbench.core.ras1.push testbench.core.ras1.pop testbench.core.ras1.rpc testbench.core.ras1.link_rd testbench.core.ras1.link_rs1 testbench.core.ras1.requal testbench.core.ras1.link testbench.core.ras1.entry_done {testbench.core.ras1.$unit} }

set _session_group_8 r0
gui_sg_create "$_session_group_8"
set r0 "$_session_group_8"

gui_sg_addsignal -group "$_session_group_8" { testbench.core.r0.clock testbench.core.r0.reset testbench.core.r0.rtr testbench.core.r0.ROB testbench.core.r0.write_enable testbench.core.r0.data_mem testbench.core.r0.store_addr testbench.core.r0.store_data testbench.core.r0.pregold testbench.core.r0.data testbench.core.r0.data_write testbench.core.r0.is_store testbench.core.r0.store_address testbench.core.r0.mem_size testbench.core.r0.store_tag testbench.core.r0.store_rs2 testbench.core.r0.preg testbench.core.r0.dest_reg testbench.core.r0.inst_retire testbench.core.r0.halt testbench.core.r0.alt_tag testbench.core.r0.switch testbench.core.r0.retire_load testbench.core.r0.size_div testbench.core.r0.tstore_data {testbench.core.r0.$unit} }

set _session_group_9 prf0
gui_sg_create "$_session_group_9"
set prf0 "$_session_group_9"

gui_sg_addsignal -group "$_session_group_9" { testbench.core.prf0.clock testbench.core.prf0.reset testbench.core.prf0.PA testbench.core.prf0.PB testbench.core.prf0.tb_reg testbench.core.prf0.cdb testbench.core.prf0.ALU_RESULT testbench.core.prf0.store_tag testbench.core.prf0.retire_tag testbench.core.prf0.store_rs2_tag testbench.core.prf0.store_data testbench.core.prf0.store_tag_value testbench.core.prf0.retire_value testbench.core.prf0.PA_value testbench.core.prf0.PB_value testbench.core.prf0.tb_value testbench.core.prf0.pregisters testbench.core.prf0.done testbench.core.prf0.dones testbench.core.prf0.rda_preg testbench.core.prf0.rdb_preg {testbench.core.prf0.$unit} }

set _session_group_10 predictor
gui_sg_create "$_session_group_10"
set predictor "$_session_group_10"

gui_sg_addsignal -group "$_session_group_10" { testbench.core.predictor.clock testbench.core.predictor.reset testbench.core.predictor.taken testbench.core.predictor.enable testbench.core.predictor.state testbench.core.predictor.prediction testbench.core.predictor.next_prediction testbench.core.predictor.n_state {testbench.core.predictor.$unit} }

set _session_group_11 mt_ss
gui_sg_create "$_session_group_11"
set mt_ss "$_session_group_11"

gui_sg_addsignal -group "$_session_group_11" { testbench.core.mt_ss.reset testbench.core.mt_ss.clock testbench.core.mt_ss.dest_rob testbench.core.mt_ss.rollback_en testbench.core.mt_ss.regA testbench.core.mt_ss.regB testbench.core.mt_ss.dispatch_en testbench.core.mt_ss.cdb testbench.core.mt_ss.free_register testbench.core.mt_ss.rrat_table testbench.core.mt_ss.prev_T testbench.core.mt_ss.PA testbench.core.mt_ss.PB testbench.core.mt_ss.PA_ready testbench.core.mt_ss.PB_ready testbench.core.mt_ss.rmap_memory testbench.core.mt_ss.plus_memory testbench.core.mt_ss.destination {testbench.core.mt_ss.$unit} }

set _session_group_12 if_stage_0
gui_sg_create "$_session_group_12"
set if_stage_0 "$_session_group_12"

gui_sg_addsignal -group "$_session_group_12" { testbench.core.if_stage_0.clock testbench.core.if_stage_0.reset testbench.core.if_stage_0.Imem2proc_data testbench.core.if_stage_0.Imem2proc_valid testbench.core.if_stage_0.rs_rob_hazard testbench.core.if_stage_0.return_addr testbench.core.if_stage_0.ret_valid testbench.core.if_stage_0.haz_enable testbench.core.if_stage_0.T_PC testbench.core.if_stage_0.hit testbench.core.if_stage_0.rollback testbench.core.if_stage_0.exception_pc testbench.core.if_stage_0.proc2Imem_addr testbench.core.if_stage_0.if_packet_out testbench.core.if_stage_0.is_branch testbench.core.if_stage_0.is_jump testbench.core.if_stage_0.PC2btb testbench.core.if_stage_0.PC_reg testbench.core.if_stage_0.PC_plus_2width testbench.core.if_stage_0.next_PC testbench.core.if_stage_0.PC_enable testbench.core.if_stage_0.done testbench.core.if_stage_0.ret_val testbench.core.if_stage_0.ret_add {testbench.core.if_stage_0.$unit} }

set _session_group_13 icache_mem
gui_sg_create "$_session_group_13"
set icache_mem "$_session_group_13"

gui_sg_addsignal -group "$_session_group_13" { testbench.core.icache_mem.clock testbench.core.icache_mem.reset testbench.core.icache_mem.wr1_en testbench.core.icache_mem.wr1_idx testbench.core.icache_mem.rd1_idx testbench.core.icache_mem.wr1_tag testbench.core.icache_mem.rd1_tag testbench.core.icache_mem.wr1_data testbench.core.icache_mem.rd1_data testbench.core.icache_mem.rd1_valid testbench.core.icache_mem.vc_en testbench.core.icache_mem.swap_en testbench.core.icache_mem.vc_idx testbench.core.icache_mem.swap_idx testbench.core.icache_mem.vc_tag testbench.core.icache_mem.swap_tag testbench.core.icache_mem.vc_write testbench.core.icache_mem.swap_data testbench.core.icache_mem.vc_data testbench.core.icache_mem.vc_valid testbench.core.icache_mem.prev_tag testbench.core.icache_mem.data testbench.core.icache_mem.tags testbench.core.icache_mem.valids {testbench.core.icache_mem.$unit} }

set _session_group_14 icache_control
gui_sg_create "$_session_group_14"
set icache_control "$_session_group_14"

gui_sg_addsignal -group "$_session_group_14" { testbench.core.icache_control.clock testbench.core.icache_control.reset testbench.core.icache_control.Imem2proc_response testbench.core.icache_control.Imem2proc_data testbench.core.icache_control.Imem2proc_tag testbench.core.icache_control.hazard testbench.core.icache_control.proc2Icache_addr testbench.core.icache_control.cachemem_data testbench.core.icache_control.cachemem_valid testbench.core.icache_control.proc2Imem_command testbench.core.icache_control.proc2Imem_addr testbench.core.icache_control.Icache_data_out testbench.core.icache_control.Icache_valid_out testbench.core.icache_control.current_index testbench.core.icache_control.current_tag testbench.core.icache_control.last_index testbench.core.icache_control.last_tag testbench.core.icache_control.data_write_enable testbench.core.icache_control.haz_enable testbench.core.icache_control.current_mem_tag testbench.core.icache_control.ins_left testbench.core.icache_control.miss_outstanding testbench.core.icache_control.changed_addr testbench.core.icache_control.send_request testbench.core.icache_control.update_mem_tag testbench.core.icache_control.unanswered_miss {testbench.core.icache_control.$unit} }

set _session_group_15 i0
gui_sg_create "$_session_group_15"
set i0 "$_session_group_15"

gui_sg_addsignal -group "$_session_group_15" { testbench.core.i0.clock testbench.core.i0.reset testbench.core.i0.rollback_en testbench.core.i0.issue_packet testbench.core.i0.ld_in_ex testbench.core.i0.data_input testbench.core.i0.stall_ALU testbench.core.i0.FU_unit_ALU testbench.core.i0.FU_unit_mul testbench.core.i0.ex_packet testbench.core.i0.delete_confirm testbench.core.i0.a testbench.core.i0.b testbench.core.i0.c {testbench.core.i0.$unit} }

set _session_group_16 fl1
gui_sg_create "$_session_group_16"
set fl1 "$_session_group_16"

gui_sg_addsignal -group "$_session_group_16" { testbench.core.fl1.clock testbench.core.fl1.reset testbench.core.fl1.rollback_en testbench.core.fl1.rewind_head testbench.core.fl1.dispatch_en testbench.core.fl1.retire_en testbench.core.fl1.retire_reg testbench.core.fl1.free_reg testbench.core.fl1.freeregisters testbench.core.fl1.n_fl testbench.core.fl1.head testbench.core.fl1.tail testbench.core.fl1.next_head testbench.core.fl1.next_tail {testbench.core.fl1.$unit} }

set _session_group_17 ex_out
gui_sg_create "$_session_group_17"
set ex_out "$_session_group_17"

gui_sg_addsignal -group "$_session_group_17" { testbench.core.ex_out.clock testbench.core.ex_out.reset testbench.core.ex_out.rollback testbench.core.ex_out.FU_unit_ALU testbench.core.ex_out.FU_unit_mul testbench.core.ex_out.ex_packet testbench.core.ex_out.PA_value testbench.core.ex_out.PB_value testbench.core.ex_out.complete_packet testbench.core.ex_out.execution_done testbench.core.ex_out.ALU_stall testbench.core.ex_out.PA testbench.core.ex_out.PB testbench.core.ex_out.st_value_valid testbench.core.ex_out.st_value testbench.core.ex_out.retire_store testbench.core.ex_out.retire_store_address testbench.core.ex_out.retire_store_size testbench.core.ex_out.temp_taken testbench.core.ex_out.take_branch testbench.core.ex_out.PC testbench.core.ex_out.tag testbench.core.ex_out.target testbench.core.ex_out.rob_result testbench.core.ex_out.mem_data testbench.core.ex_out.mem_data_valid testbench.core.ex_out.proc2dcache_command testbench.core.ex_out.load_present testbench.core.ex_out.proc2dcache_addr testbench.core.ex_out.ex_addr testbench.core.ex_out.ex_st_PC testbench.core.ex_out.is_ex_load testbench.core.ex_out.mem_size testbench.core.ex_out.result testbench.core.ex_out.result_store testbench.core.ex_out.store_buffer testbench.core.ex_out.retire_store_index testbench.core.ex_out.retire_store_tag testbench.core.ex_out.result_mul testbench.core.ex_out.tresult_add testbench.core.ex_out.result_add testbench.core.ex_out.done_mul testbench.core.ex_out.done_alu testbench.core.ex_out.done_lsu testbench.core.ex_out.func testbench.core.ex_out.result_mul2 testbench.core.ex_out.result_mul1 testbench.core.ex_out.done_mul2 testbench.core.ex_out.done_mul1 testbench.core.ex_out.mem_result_out testbench.core.ex_out.opa_mux_out testbench.core.ex_out.opb_mux_out testbench.core.ex_out.brcond_result testbench.core.ex_out.branch testbench.core.ex_out.tag_out testbench.core.ex_out.tag1 testbench.core.ex_out.tag2 testbench.core.ex_out.ld_location testbench.core.ex_out.true_PB_value testbench.core.ex_out.true_PA_value testbench.core.ex_out.mux_mem_data testbench.core.ex_out.mem_sizes testbench.core.ex_out.is_store testbench.core.ex_out.store_mem_size testbench.core.ex_out.store_index testbench.core.ex_out.store_tag testbench.core.ex_out.load_idx testbench.core.ex_out.load_tag testbench.core.ex_out.tempproc_command testbench.core.ex_out.tempproc_addr {testbench.core.ex_out.$unit} }

set _session_group_18 disp0
gui_sg_create "$_session_group_18"
set disp0 "$_session_group_18"

gui_sg_addsignal -group "$_session_group_18" { testbench.core.disp0.clock testbench.core.disp0.reset testbench.core.disp0.if_id_packet_in testbench.core.disp0.ROB_hazard testbench.core.disp0.RS_hazard testbench.core.disp0.disp_packet_out testbench.core.disp0.dispatch_en testbench.core.disp0.is_store testbench.core.disp0.is_load testbench.core.disp0.disp_mem_size testbench.core.disp0.dest_reg_select testbench.core.disp0.valid_inst {testbench.core.disp0.$unit} }

set _session_group_19 dcache_mem
gui_sg_create "$_session_group_19"
set dcache_mem "$_session_group_19"

gui_sg_addsignal -group "$_session_group_19" { testbench.core.dcache_mem.clock testbench.core.dcache_mem.reset testbench.core.dcache_mem.wr1_en testbench.core.dcache_mem.st_wr_en testbench.core.dcache_mem.st_addr testbench.core.dcache_mem.st_wr_data testbench.core.dcache_mem.wr1_idx testbench.core.dcache_mem.rd1_idx testbench.core.dcache_mem.wr1_tag testbench.core.dcache_mem.rd1_tag testbench.core.dcache_mem.wr1_data testbench.core.dcache_mem.rd1_data testbench.core.dcache_mem.rd1_valid testbench.core.dcache_mem.st_wr_idx testbench.core.dcache_mem.st_wr_tag testbench.core.dcache_mem.data testbench.core.dcache_mem.tags testbench.core.dcache_mem.valids testbench.core.dcache_mem.cache_valid {testbench.core.dcache_mem.$unit} }

set _session_group_20 dcache_control
gui_sg_create "$_session_group_20"
set dcache_control "$_session_group_20"

gui_sg_addsignal -group "$_session_group_20" { testbench.core.dcache_control.clock testbench.core.dcache_control.reset testbench.core.dcache_control.st_en testbench.core.dcache_control.st_addr testbench.core.dcache_control.st_data testbench.core.dcache_control.st_mem_size testbench.core.dcache_control.ex_mem_size testbench.core.dcache_control.sproc2Dcache_addr testbench.core.dcache_control.cache_enable testbench.core.dcache_control.ldproc2Dmem_command testbench.core.dcache_control.Dmem2proc_response testbench.core.dcache_control.Dmem2proc_data testbench.core.dcache_control.Dmem2proc_tag testbench.core.dcache_control.cachemem_valid testbench.core.dcache_control.cachemem_data testbench.core.dcache_control.Dcache_data_out testbench.core.dcache_control.Dcache_valid_out testbench.core.dcache_control.proc2Dmem_command testbench.core.dcache_control.proc2Dmem_addr testbench.core.dcache_control.current_index testbench.core.dcache_control.current_tag testbench.core.dcache_control.last_index testbench.core.dcache_control.last_tag testbench.core.dcache_control.data_write_enable testbench.core.dcache_control.rd_size testbench.core.dcache_control.write_enable testbench.core.dcache_control.size_div testbench.core.dcache_control.sproc2Dmem_command testbench.core.dcache_control.proc2Dcache_addr testbench.core.dcache_control.current_mem_tag testbench.core.dcache_control.miss_outstanding testbench.core.dcache_control.changed_addr testbench.core.dcache_control.send_request testbench.core.dcache_control.update_mem_tag testbench.core.dcache_control.unanswered_miss {testbench.core.dcache_control.$unit} }

set _session_group_21 c0
gui_sg_create "$_session_group_21"
set c0 "$_session_group_21"

gui_sg_addsignal -group "$_session_group_21" { testbench.core.c0.clock testbench.core.c0.reset testbench.core.c0.rollback_en testbench.core.c0.ex_complete_packet testbench.core.c0.execution_complete testbench.core.c0.cdb testbench.core.c0.result {testbench.core.c0.$unit} }

set _session_group_22 btb
gui_sg_create "$_session_group_22"
set btb "$_session_group_22"

gui_sg_addsignal -group "$_session_group_22" { testbench.core.btb.EX_TARGET testbench.core.btb.PC testbench.core.btb.mismatch testbench.core.btb.clock testbench.core.btb.head testbench.core.btb.reset testbench.core.btb.ROB_tag testbench.core.btb.EX_tag testbench.core.btb.buf_obj testbench.core.btb.T_PC testbench.core.btb.take_branch testbench.core.btb.combined testbench.core.btb.EX_PC testbench.core.btb.hit testbench.core.btb.is_jump testbench.core.btb.curr_state {testbench.core.btb.$unit} testbench.core.btb.is_branch }

# Global: Highlighting

# Global: Stack
gui_change_stack_mode -mode list

# Post database loading setting...

# Restore C1 time
gui_set_time -C1_only 32520



# Save global setting...

# Wave/List view global setting
gui_cov_show_value -switch false

# Close all empty TopLevel windows
foreach __top [gui_ekki_get_window_ids -type TopLevel] {
    if { [llength [gui_ekki_get_window_ids -parent $__top]] == 0} {
        gui_close_window -window $__top
    }
}
gui_set_loading_session_type noSession
# DVE View/pane content session: 


# Hier 'Hier.1'
gui_show_window -window ${Hier.1}
gui_list_set_filter -id ${Hier.1} -list { {Package 1} {All 0} {Process 1} {VirtPowSwitch 0} {UnnamedProcess 1} {UDP 0} {Function 1} {Block 1} {SrsnAndSpaCell 0} {OVA Unit 1} {LeafScCell 1} {LeafVlgCell 1} {Interface 1} {LeafVhdCell 1} {$unit 1} {NamedBlock 1} {Task 1} {VlgPackage 1} {ClassDef 1} {VirtIsoCell 0} }
gui_list_set_filter -id ${Hier.1} -text {*}
gui_hier_list_init -id ${Hier.1}
gui_change_design -id ${Hier.1} -design Sim
catch {gui_list_expand -id ${Hier.1} testbench}
catch {gui_list_expand -id ${Hier.1} testbench.core}
catch {gui_list_select -id ${Hier.1} {testbench.core.vc0}}
gui_view_scroll -id ${Hier.1} -vertical -set 0
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Data 'Data.1'
gui_list_set_filter -id ${Data.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {LowPower 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Data.1} -text {*}
gui_list_show_data -id ${Data.1} {testbench.core.vc0}
gui_view_scroll -id ${Data.1} -vertical -set 0
gui_view_scroll -id ${Data.1} -horizontal -set 0
gui_view_scroll -id ${Hier.1} -vertical -set 0
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Source 'Source.1'
gui_src_value_annotate -id ${Source.1} -switch false
gui_set_env TOGGLE::VALUEANNOTATE 0
gui_open_source -id ${Source.1}  -replace -active _vcs_unit__358072738 sys_defs.svh
gui_view_scroll -id ${Source.1} -vertical -set 0
gui_src_set_reusable -id ${Source.1}

# View 'Wave.1'
gui_wv_sync -id ${Wave.1} -switch false
set groupExD [gui_get_pref_value -category Wave -key exclusiveSG]
gui_set_pref_value -category Wave -key exclusiveSG -value {false}
set origWaveHeight [gui_get_pref_value -category Wave -key waveRowHeight]
gui_list_set_height -id Wave -height 25
set origGroupCreationState [gui_list_create_group_when_add -wave]
gui_list_create_group_when_add -wave -disable
gui_marker_set_ref -id ${Wave.1}  C1
gui_wv_zoom_timerange -id ${Wave.1} 0 32520
gui_list_add_group -id ${Wave.1} -after {New Group} {vc0}
gui_list_add_group -id ${Wave.1} -after {New Group} {ssrrat0}
gui_list_add_group -id ${Wave.1} -after {New Group} {sq0}
gui_list_add_group -id ${Wave.1} -after {New Group} {rs0}
gui_list_add_group -id ${Wave.1} -after {New Group} {robss}
gui_list_add_group -id ${Wave.1} -after {New Group} {rf}
gui_list_add_group -id ${Wave.1} -after {New Group} {ras1}
gui_list_add_group -id ${Wave.1} -after {New Group} {r0}
gui_list_add_group -id ${Wave.1} -after {New Group} {prf0}
gui_list_add_group -id ${Wave.1} -after {New Group} {predictor}
gui_list_add_group -id ${Wave.1} -after {New Group} {mt_ss}
gui_list_add_group -id ${Wave.1} -after {New Group} {if_stage_0}
gui_list_add_group -id ${Wave.1} -after {New Group} {icache_mem}
gui_list_add_group -id ${Wave.1} -after {New Group} {icache_control}
gui_list_add_group -id ${Wave.1} -after {New Group} {i0}
gui_list_add_group -id ${Wave.1} -after {New Group} {fl1}
gui_list_add_group -id ${Wave.1} -after {New Group} {ex_out}
gui_list_add_group -id ${Wave.1} -after {New Group} {disp0}
gui_list_add_group -id ${Wave.1} -after {New Group} {dcache_mem}
gui_list_add_group -id ${Wave.1} -after {New Group} {dcache_control}
gui_list_add_group -id ${Wave.1} -after {New Group} {c0}
gui_list_add_group -id ${Wave.1} -after {New Group} {btb}
gui_list_collapse -id ${Wave.1} vc0
gui_list_collapse -id ${Wave.1} ssrrat0
gui_list_collapse -id ${Wave.1} sq0
gui_list_collapse -id ${Wave.1} rs0
gui_list_collapse -id ${Wave.1} robss
gui_list_collapse -id ${Wave.1} rf
gui_list_collapse -id ${Wave.1} ras1
gui_list_collapse -id ${Wave.1} r0
gui_list_collapse -id ${Wave.1} prf0
gui_list_collapse -id ${Wave.1} predictor
gui_list_collapse -id ${Wave.1} mt_ss
gui_list_collapse -id ${Wave.1} if_stage_0
gui_list_collapse -id ${Wave.1} icache_mem
gui_list_collapse -id ${Wave.1} icache_control
gui_list_collapse -id ${Wave.1} i0
gui_list_collapse -id ${Wave.1} fl1
gui_list_collapse -id ${Wave.1} ex_out
gui_list_collapse -id ${Wave.1} disp0
gui_list_collapse -id ${Wave.1} dcache_mem
gui_list_collapse -id ${Wave.1} dcache_control
gui_list_collapse -id ${Wave.1} c0
gui_list_select -id ${Wave.1} {testbench.core.btb.mismatch }
gui_seek_criteria -id ${Wave.1} {Any Edge}



gui_set_env TOGGLE::DEFAULT_WAVE_WINDOW ${Wave.1}
gui_set_pref_value -category Wave -key exclusiveSG -value $groupExD
gui_list_set_height -id Wave -height $origWaveHeight
if {$origGroupCreationState} {
	gui_list_create_group_when_add -wave -enable
}
if { $groupExD } {
 gui_msg_report -code DVWW028
}
gui_list_set_filter -id ${Wave.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Wave.1} -text {*}
gui_list_set_insertion_bar  -id ${Wave.1} -group btb  -position in

gui_marker_move -id ${Wave.1} {C1} 32520
gui_view_scroll -id ${Wave.1} -vertical -set 0
gui_show_grid -id ${Wave.1} -enable false
# Restore toplevel window zorder
# The toplevel window could be closed if it has no view/pane
if {[gui_exist_window -window ${TopLevel.1}]} {
	gui_set_active_window -window ${TopLevel.1}
	gui_set_active_window -window ${Source.1}
	gui_set_active_window -window ${HSPane.1}
}
if {[gui_exist_window -window ${TopLevel.2}]} {
	gui_set_active_window -window ${TopLevel.2}
	gui_set_active_window -window ${Wave.1}
}
#</Session>

