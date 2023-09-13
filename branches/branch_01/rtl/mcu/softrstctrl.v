
module softrstctrl (
  clkcpu,
  resetff,
  newinstr,
  srstreq,
  srstflag,
  sfrdatai,
  sfraddr,
  sfrwe
  );

  input             clkcpu;         // Global clock input
  input             resetff;
  input             newinstr;
  output            srstreq;        // Software reset request
  wire              srstreq;
  output            srstflag;       // Software reset status
  reg               srstflag;
  input     [ 7: 0] sfrdatai;
  input     [ 6: 0] sfraddr;
  input             sfrwe;

//*******************************************************************--

  `include "mcu51_param.v"
  reg               srst_ff0;
  reg               srst_ff1;
  reg               srst_r;
  reg       [ 3: 0] srst_count;

  //------------------------------------------------------------------
  // Software reset driver
  //------------------------------------------------------------------
  assign srstreq = srst_r;
  
  //------------------------------------------------------------------
  // Software reset status flag
  //------------------------------------------------------------------
  always @(posedge clkcpu)
  begin : srstflag_proc
  //------------------------------------------------------------------
    //-----------------------------------
    // Synchronous reset
    //-----------------------------------
    if (resetff == 1'b1)
    begin
      srstflag <= SRST_RV[0] ;
    end
    else
    begin
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // Special Function Register write
      //--------------------------------
      if (srst_r == 1'b1)
      begin
        srstflag <= 1'b1;
      end
      else if (sfraddr == SRST_ID && sfrwe == 1'b1 && sfrdatai[0]==1'h0)
        srstflag <= 1'b0;
    end
  end

  //------------------------------------------------------------------
  // Software Reset
  //------------------------------------------------------------------
  always @(posedge clkcpu)
  begin : soft_reset_proc
  //------------------------------------------------------------------
    if (resetff == 1'b1)
    begin
      srst_r         <= 1'b0;
      srst_ff0       <= SRST_RV[6];
      srst_ff1       <= SRST_RV[6];
    end
    else
    begin
      if (sfraddr == SRST_ID && sfrwe == 1'b1)
      begin
        //---------------------------------
        // Special Function Register write
        //---------------------------------
          srst_ff0    <= sfrdatai[0];
          srst_ff1    <= srst_ff0;
      end
      else
      begin
        //-----------------------------------
        // Synchronous reset
        //-----------------------------------
        if (srst_r == 1'b1)
        begin
          srst_ff0    <= 1'b0 ;
          srst_ff1    <= 1'b0 ;
        end
        else if (newinstr == 1'b1)
        begin
          //-------------------------------
          // Clear after one instruction
          //-------------------------------
          srst_ff0    <= 1'b0 ;
          srst_ff1    <= srst_ff0 ;
        end
      end
      if (sfraddr == SRST_ID && sfrwe == 1'b1 && (sfrdatai[0]) == 1'b1)
      begin
        //---------------------------------
        // Software Reset
        //---------------------------------
          srst_r    <= srst_ff1;
      end
      else if (srst_count == 4'b1111)
      begin
        srst_r    <= 1'b0;
      end
    end
  end

  //------------------------------------------------------------------
  // Software reset counter
  //------------------------------------------------------------------
  always @(posedge clkcpu)
  begin : srst_count_proc
  //------------------------------------------------------------------
    //-----------------------------------
    // Synchronous reset
    //-----------------------------------
    if (resetff == 1'b1)
    begin
      srst_count <= 4'b0000;
    end
    else
    begin
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      if (srst_r == 1'b1)
      begin
        srst_count <= srst_count + 1'b1;
      end
    end
  end

endmodule // softrstctrl

