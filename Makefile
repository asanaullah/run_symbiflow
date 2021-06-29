SYMBIFLOW_DIR=./symbiflow-arch-defs
VERILOG_FILE=test
SYNTH_SCRIPTS_DIR=synth_scripts
DEVICE=xc7a50t-arty-swbut-test
DEVICE_FAMILY=artix7
PART=xc7a50tfgg484-1
DEVICE_FILE_DIR=./${DEVICE_FAMILY}
TECHMAP_DIR = ${SYMBIFLOW_DIR}/xc/xc7/techmap
YOSYS=${SYMBIFLOW_DIR}/env/conda/envs/symbiflow_arch_def_base/bin/yosys
VPR=${SYMBIFLOW_DIR}/env/conda/envs/symbiflow_arch_def_base/bin/vpr
CMAKE=${SYMBIFLOW_DIR}/env/conda/envs/symbiflow_arch_def_base/bin/cmake
VPR_FLAGS= --echo_file on --graphics_commands "save_graphics temp.png" --disp on --save_graphics on --max_router_iterations 500 --routing_failure_predictor off --router_high_fanout_threshold -1 --constant_net_method route --route_chan_width 500 --router_heap bucket --clock_modeling route --place_delta_delay_matrix_calculation_method dijkstra --place_delay_model delta --router_lookahead extended_map --check_route quick --strict_checks off --allow_dangling_combinational_nodes on --disable_errors check_unbuffered_edges:check_route --congested_routing_iteration_threshold 0.8 --incremental_reroute_delay_ripup off --base_cost_type delay_normalized_length_bounded --bb_factor 10 --acc_fac 0.7 --astar_fac 1.8 --initial_pres_fac 2.828 --pres_fac_mult 1.2 --check_rr_graph off --suppress_warnings noisy_warnings.log,sum_pin_class:check_unbuffered_edges:load_rr_indexed_data_T_values:check_rr_node:trans_per_R:check_route:set_rr_graph_tool_comment:calculate_average_switch

.PHONY: all 
all: build_symbiflow extract_device_graph synth pack constrain place route

.PHONY: route
route :  ${VERILOG_FILE}.route

.PHONY: place
place: ${VERILOG_FILE}.place 

.PHONY: constrain
constrain: ${VERILOG_FILE}_constraints.place 

.PHONY: pack 	
pack: ${VERILOG_FILE}.net

.PHONY: synth
synth: ${VERILOG_FILE}.eblif

.PHONY: extract_device_graph
extract_device_graph: ${DEVICE_FILE_DIR}/rr_graph_real.bin

.PHONY: build_symbiflow

build_symbiflow:
	if [ -d "${SYMBIFLOW_DIR}/build" ]; then echo "Symbiflow build directory already exists - skipping"; else cd ${SYMBIFLOW_DIR} && make env; fi

${DEVICE_FILE_DIR}/rr_graph_real.bin: 
	if [ -d "${DEVICE_FILE_DIR}" ]; then echo "Device files already extracted - skipping"; else mkdir ${DEVICE_FILE_DIR} && tar -xvf ${DEVICE_FAMILY}.tar.xz -C ${DEVICE_FILE_DIR}; fi

${VERILOG_FILE}.route: ${VERILOG_FILE}.place
	${VPR} ${DEVICE_FILE_DIR}/arch.timing.xml ${VERILOG_FILE}.eblif --device ${DEVICE} --read_rr_graph ${DEVICE_FILE_DIR}/rr_graph_real.bin  --read_router_lookahead ${DEVICE_FILE_DIR}/rr_graph_lookahead.bin --read_placement_delay_lookup ${DEVICE_FILE_DIR}/rr_graph_place_delay.bin --place_file $< ${VPR_FLAGS} --route


${VERILOG_FILE}.place: ${VERILOG_FILE}_constraints.place
	${VPR} ${DEVICE_FILE_DIR}/arch.timing.xml ${VERILOG_FILE}.eblif --device ${DEVICE} --read_rr_graph ${DEVICE_FILE_DIR}/rr_graph_real.bin --read_router_lookahead ${DEVICE_FILE_DIR}/rr_graph_lookahead.bin --read_placement_delay_lookup ${DEVICE_FILE_DIR}/rr_graph_place_delay.bin  --fix_clusters $< ${VPR_FLAGS} --net_file ${VERILOG_FILE}.net --place


