module tb_sa 
import sa_parameters::*;
();
timeunit 1ns;	
timeprecision 1ns;
initial begin
    $fsdbDumpfile("dump.fsdb");
    $fsdbDumpvars(0, "+all");
end
logic   wupdate;
logic   op_en;
logic   clk;
logic   [N - 1: 0]   load_en, clear;
logic   [BX*N - 1 : 0] iact;
logic   [BW*K - 1 : 0] write_data;
logic   [(BW + BX + NDP)*K - 1 : 0] oact;
int act_counter;

sa_top dut (
    .clk(clk),
    .wupdate(wupdate),
    .op_en(op_en),
    .load_en(load_en),
    .iact(iact),
    .clear(clear),
    .write_data(write_data),
    .oact(oact)
);

task automatic write_weights();
    @(posedge clk);
    for (int witn = 0; witn < N; witn++) begin
        load_en <= 0;
        load_en[witn] <= '1; 
        for (int witk = 0; witk < K; witk++) begin
            write_data[BW*witk +: BW] <= -(1 + witk);
        end
        @(posedge clk);
    end
    load_en <= '0;
endtask //automatic

// task automatic inference();
//     int op_counter = 0;
//     @(posedge clk);
//     op_en <= '1;
//     for (int opint = 0; opint < 20; opint++) begin
//         op_counter = op_counter + 1;
//         act_counter ='0;
//         for (int witn = 0; witn < N; witn++) begin
//             act_counter <= act_counter + 1;
//             if ($signed(act_counter - witn) < 0) begin
//                 iact[BX*witn +: BX] <= '0; 
//             end
//             else begin
//                 iact[BX*witn +: BX] <= op_counter; 
//             end
//             @(posedge clk); 
//         end 
//     end
// endtask //automatic
task automatic inference();
    int op_counter = 0;
    @(posedge clk);
    op_en <= '1;
    for (int opint = 0; opint < 256; opint++) begin
        act_counter ='0;
        for (int witn = 0; witn < N; witn++) begin
            if (opint < witn) iact[BX*witn +: BX] <= '0; 
            else iact[BX*witn +: BX] <= iact[BX*witn +: BX] + 1; 
        end 
        @(posedge clk); 
    end
endtask //automatic
always begin : CLOCK_GENERATION
#1  clk = ~clk;
end
initial begin: CLOCK_INITIALIZATION
    clk = '0;
end 

initial begin: TEST_VECTORS
    clear = '1;
    op_en = '0;
    load_en = '0;
    wupdate = '0;
    write_data = '0;
    iact = '0;
    act_counter = 1;
    @(posedge clk);
    clear <= '0;
    @(posedge clk);
    write_weights();
    @(posedge clk);
    wupdate <= '1;
    @(posedge clk);
    wupdate <= '0;
    inference();
    repeat (100) @(posedge clk);
    $finish;
end
endmodule