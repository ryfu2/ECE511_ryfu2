module sa_processing_element
import sa_parameters::*;
(
    input logic  clk,
    input logic  load_en, clear, wupdate, op_en,
    input logic  [BX - 1 : 0] iact_in,
    input logic  [BW - 1 : 0] write_data,
    input logic  [BW + BX + NDP - 1 : 0] psum_in,
    output logic [BX - 1 : 0] iact_out,
    output logic [BW + BX + NDP - 1 : 0] psum_out
);
    logic signed [BW - 1 : 0] data_reg;
    logic signed [BW - 1 : 0] data_prefill_reg;
    logic signed [BX - 1 : 0] iact_reg;
    logic signed [BW + BX + NDP - 1 : 0] psum_reg;
    always_ff @( posedge clk ) begin
        if (load_en) data_prefill_reg <= write_data;
    end
    always_ff @(posedge clk) begin
        if (wupdate) data_reg <= data_prefill_reg;
    end
    always_ff @(posedge clk) begin
        if (clear) begin
            iact_reg <= '0;
            psum_reg <= '0; 
        end
        else if (op_en) begin
            iact_reg <= iact_in;
            psum_reg <= psum_in;  
        end
    end
    assign iact_out = iact_reg;
    assign psum_out = $signed(data_reg*iact_reg + psum_reg);
endmodule