
interface axi_stream_if
#(
    parameter int bytes   = 1,
    parameter int user_w  = 1 
)
( input clk );

logic [bytes*8-1:0]         tdata;
logic                       tvalid;
logic                       tlast;
logic                       tready;
logic [user_w-1:0]          tuser;

modport Master
(
    output                  tdata,
    output                  tvalid,
    output                  tlast,
    output                  tuser,
    input                   tready
);

modport Slave
(
    input                   tdata,
    input                   tvalid,
    input                   tlast,
    input                   tuser,
    output                  tready
);

task init_master;
    // tdata   <= '0;
    // tvalid  <= 0;
    // tlast   <= 0;
    // tuser   <= 0;

endtask

task init_slave;
    //tready   <= 0;

endtask

task wait_clk();
        @(posedge clk );
endtask

task write
(
    input   int                             is_sequence,
    input   logic [bytes*8-1:0]             data_i,
    input   logic [user_w-1:0]              user_i,
    input   logic                           tlast_i,
    input   int                             pause_cnt
);

    if( 0==is_sequence )
        @(posedge clk );

    tvalid  <= #1 1;
    tdata   <= #1 data_i;
    tuser   <= #1 user_i;
    tlast   <= #1 tlast_i;

    @(posedge clk   iff tready);


    if( pause_cnt>0 ) begin

        tvalid  <= #1 0;
        tdata   <= #1 '0;
        tuser   <= #1 '0;
        tlast   <= #1 0;
    
        for( int ii=0; ii<pause_cnt; ii++ )
            @(posedge clk);
    end


endtask


task read
(
    input   int                             is_sequence,
    output  logic [bytes*8-1:0]             data_o,
    output  logic [user_w-1:0]              user_o,
    output  logic                           tlast_o,
    input   int                             pause_cnt
);

    if( 0==is_sequence )
        @(posedge clk );

    tready <= #1 1;

    @(posedge clk   iff tvalid && tready);

    data_o = tdata;
    user_o = tuser;
    tlast_o = tlast;

    if( pause_cnt>0 ) begin

        tready <= #1 0;
    
        for( int ii=0; ii<pause_cnt; ii++ )
            @(posedge clk);
    end


endtask

endinterface