## Run_Symbiflow: Simplified execution for Symbiflow

Build steps: 

 - Clone the repository using ```git clone --recursive https://github.com/asanaullah/run_symbiflow```
 - Change directory ```cd run_symbiflow```
 - Set the XRAY_VIVADO_SETTINGS environment variable to point to settings64.sh in Vivado
 - Run ```make all```. This will build Symbiflow, extract device files, synthesize, pack, place, route, generated the FPGA assembly file, generate the bitstream, and finally program the board.
 
 

Changing design:
- Update .V file
- Update ```VERILOG_FILE=``` in Makefile
- Update .PCF file in ```DEVICE_FILE_DIR```



Changing board:
- Update the following Makefile section
  ``` 
  DEVICE=xc7a50t-arty-swbut-test
  DEVICE_FAMILY=artix7
  PART=xc7a50tfgg484-1
  DEVICE_FILE_DIR=./${DEVICE_FAMILY}
  TECHMAP_DIR = ${SYMBIFLOW_DIR}/xc/xc7/techmap
  ```
- Update files in  ```DEVICE_FILE_DIR```
