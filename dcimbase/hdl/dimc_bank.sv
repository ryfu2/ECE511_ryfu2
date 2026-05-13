// config: 32 rows, 32 cols, 8b weights, A_max=8, pipe=False, LUT=True, Booth = False

module dimc_bank (
    input  logic clk,
    input  logic [4:0] write_addr,
    input  logic [31:0] write_data,
    input  logic [31:0] iact,
    input  logic write_en,
    input  logic MSB, LSB,
    output logic [83:0] oact
);

// scm array
logic [31:0] weight_matrix [32];

// genvar r, c;
// generate
//     for (r = 0; r < 32; r++) begin : row_gen
//         wire row_w_en = write_en && (write_addr == r);

//         for (c = 0; c < 32; c++) begin : col_gen
//             // SRM6T0BBWP30P140hvt u_bitcell ( .BL(write_data[c]), .BLB(~write_data[c]),
//             //                    .WL(row_w_en), .Q(weight_matrix[r][c]), .QB() );

//         end
//     end
// endgenerate
always_latch begin : row_gen
    for (int r = 0; r < 32;r++) begin
        logic row_w_en;
        row_w_en = write_en && (write_addr == r);
        for (int c = 0; c < 32; c++) begin
            if (row_w_en) begin
                weight_matrix[r][c] = write_data[c];
            end
        end 
    end
end
logic signed [20:0] shift_regs [4];
logic signed [20:0] channel_sums [4];

assign oact[20:0] = shift_regs[0][20:0];
assign oact[41:21] = shift_regs[1][20:0];
assign oact[62:42] = shift_regs[2][20:0];
assign oact[83:63] = shift_regs[3][20:0];

logic signed [8:0] lut_array [4][16]; 
always_comb begin
    if (write_en) begin
        for (int j = 0; j < 4; j++) begin
            channel_sums[j] = '0;
        end
    end
    else begin
        for (int j = 0; j < 4; j++) begin
            channel_sums[j] = '0;
            for (int i = 0; i < 32; i++) begin
                channel_sums[j] = channel_sums[j] + $signed(weight_matrix[i][8*j +: 8]) * $signed({1'b0, iact[i*1 +: 1]});
            end
        end
    end
end
always_ff @(posedge clk) begin
    if (write_en) begin
        for (int j = 0; j < 4; j++) begin
            shift_regs[j] <= 0;
        end
    end else begin
        for (int j = 0; j < 4; j++) begin
            if (MSB)      shift_regs[j] <= $signed(~channel_sums[j]+'d1);
            else          shift_regs[j] <= $signed((shift_regs[j] << 1) + channel_sums[j]);
        end
    end
end

endmodule
