module pdcm_dp_unit
import pdcm_parameters::*;
(
    input logic                             clk, op_en,
    input logic  [2*BW - 1 : 0]             write_en,
    input logic  [BX*N - 1 : 0]             iact,
    input logic  [(N/2) - 1 : 0]            write_data,
    output logic [(BW + BX + NDP) - 1 : 0]  oact
);
    lut_entries_t lut_out [0:((N / 2) - 1)];
    logic [BW + BX + NDP - 1 : 0] psum_out [BX / 2];
    cm_row cm_row_inst(
        .din(write_data),
        .write_en(write_en),
        .lut_out(lut_out)
    );

    genvar i_pe;
    generate
        for (i_pe = 0; i_pe < (BX / 2); ++i_pe) begin
            //Starting stage PEs
            if (i_pe == 0) begin
                pdcm_processing_element #(
                .PE_POS(0),
                .SBIT(2'b01)
                ) pe_inst_s (
                    .clk(clk),
                    .op_en(op_en),
                    .sbit_en('1),
                    .lut_in(lut_out),
                    .iact1_in(iact[N +: N]),
                    .iact0_in(iact[0 +: N]),
                    .psum_in('0),
                    .psum_out(psum_out[0])
                ); 
            end
            //Final stage PEs
            else if (i_pe == (BX / 2 - 1)) begin
                pdcm_processing_element #(
                .PE_POS(i_pe),
                .SBIT(2'b10)
                ) pe_inst_f (
                    .clk(clk),
                    .op_en(op_en),
                    .sbit_en('1),
                    .lut_in(lut_out),
                    .iact1_in(iact[(i_pe*2*N + N) +: N]),
                    .iact0_in(iact[(i_pe*2*N) +: N]),
                    .psum_in(psum_out[i_pe - 1]),
                    .psum_out(psum_out[i_pe])
                );
            end
            //Intermediate stage PEs
            else begin
                pdcm_processing_element #(
                .PE_POS(i_pe),
                .SBIT(2'b00)
                ) pe_inst_i (
                    .clk(clk),
                    .op_en(op_en),
                    .sbit_en('1),
                    .lut_in(lut_out),
                    .iact1_in(iact[(i_pe*2*N + N) +: N]),
                    .iact0_in(iact[(i_pe*2*N) +: N]),
                    .psum_in(psum_out[i_pe - 1]),
                    .psum_out(psum_out[i_pe])
                );
            end
        end
    endgenerate

    always_ff @( posedge clk ) begin
        oact <= psum_out [(BX / 2) - 1]; 
    end
endmodule