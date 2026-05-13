module cm_row 
import pdcm_parameters::*;
(
    input logic [N / 2 - 1 : 0] din,
    input logic [2*BW - 1 : 0] write_en,
    output lut_entries_t lut_out[0: ((N / 2) - 1)]
);
    logic signed [(BW*2 - 1) : 0]   data[N / 2];
    logic signed [BW : 0]           sum[N / 2];
    genvar i;
    generate
        for (i = 0; i < (N / 2); ++i) begin
            pimc_row_8b pimc_row (
                .WL(write_en),
                .D(din[i]),
                .Q0(data[i][0 +: BW]),
                .Q1(data[i][BW +: BW]),
                .S(sum[i])
            ); 
        end
    endgenerate
    always_comb begin
        for (int i = 0; i < (N / 2); ++i) begin
            lut_out[i].lut_01 = {data[i][BW - 1], data[i][0 +: BW]};
            lut_out[i].lut_10 = {data[i][2*BW - 1], data[i][BW +: BW]};
            // lut_out[i].lut_11 = data[i][0 +: BW] + data[i][BW +: BW];
            lut_out[i].lut_11 = sum[i];
        end
    end
endmodule