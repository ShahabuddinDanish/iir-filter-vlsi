//`timescale 1ns

module tb_iir ();

	wire CLK_i;
	wire RST_n_i;
	wire [13:0] DIN_i;
	wire [13:0] A1_i;
	wire [13:0] B0_i;
	wire [13:0] B1_i;
	wire [13:0] DOUT_i;
	wire VIN_i;
	wire VOUT_i;
	wire END_SIM_i;

	clk_gen CG(
		.END_SIM(END_SIM_i),
		.CLK(CLK_i),
		.RST_n(RST_n_i)
	);

   data_maker SM(
		.CLK(CLK_i),
	    .RST_n(RST_n_i),
		.VOUT(VIN_i),
		.DOUT(DIN_i),
        .Ai(A1_i),
        .Bi0(B0_i),
        .Bi(B1_i),
		.END_SIM(END_SIM_i)
	);
	
	iirfilter UUT(
		.CLK(CLK_i),
	    .RST_n(RST_n_i),
	    .DIN(DIN_i),
        .VIN(VIN_i),
        .Ai(A1_i),
        .Bi0(B0_i),
        .Bi(B1_i),
        .DOUT(DOUT_i),
        .VOUT(VOUT_i));

   data_sink DS(
		.CLK(CLK_i),
		.RST_n(RST_n_i),
		.VIN(VOUT_i),
		.DIN(DOUT_i)
	);   

	always @(posedge END_SIM_i) begin
		if (END_SIM_i) begin
			$display("Simulation end signal received. Ending simulation.");
			$finish;
		end
	end

endmodule
