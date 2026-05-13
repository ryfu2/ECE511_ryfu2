// DiM Package
package pdcm_parameters;
//********************************************************************//
//High level Parameters
    localparam BX = 8;  //Input precision
    localparam BW = 8;  //Weight precision
    localparam N = 32; //Dot-product dimension
    localparam NDP = $clog2(N);
    localparam K = 4;  //Number of parallel components
//********************************************************************//
typedef struct {
    logic signed [BW : 0]  lut_01; 
    logic signed [BW : 0]  lut_10; 
    logic signed [BW : 0]  lut_11; 
} lut_entries_t;
endpackage : pdcm_parameters
