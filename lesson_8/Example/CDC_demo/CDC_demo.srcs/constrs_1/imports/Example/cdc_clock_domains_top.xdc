## cdc_clock_domains_top.xdc
## Generic (not board-specific) constraints for exploring Report
## Clock Networks and Report Clock Interaction, per the lecture's
## set_false_path technique (session 8, part 4).
##
## Periods deliberately COPRIME (10ns and 33ns -- GCD=1) so the two
## domains genuinely drift in phase relative to each other, unlike
## simple multiples (e.g. 10ns/30ns) which freeze into one fixed
## relationship after the first cycle.

create_clock -period 10.000 -name clk_a [get_ports clk_a]
create_clock -period 33.000 -name clk_b [get_ports clk_b]

## The actual CDC crossing (tick_a_toggle -> cdc_sync's internal
## sync_stage1) is deliberately asynchronous. Without this line,
## Vivado would try normal Setup/Hold analysis between clk_a and
## clk_b on this path -- meaningless for a genuinely async crossing.
set_false_path -from [get_pins u_sync/enable_a] -to [get_pins u_sync/sync_stage1_reg/D]

## No PACKAGE_PIN/IOSTANDARD needed -- this is for synthesis +
## exploring the clock reports, not a real board deployment.
