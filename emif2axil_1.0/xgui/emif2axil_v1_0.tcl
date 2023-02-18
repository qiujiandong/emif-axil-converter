# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  #Adding Group
  set AXI-l [ipgui::add_group $IPINST -name "AXI-l" -parent ${Page_0} -display_name {AXI-lite Base Address}]
  set_property tooltip {AXI-lite Base Address} ${AXI-l}
  ipgui::add_static_text $IPINST -name "AXI-lite base address" -parent ${AXI-l} -text {The base address of AXI-lite}
  ipgui::add_param $IPINST -name "AXIL_ADDR_BASE" -parent ${AXI-l}

  #Adding Group
  set AXI-lite_Space_Size [ipgui::add_group $IPINST -name "AXI-lite Space Size" -parent ${Page_0}]
  set_property tooltip {AXI-lite Space Size} ${AXI-lite_Space_Size}
  ipgui::add_static_text $IPINST -name "AXI-lite Addr Base" -parent ${AXI-lite_Space_Size} -text {The actual space size can be accessed by AXI-lite

eg. Addr Width = 16 for AXI-lite space is 64kB

Note: The max width is 25 (32MB) 
}
  ipgui::add_param $IPINST -name "AXIL_ADDR_WIDTH" -parent ${AXI-lite_Space_Size}

  #Adding Group
  set EMIF_Base_Address [ipgui::add_group $IPINST -name "EMIF Base Address" -parent ${Page_0}]
  set_property tooltip {EMIF Base Address} ${EMIF_Base_Address}
  ipgui::add_static_text $IPINST -name "EBA_Text" -parent ${EMIF_Base_Address} -text {Note: The Uint of Emif Addr Width is Words, but not Bytes! 

The lowest N-1 bits of EMIF Base Address must be zero. 

eg. AXI-lite Address Width is 25, and all 24 bits must be zero

AXI-lite Address Width is 16, and the lowest 15 bits must be zero}
  ipgui::add_param $IPINST -name "EMIF_ADDR_BASE" -parent ${EMIF_Base_Address}



}

proc update_PARAM_VALUE.AXIL_ADDR_BASE { PARAM_VALUE.AXIL_ADDR_BASE } {
	# Procedure called to update AXIL_ADDR_BASE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXIL_ADDR_BASE { PARAM_VALUE.AXIL_ADDR_BASE } {
	# Procedure called to validate AXIL_ADDR_BASE
	return true
}

proc update_PARAM_VALUE.AXIL_ADDR_WIDTH { PARAM_VALUE.AXIL_ADDR_WIDTH } {
	# Procedure called to update AXIL_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXIL_ADDR_WIDTH { PARAM_VALUE.AXIL_ADDR_WIDTH } {
	# Procedure called to validate AXIL_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.EMIF_ADDR_BASE { PARAM_VALUE.EMIF_ADDR_BASE } {
	# Procedure called to update EMIF_ADDR_BASE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.EMIF_ADDR_BASE { PARAM_VALUE.EMIF_ADDR_BASE } {
	# Procedure called to validate EMIF_ADDR_BASE
	return true
}


proc update_MODELPARAM_VALUE.AXIL_DW { MODELPARAM_VALUE.AXIL_DW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	# WARNING: There is no corresponding user parameter named "AXIL_DW". Setting updated value from the model parameter.
set_property value 32 ${MODELPARAM_VALUE.AXIL_DW}
}

proc update_MODELPARAM_VALUE.AXIL_AW { MODELPARAM_VALUE.AXIL_AW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	# WARNING: There is no corresponding user parameter named "AXIL_AW". Setting updated value from the model parameter.
set_property value 4 ${MODELPARAM_VALUE.AXIL_AW}
}

proc update_MODELPARAM_VALUE.AXIL_ADDR_BASE { MODELPARAM_VALUE.AXIL_ADDR_BASE PARAM_VALUE.AXIL_ADDR_BASE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXIL_ADDR_BASE}] ${MODELPARAM_VALUE.AXIL_ADDR_BASE}
}

proc update_MODELPARAM_VALUE.AXIL_ADDR_WIDTH { MODELPARAM_VALUE.AXIL_ADDR_WIDTH PARAM_VALUE.AXIL_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXIL_ADDR_WIDTH}] ${MODELPARAM_VALUE.AXIL_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.EMIF_ADDR_BASE { MODELPARAM_VALUE.EMIF_ADDR_BASE PARAM_VALUE.EMIF_ADDR_BASE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.EMIF_ADDR_BASE}] ${MODELPARAM_VALUE.EMIF_ADDR_BASE}
}

