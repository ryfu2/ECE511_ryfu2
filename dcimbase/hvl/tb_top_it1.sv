module tb_dimc();

        localparam bit USE_PIPELINE = 0; 

        logic clk;
        logic [4:0] write_addr_in;
        logic [31:0] write_data_in;
        logic [31:0] activation_in;
        logic write_en_in;
        logic MSB_in;
        logic LSB_in;
        logic [5:0] cycle_count;
        logic [83:0] output_out;

        int error_count = 0;

        initial begin
            clk = 0;
            // 0.25ns high, 0.25ns low = 2000.0 MHz
            forever #1 clk = ~clk; 
        end
        
        initial begin
            cycle_count = 0;
            forever @(posedge clk) cycle_count <= cycle_count + 1;
        end

        initial begin
            $dumpfile("dimc_inference.vcd");
            $dumpvars(0, dut); 
            $dumpoff;          
        end

        dimc_top dut (
            .clk(clk),
            .write_addr_in(write_addr_in),
            .write_data_in(write_data_in),
            .iact_in(activation_in),
            .write_en_in(write_en_in),
            .MSB_in(MSB_in),
            .LSB_in(LSB_in),
            .oact_out(output_out)
        );

    `ifndef PNR
        logic [31:0] debug_weight_matrix [32];
        genvar r;
        generate
            for (r = 0; r < 32; r++) begin : dbg_row
                assign debug_weight_matrix[r] = dut.u_dimc_bank.weight_matrix[r];
            end
        endgenerate
    `endif

        logic [7:0] test_activations [32]; 

        initial begin
            write_addr_in = 0;
            write_data_in = 0;
            activation_in = 0;
            write_en_in = 0;
            MSB_in <= 0;
            LSB_in <= 0;

            @(posedge clk);
            @(posedge clk);

            $display("--- Starting Weight Load ---");
            write_en_in = 1;
            
            for (int ch = 0; ch < 4; ch++) begin
                write_data_in[ch * 8 +: 8] = 15; 
            end

            for (int r = 0; r < 32; r++) begin
                write_addr_in = r[4:0];
                @(posedge clk);
            end
            write_en_in = 0;
            @(posedge clk);

            // ==========================================
            // INFERENCE 1
            // ==========================================
            $display("\n--- Starting Inference 1 ---");
            for (int i = 0; i < 32; i++) test_activations[i] = 8'haa; 
            
            $dumpon; 
            
            for (int bit_idx = 7; bit_idx >= 0; bit_idx--) begin
                MSB_in <= (bit_idx == 7);
                LSB_in <= (bit_idx == 0);
                for (int row = 0; row < 32; row++) activation_in[row] <= test_activations[row][bit_idx];
                @(posedge clk);
            end
            
            if (USE_PIPELINE) begin
                MSB_in <= 0; LSB_in <= 0; activation_in <= 0;
                @(posedge clk); 
            end
            
            fork
                begin
                    automatic logic signed [20:0] exp_val_1 = -41280;
                    @(posedge clk);
                    @(posedge clk);
                    $display("\n--- Checking Inference 1 Results ---");
                    #0.125;
                    for (int ch = 0; ch < 4; ch++) begin
                        if ($signed(output_out[ch*21 +: 21]) !== exp_val_1) begin
                            $display("Inf 1 Mismatch [Channel %0d]: Expected %0d, Got %0d", ch, exp_val_1, $signed(output_out[ch*21 +: 21]));
                            error_count++;
                        end
                    end
                end
            join_none

            // ==========================================
            // INFERENCE 2
            // ==========================================
            $display("\n--- Starting Inference 2 ---");
            for (int i = 0; i < 32; i++) test_activations[i] = 8'haa; 
            
            for (int bit_idx = 7; bit_idx >= 0; bit_idx--) begin
                MSB_in <= (bit_idx == 7);
                LSB_in <= (bit_idx == 0);
                for (int row = 0; row < 32; row++) activation_in[row] <= test_activations[row][bit_idx];
                @(posedge clk);
            end
            
            if (USE_PIPELINE) begin
                MSB_in <= 0; LSB_in <= 0; activation_in <= 0;
                @(posedge clk); 
            end
            
            fork
                begin
                    automatic logic signed [20:0] exp_val_2 = -41280;
                    @(posedge clk);
                    @(posedge clk);
                    $display("\n--- Checking Inference 2 Results ---");
                    #0.125;
                    for (int ch = 0; ch < 4; ch++) begin
                        if ($signed(output_out[ch*21 +: 21]) !== exp_val_2) begin
                            $display("Inf 2 Mismatch [Channel %0d]: Expected %0d, Got %0d", ch, exp_val_2, $signed(output_out[ch*21 +: 21]));
                            error_count++;
                        end
                    end
                end
            join_none

            // ==========================================
            // INFERENCE 3
            // ==========================================
            $display("\n--- Starting Inference 3 ---");
            for (int i = 0; i < 32; i++) test_activations[i] = 8'haa; 
            
            for (int bit_idx = 7; bit_idx >= 0; bit_idx--) begin
                MSB_in <= (bit_idx == 7);
                LSB_in <= (bit_idx == 0);
                for (int row = 0; row < 32; row++) activation_in[row] <= test_activations[row][bit_idx];
                @(posedge clk);
            end
            
            if (USE_PIPELINE) begin
                MSB_in <= 0; LSB_in <= 0; activation_in <= 0;
                @(posedge clk); 
            end
            
            fork
                begin
                    automatic logic signed [20:0] exp_val_3 = -41280;
                    @(posedge clk);
                    @(posedge clk);
                    $display("\n--- Checking Inference 3 Results ---");
                    #0.125;
                    for (int ch = 0; ch < 4; ch++) begin
                        if ($signed(output_out[ch*21 +: 21]) !== exp_val_3) begin
                            $display("Inf 3 Mismatch [Channel %0d]: Expected %0d, Got %0d", ch, exp_val_3, $signed(output_out[ch*21 +: 21]));
                            error_count++;
                        end
                    end
                end
            join_none

            // ==========================================
            // INFERENCE 4
            // ==========================================
            $display("\n--- Starting Inference 4 ---");
            for (int i = 0; i < 32; i++) test_activations[i] = 8'haa; 
            
            for (int bit_idx = 7; bit_idx >= 0; bit_idx--) begin
                MSB_in <= (bit_idx == 7);
                LSB_in <= (bit_idx == 0);
                for (int row = 0; row < 32; row++) activation_in[row] <= test_activations[row][bit_idx];
                @(posedge clk);
            end
            
            if (USE_PIPELINE) begin
                MSB_in <= 0; LSB_in <= 0; activation_in <= 0;
                @(posedge clk); 
            end
            
            fork
                begin
                    automatic logic signed [20:0] exp_val_4 = -41280;
                    @(posedge clk);
                    @(posedge clk);
                    $display("\n--- Checking Inference 4 Results ---");
                    #0.125;
                    for (int ch = 0; ch < 4; ch++) begin
                        if ($signed(output_out[ch*21 +: 21]) !== exp_val_4) begin
                            $display("Inf 4 Mismatch [Channel %0d]: Expected %0d, Got %0d", ch, exp_val_4, $signed(output_out[ch*21 +: 21]));
                            error_count++;
                        end
                    end
                end
            join_none

            // ==========================================
            // INFERENCE 5
            // ==========================================
            $display("\n--- Starting Inference 5 ---");
            for (int i = 0; i < 32; i++) test_activations[i] = 8'haa; 
            
            for (int bit_idx = 7; bit_idx >= 0; bit_idx--) begin
                MSB_in <= (bit_idx == 7);
                LSB_in <= (bit_idx == 0); 
                for (int row = 0; row < 32; row++) activation_in[row] <= test_activations[row][bit_idx];
                @(posedge clk);
            end
            
            if (USE_PIPELINE) begin
                MSB_in <= 0; LSB_in <= 0; activation_in <= 0;
                @(posedge clk); 
            end else begin
                MSB_in <= 0; LSB_in <= 0; activation_in <= 0;
            end
            
            $dumpoff; 

            @(posedge clk);
            @(posedge clk);

            $display("\n--- Checking Inference 5 Results ---");
            begin
                automatic logic signed [20:0] exp_val_5 = -41280;
                #0.125;
                for (int ch = 0; ch < 4; ch++) begin
                    if ($signed(output_out[ch*21 +: 21]) !== exp_val_5) begin
                        $display("Inf 5 Mismatch [Channel %0d]: Expected %0d, Got %0d", ch, exp_val_5, $signed(output_out[ch*21 +: 21]));
                        error_count++;
                    end
                end
            end

            if (error_count == 0) begin
                $display("\n==================================================");
                $display("  [PASS] ALL TESTS PASSED SUCCESSFULLY!           ");
                $display("==================================================\n");
            end else begin
                $display("\n==================================================");
                $display("  [FAIL] TEST FAILED WITH %0d ERRORS!             ", error_count);
                $display("==================================================\n");
            end

            #20 $finish;
        end
    endmodule
    