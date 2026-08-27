// Code your design here
//==========================I/O HANDLING============================
module updowncounter_d (
			output reg [7:0] Cout,
			output reg dir,err, ec ,
  			input start,
			input ncs,rst,a1,a0,
			input nwr,nrd,clk,
			inout [7:0] d_in
			);

//-------------------------signal declaration----------------------
  
  	reg [7:0] din_reg,count1,cc_count ;
	reg [7:0] plr,llr,ulr,ccr ;
  reg [2:0] state_reg ;
  	wire [2:0] next_shift ;
  	reg write_stop,count_start,start_active,control_up,control_down ;

//------------------------procedural block-------------------------
 	 assign d_in = (!ncs && nwr) ? din_reg : 8'hzz ;
 	assign next_shift = {state_reg[1:0], start};

//------------------------count control-------------------
  
    always @(posedge clk) begin
        if (reset) begin
            state_reg <= 3'b000;
            start_active <= 1'b0;
        end else begin
            state_reg <= next_shift;
            if (next_shift == 3'b010) begin
              if (count_start == 1'b0) begin
                    start_active <= 1'b1;
                    write_stop <= 1'b1;
                    count_start <= 1'b1;
                if ((err == 1'b0) && (ccr > 1'b0)) begin
                        count1 <= plr;
                        count_cc <= ccr;
                    end
                end
            end
        end
    end

//---------------------------data reading-----------------
  
	always @(posedge clk ) begin
		if (!ncs) 
       	 begin					//active low chip select
			if(!rst) begin			//active low reset
				din_reg <= 8'd0 ;
				{plr,llr,ulr,ccr} = 32'h0000ff00;
				Cout <= 8'd0 ;
				err <= 1'b0 ;
              	dir <= 1'b0 ;
              	ec <= 1'b0 ;
              	write_stop = 1'b0 ;
		
              	count1 <= 8'd0 ;
              	cc_count <= 8'd0 ;
              	control_up <= 1'b0 ;
              	control_down <= 1'b0 ;
              	count_start <= 1'b0 ;
			end
			else begin
				  case ({a1,a0})
				  2'b00: begin
                        if (!nwr && !write_stop) begin
                            plr <= d_in;
                        end else if (!nrd) begin
                            din_reg <= plr;
                        end
                    end
                    2'b01: begin
                        if (!nwr && !write_stop) begin
                            ulr <= d_in;
                        end else if (!nrd && !write_stop) begin
                            din_reg <= ulr;
                        end
                    end
                    2'b10: begin
                        if (!nwr && !write_stop) begin
                            llr <= d_in;
                        end else if (!nrd) begin
                            din_reg <= llr;
                        end
                    end
                    2'b11: begin
                        if (!nwr && !write_stop) begin
                            ccr <= d_in;
                        end else if (!nrd) begin
                            din_reg <= ccr;
                        end
                    end
                endcase				
			end
		end
		else begin
			{plr,llr,ulr,ccr} = 32'h0;
		end
      
  end
 

//---------------------------------------counting process--------------------------
  always @(posedge clk) begin 
  	  if (rst)
      begin
    		if (plr > ulr || plr < llr ) begin
                    err <= 1'b1;
    		end 
    		else if ((count_cc > 0) && (err == 1'b0)) begin
              
                  if (start_active == 1'b1) 
                  begin
                      if (!(count1 == ulr) && !(plr == ulr)) 
                      begin
                            count1 <= count1 + 1'b1;
                            dir <= 1'b1;
                        if (count1 == ulr - 1'b1) 
                          	begin
                                control_up <= 1'b1;
                            end
                      end 
                      else if (!(count1 == llr) && !control_down) 
                      begin
                            count1 <= count1 - 1'b1;
                            dir <= 1'b0;
                        	if (count1 == llr + 1'b1) begin
                                control_down <= 1'b1;
                            end
                      end 
                      else if (!(count1 == plr))
                      begin
                            count1 <= count1 + 1'b1;
                            dir <= 1'b1;
                      	    if (count1 == plr - 1'b1) begin
                                control_down <= 1'b0;
                                control_up <= 1'b0;
                                count_cc <= count_cc - 1'b1;
                            end
                      end 
                      else if ((plr == llr) && !(count_cc == 0)) 
                      begin
                            count_cc <= count_cc - 1'b1;
                            control_up <= 1'b0;
                            control_down <= 1'b0;
                      end
                  end
                  else begin
                    count1 <= 8'd0;
                    dir <= 1'b0;
                  end
             end
        end
    end

//-------------------------------------output register---------------------------
	always @(posedge clk ) begin
          	Cout <= count1 ;
    end


//-------------------------------------end count---------------
    always @(posedge clk) begin
      if ((ccr == 0) || (count1 == 1'b0)) begin
            ec <= 1'b0;
      end else if (start_active && (count_cc == 8'd0) && (count1 == plr) && (Cout == plr)) begin
            ec <= 1'b1;
            count_start <= 1'b0;
            write_stop <= 1'b0;
        end
    end
endmodule

/*
//======================start pulse generation===================
module start_d (
		output reg start_detect,
		input start,
		input err,clk
		);


//--------------------present state----------------------------
	always @(posedge clk ) begin
		if (!err) begin
			start_reg <= start_next ;
		end else
			start_reg <= 1'b0 ;
	end

//--------------------next state------------------------------
  always @(start,start_reg) begin
		start_next = 1'b0 ;
    case(start_reg)
			S0 : if (!start) 
				start_next = S1 ;
				else start_next = S0 ;
			S1 : if (start)
				start_next = S2 ;
				else start_next = S1 ;
			S2 : if (!start)
				start_next = S3 ;
				else start_next = S0 ;
		endcase
	end

//--------------------output logic----------------------------
  always@(start_reg) begin
    if (start_reg == S3)
		start_detect = start_reg ;
		else 
		start_detect = S0 ;
	end
endmodule
*/



