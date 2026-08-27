// Code your testbench here
// or browse Examples
module updowncounter_tb ();
	wire [7:0] Cout;
	wire dir,err,ec ;
  	reg start ;
	reg ncs,rst,a1,a0 ;
	reg nwr,nrd,clk = 1'b0 ;
	wire [7:0] d_in ;

//-------------------------design instantiation---------------------
  updowncounter_d DUT(.Cout(Cout),.dir(dir),.err(err),.start(start),.ncs(ncs),.rst(rst),.a1(a1),.a0(a0),.nwr(nwr),.nrd(nrd),.clk(clk),.d_in(d_in));
	reg [7:0] dtb_reg ;

  assign d_in = (!ncs && !nwr) ? dtb_reg : 8'hzz ;

//-------------------------stimulus generation---------------------
	always #5 clk = !clk ;
  initial begin
        // default signals
        ncs   = 1'b1;
        reset = 1'b0;
        nrd   = 1'b1;
        nwr   = 1'b1;
        start = 1'b0;
        a1    = 1'b0;
        a0    = 1'b0;
        write_reg = 8'd0;

        @(posedge clk);
        ncs = 1'b0;         // select chip
        @(posedge clk);
        reset = 1'b1;       // release reset

        // Write preload = 248 (addr 00)
        @(posedge clk);
        a1 = 1'b0; a0 = 1'b0; dtb_reg = 8'd248; nwr = 1'b0; nrd = 1'b1;
        @(posedge clk);
        nwr = 1'b1;

        // Write upperlimit = 255 (addr 01)
        @(posedge clk);
        a1 = 1'b0; a0 = 1'b1; dtb_reg = 8'd255; nwr = 1'b0;
        @(posedge clk);
        nwr = 1'b1;

        // Write lowerlimit = 242 (addr 10)
        @(posedge clk);
        a1 = 1'b1; a0 = 1'b0; dtb_reg = 8'd242; nwr = 1'b0;
        @(posedge clk);
        nwr = 1'b1;

        // Write cyclecount = 1 (addr 11)
        @(posedge clk);
        a1 = 1'b1; a0 = 1'b1; dtb_reg = 8'd1; nwr = 1'b0;
        @(posedge clk);
        nwr = 1'b1;

        // Pulse start (produce rising edge sampled by DUT's edge detector)
        @(posedge clk);
        start = 1'b1;
        @(posedge clk);
        start = 1'b0;

        // Let counter run for a while, then change preload/limits to test other behavior
        repeat (20) @(posedge clk);

        // Example: Update preload to 6 and limits to see other transitions
        @(posedge clk);
        a1 = 1'b0; a0 = 1'b0; dtb_reg = 8'd6; nwr = 1'b0;
        @(posedge clk);
        nwr = 1'b1;

        @(posedge clk);
        a1 = 1'b1; a0 = 1'b0; dtb_reg = 8'd6; nwr = 1'b0;
        @(posedge clk);
        nwr = 1'b1;

        @(posedge clk);
        a1 = 1'b0; a0 = 1'b1; dtb_reg = 8'd6; nwr = 1'b0;
        @(posedge clk);
        nwr = 1'b1;

        // allow more cycles
        repeat (50) @(posedge clk);

        // finish
        $display("Testbench finished");
        $finish;
    end

    initial begin
        $monitor($time,"time=%0t preload=%0d upperlimit=%0d lowerlimit=%0d cyclecount=%0d cout=%0d cout1=%0d dir=%b err=%b ec=%b",
                  DUT.plr, DUT.ulr, DUT.llr, DUT.ccr, Cout, DUT.count1, dir, err, ec);