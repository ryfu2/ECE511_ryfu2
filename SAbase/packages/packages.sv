// DiM Package
package sa_parameters;
//********************************************************************//
//High level Parameters
    localparam BX = 8;  //Input precision
    localparam BW = 8;  //Weight precision
    localparam N = 32; //Dot-product dimension
    localparam NDP = $clog2(N);
    localparam K = 4;  //Number of parallel components
//********************************************************************//

endpackage : sa_parameters
