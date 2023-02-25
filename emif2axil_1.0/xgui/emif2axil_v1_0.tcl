# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "AXIL_ADDR_BASE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "AXIL_ADDR_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "EMIF_ADDR_BASE" -parent ${Page_0}


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

proc update_PARAM_VALUE.AXIL_DW { PARAM_VALUE.AXIL_DW } {
	# Procedure called to update AXIL_DW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXIL_DW { PARAM_VALUE.AXIL_DW } {
	# Procedure called to validate AXIL_DW
	return true
}

proc update_PARAM_VALUE.EMIF_ADDR_BASE { PARAM_VALUE.EMIF_ADDR_BASE } {
	# Procedure called to update EMIF_ADDR_BASE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.EMIF_ADDR_BASE { PARAM_VALUE.EMIF_ADDR_BASE } {
	# Procedure called to validate EMIF_ADDR_BASE
	return true
}


proc update_MODELPARAM_VALUE.AXIL_DW { MODELPARAM_VALUE.AXIL_DW PARAM_VALUE.AXIL_DW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXIL_DW}] ${MODELPARAM_VALUE.AXIL_DW}
}

proc update_MODELPARAM_VALUE.EMIF_ADDR_BASE { MODELPARAM_VALUE.EMIF_ADDR_BASE PARAM_VALUE.EMIF_ADDR_BASE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.EMIF_ADDR_BASE}] ${MODELPARAM_VALUE.EMIF_ADDR_BASE}
}

proc update_MODELPARAM_VALUE.AXIL_ADDR_BASE { MODELPARAM_VALUE.AXIL_ADDR_BASE PARAM_VALUE.AXIL_ADDR_BASE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXIL_ADDR_BASE}] ${MODELPARAM_VALUE.AXIL_ADDR_BASE}
}

proc update_MODELPARAM_VALUE.AXIL_ADDR_WIDTH { MODELPARAM_VALUE.AXIL_ADDR_WIDTH PARAM_VALUE.AXIL_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXIL_ADDR_WIDTH}] ${MODELPARAM_VALUE.AXIL_ADDR_WIDTH}
}

