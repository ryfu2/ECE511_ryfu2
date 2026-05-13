module sa_top
import sa_parameters::*;
(
    input logic     clk,
    input logic     wupdate, op_en,
    input logic  [N - 1: 0]   load_en, clear,
    input logic  [BX*N - 1 : 0] iact,
    input logic  [BW*K - 1 : 0] write_data,
    output logic [(BW + BX + NDP)*K - 1 : 0] oact
);
    logic [BX*N - 1 : 0] iact_file [K + 1];
    logic [(BW + BX + NDP)*K - 1 : 0] psum_file [N + 1];
    assign iact_file[0] = iact;
    assign psum_file[0] = '0;
    genvar i,j;
    generate
        for (i = 0 ; i < K; ++i) begin
            for (j = 0; j < N; ++j) begin
                sa_processing_element pe_inst (
                    .clk(clk),
                    .op_en(op_en),
                    .wupdate(wupdate),
                    .load_en(load_en[j]),
                    .clear(clear[j]),
                    .write_data(write_data[BW*i +: BW]),
                    .iact_in(iact_file[i][BX*j +: BX]),
                    .iact_out(iact_file[i + 1][BX*j +: BX]),
                    .psum_in(psum_file[j][(BW + BX + NDP)*i +: (BW + BX + NDP)]),
                    .psum_out(psum_file[j + 1][(BW + BX + NDP)*i +: (BW + BX + NDP)])
                );
            end
        end
    endgenerate
    // assign oact = psum_file[N];
    always_ff @( posedge clk ) begin
        oact <= psum_file[N];
    end
    logic [BW + BX + NDP - 1 : 0] oact_monitor [K];
    always_comb begin
        for (int i = 0; i < K; ++i) begin
            oact_monitor[i] = oact[i*(BW + BX + NDP) +: (BW + BX + NDP)];
        end
    end
endmodule