${VERILOG_FILE}_constraints.place: ${VERILOG_FILE}.net
	${CMAKE} -E env PYTHONPATH=${SYMBIFLOW_DIR}/utils ${SYMBIFLOW_DIR}/env/conda/envs/symbiflow_arch_def_base/bin/python3 ${SYMBIFLOW_DIR}/xc/common/utils/prjxray_create_ioplace.py --map ${DEVICE_FILE_DIR}/pinmap.csv --blif ${VERILOG_FILE}.eblif --pcf ${DEVICE_FILE_DIR}/${DEVICE_FAMILY}.pcf --net $< --out ${VERILOG_FILE}_io.place
	${CMAKE} -E env  PYTHONPATH=${SYMBIFLOW_DIR}/utils ${SYMBIFLOW_DIR}/env/conda/envs/symbiflow_arch_def_base/bin/python3 ${SYMBIFLOW_DIR}/xc/common/utils/prjxray_create_place_constraints.py --net $< --arch ${DEVICE_FILE_DIR}/arch.timing.xml --blif ${VERILOG_FILE}.eblif --input /dev/stdin --output /dev/stdout --db_root ${SYMBIFLOW_DIR}/env/conda/envs/symbiflow_arch_def_base/share/symbiflow/prjxray-db --part ${PART} --vpr_grid_map ${DEVICE_FILE_DIR}/gridmap.csv --roi < ${VERILOG_FILE}_io.place > ${VERILOG_FILE}_constraints.place
	${CMAKE} -E env  PYTHONPATH=${SYMBIFLOW_DIR}/utils ${SYMBIFLOW_DIR}/env/conda/envs/symbiflow_arch_def_base/bin/python3 ${SYMBIFLOW_DIR}/xc/common/utils/prjxray_create_ioplace.py --map ${DEVICE_FILE_DIR}/pinmap.csv --blif ${VERILOG_FILE}.eblif --pcf ${DEVICE_FILE_DIR}/${DEVICE_FAMILY}.pcf --net $< --out ${VERILOG_FILE}_io.place

${VERILOG_FILE}.net: ${VERILOG_FILE}.eblif	
	${VPR} ${DEVICE_FILE_DIR}/arch.timing.xml $< --device ${DEVICE} --read_rr_graph ${DEVICE_FILE_DIR}/rr_graph_real.bin --read_router_lookahead ${DEVICE_FILE_DIR}/rr_graph_lookahead.bin --read_placement_delay_lookup ${DEVICE_FILE_DIR}/rr_graph_place_delay.bin  ${VPR_FLAGS} --pack


${VERILOG_FILE}.eblif:${VERILOG_FILE}.json
	${CMAKE} -E env symbiflow-arch-defs_SOURCE_DIR=${SYMBIFLOW_DIR} OUT_EBLIF=$@ ${YOSYS} -p "read_json $<; tcl ${SYNTH_SCRIPTS_DIR}/conv.tcl"

${VERILOG_FILE}.json:  ${VERILOG_FILE}_synth.json
	python3 ${SYMBIFLOW_DIR}/utils/split_inouts.py -i $< -o $@

${VERILOG_FILE}_synth.json: 
	${CMAKE} -E env TECHMAP_PATH=${TECHMAP_DIR} UTILS_PATH=${SYMBIFLOW_DIR}/utils DEVICE_CELLS_SIM= DEVICE_CELLS_MAP= OUT_JSON=$@ OUT_SYNTH_V=${VERILOG_FILE}_synth.v OUT_FASM_EXTRA=${VERILOG_FILE}_fasm_extra.fasm PART_JSON= INPUT_XDC_FILES= OUT_SDC=${VERILOG_FILE}_synth.sdc USE_ROI=TRUE PCF_FILE=${DEVICE_FILE_DIR}/${DEVICE_FAMILY}.pcf PINMAP_FILE=${DEVICE_FILE_DIR}/pinmap.csv PYTHON3=python3 ${YOSYS} -p "tcl ${SYNTH_SCRIPTS_DIR}/synth.tcl" ${VERILOG_FILE}.v
	
	
	
clean:
	- rm *.json
	- rm *.sdc
	- rm *.eblif
	- rm *.ilang
	- rm *premap.v
	- rm *_synth.v	
	- rm *.rpt
	- rm *.log
	- rm *.net
	- rm *.place
	- rm *.route
	- rm *.bit
	- rm *.post_routing
	- rm *.echo
	- rm *.blif
	- rm *.dot
	- rm *.fasm
