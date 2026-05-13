module pdcm_top
import pdcm_parameters::*;
(
    input logic                     clk,
    input logic                     op_en,
    input logic  [2*BW*K - 1 : 0]   write_en,
    input logic  [BX*N - 1 : 0]     iact,
    input logic  [(N/2)*K - 1 : 0]  write_data,
    output logic [(BW + BX + NDP)*K - 1 : 0] oact
);
    logic [BX*N - 1 : 0]        iact_reg;
    logic [(N/2)*K - 1 : 0]     write_data_reg;
    logic                       op_reg;
    always_ff @(posedge clk) begin
        op_reg <= op_en;
    end
    always_ff @(posedge clk) begin
        iact_reg <= iact;
    end
    always_ff @(posedge clk) begin
        write_data_reg <= write_data;
    end
    genvar i;
    generate
        for (i = 0; i < K; ++i) begin
            pdcm_dp_unit dp_inst
            (
                .clk(clk),
                .op_en(op_reg),
                .write_en(write_en[2*BW*i +: 2*BW]),
                .iact(iact_reg),
                .write_data(write_data_reg[(N/2)*i +: (N/2)]),
                .oact(oact[(BW + BX + NDP)*i +: (BW + BX + NDP)])
            ); 
        end
    endgenerate
endmodule