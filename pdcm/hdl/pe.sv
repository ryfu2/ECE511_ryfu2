//The lsb/msb pes have slightly different processing logic hence are implemented in 2 different modules
module pdcm_processing_element
import pdcm_parameters::*;
#(
    parameter PE_POS = 0,   // the position of this PE in this row
    parameter [1:0] SBIT = 2'b00,    //SBIT[1] = MSB, SBIT[0] = LSB
    parameter SHIFT = PE_POS*2
)
(
    input logic  clk, op_en,
    input logic sbit_en, //declare whether this PE will be enabled to support lsb/msb specific features
    input lut_entries_t lut_in[0: ((N / 2) - 1)],
    input logic  [N - 1 : 0] iact1_in, iact0_in,
    input logic  [BW + BX + NDP - 1 : 0] psum_in,
    output logic [BW + BX + NDP - 1 : 0] psum_out
);
    logic signed [BW + BX + NDP - 1 : 0] psum_total;
    logic signed [BW + BX + NDP - 1 : 0] psum_ia0 [N/2];
    logic signed [BW + BX + NDP - 1 : 0] psum_ia1 [N/2];
    logic signed [BW + BX + NDP - 1 : 0] psum_reg;
    always_ff @(posedge clk) begin
        if (op_en) psum_reg <= psum_in;
    end
    always_comb begin
        for (int i = 0; i < (N / 2); ++i) begin
            case(iact0_in[2*i +: 2])
                2'b00: psum_ia0[i] = '0;
                2'b01: psum_ia0[i] = lut_in[i].lut_01;
                2'b10: psum_ia0[i] = lut_in[i].lut_10;
                2'b11: psum_ia0[i] = lut_in[i].lut_11;
            endcase
        end
    end
    always_comb begin
        for (int i = 0; i < N / 2; ++i) begin
            case(iact1_in[2*i +: 2])
                2'b00: psum_ia1[i] = '0;
                2'b01: psum_ia1[i] = lut_in[i].lut_01;
                2'b10: psum_ia1[i] = lut_in[i].lut_10;
                2'b11: psum_ia1[i] = lut_in[i].lut_11;
            endcase
        end
    end
    generate
        if (SBIT == 2'b00) begin //Unsigned intermediate PE
            always_comb begin
                if (sbit_en) psum_total = psum_reg;
                else psum_total = psum_reg;
                for (int i = 0; i < (N / 2); ++i) begin
                    psum_total = psum_total + (psum_ia1[i] << (SHIFT + 1)) + (psum_ia0[i] << (SHIFT));
                end
            end 
        end
        else if (SBIT == 2'b01) begin //Unsigned (programmable) starter PE
            always_comb begin
                if (sbit_en) psum_total = psum_reg;
                else psum_total = '0;
                for (int i = 0; i < (N / 2); ++i) begin
                    psum_total = psum_total + (psum_ia1[i] << (SHIFT + 1)) + (psum_ia0[i] << (SHIFT));
                end
            end 
        end
        else if (SBIT == 2'b10) begin //Signed (programmable) final PE
            always_comb begin
                psum_total = psum_reg;
                if (sbit_en) begin
                    for (int i = 0; i < (N / 2); ++i) begin
                        psum_total = psum_total - (psum_ia1[i] << (SHIFT + 1)) + (psum_ia0[i] << (SHIFT));
                    end 
                end
                else begin
                    for (int i = 0; i < (N / 2); ++i) begin
                        psum_total = psum_total + (psum_ia1[i] << (SHIFT + 1)) + (psum_ia0[i] << (SHIFT));
                    end 
                end
            end 
        end
        else if (SBIT == 2'b11) begin    //Signed (programmable) starting and final PE
            always_comb begin 
                if (sbit_en) psum_total = '0;
                else psum_total = '0;
                if (sbit_en) begin
                    for (int i = 0; i < (N / 2); ++i) begin
                        psum_total = psum_total - (psum_ia1[i] << (SHIFT + 1)) + (psum_ia0[i] << (SHIFT));
                    end 
                end
                else begin
                    for (int i = 0; i < (N / 2); ++i) begin
                        psum_total = psum_total - (psum_ia1[i] << (SHIFT + 1)) + (psum_ia0[i] << (SHIFT));
                    end 
                end
            end
        end
    endgenerate
    //Retiming block
    always_ff @( posedge clk) begin
        psum_out <= psum_total;
    end
endmodule