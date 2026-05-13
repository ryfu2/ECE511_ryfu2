module pimc_row_8b ();
import pdcm_parameters::*;
endmodule
// (
//     input logic D,
//     input logic [2*BW - 1 : 0] WL,
//     output logic [BW - 1 : 0] Q0,Q1,
//     output logic [BW : 0]     S
// );
//     always_latch begin
//         for (int i = 0; i < 2*BW; ++i) begin
//             if (WL[i] & i[0] == 0) Q0[i / 2] = D;
//             else if (WL[i] & i[0] == 1) Q1[i / 2] = D;
//         end
//     end
//     assign S = $signed(Q0 + Q1);