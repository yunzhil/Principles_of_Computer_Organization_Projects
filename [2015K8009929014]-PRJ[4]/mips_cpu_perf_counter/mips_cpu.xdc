create_clock -period 20 -name clk -waveform {0 10} [get_ports mips_cpu_clk]

set_property IOSTANDARD LVCMOS18 [get_ports mips_cpu_clk]
set_property package_pin D18 [get_ports mips_cpu_clk]

set_property IOSTANDARD LVCMOS18 [get_ports mips_cpu_reset]
set_property package_pin F16 [get_ports mips_cpu_reset]

set_property IOSTANDARD LVCMOS18 [get_ports mips_cpu_pc_sig]
set_property package_pin D16 [get_ports mips_cpu_pc_sig]

set_property IOSTANDARD LVCMOS18 [get_ports mips_cpu_perf_sig]
set_property package_pin G16 [get_ports mips_cpu_perf_sig]
