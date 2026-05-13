module dimc_top #(
    parameter M = 32,
    parameter C = 32,
    parameter ADDR_W = 5,
    parameter TOTAL_OUT_W = 84
)(
    input  logic                   clk,
    input  logic [ADDR_W-1:0]      write_addr_in,
    input  logic [C-1:0]           write_data_in,
    input  logic [M-1:0]           iact_in,
    input  logic                   write_en_in,
    input  logic                   MSB_in,LSB_in,
    output logic [TOTAL_OUT_W-1:0] oact_out
);

    logic [ADDR_W-1:0]      write_addr_reg;
    logic [C-1:0]           write_data_reg;
    logic [M-1:0]           iact_reg;
    logic                   write_en_reg;
    logic                   MSB_reg, LSB_reg;
    logic [TOTAL_OUT_W-1:0] bank_oact_wire; 

    // I/O registers
    always_ff @(posedge clk) begin
        write_addr_reg <= write_addr_in;
        write_data_reg <= write_data_in;
        iact_reg       <= iact_in;
        write_en_reg   <= write_en_in;
        MSB_reg        <= MSB_in;
	    LSB_reg	       <= LSB_in;
        oact_out       <= bank_oact_wire;
    end

    dimc_bank u_dimc_bank (
        .clk        (clk),
        .write_addr (write_addr_reg),
        .write_data (write_data_reg),
        .iact       (iact_reg),
        .write_en   (write_en_reg),
        .MSB        (MSB_reg),
	    .LSB        (LSB_reg),
        .oact       (bank_oact_wire)
    );

endmodule
