
package tb_02_pkg;

    localparam  n = 5, nb = n * 8;


    virtual     axi_stream_if   #( .bytes ( n ) )  _st0;
    virtual     axi_stream_if   #( .bytes ( n ) )  _st1;

    int                 _out_ready_cnt=0;

    logic [7:0]         _q_data  [$];

    int                 _cnt_wr=0;
    int                 _cnt_rd=0;
    int                 _cnt_ok=0;  
    int                 _cnt_error=0;

    int                 _wr_done=0;

    task set_outready_cnt;
    input int cnt;        // number of delay for out_tready
    begin
        _st1.tready <= #1 '0;
        _out_ready_cnt = cnt;

    end endtask

    task rise_out_tready;

        for( ; ; ) begin
            @(posedge _st1.clk );
            if( _out_ready_cnt>0 ) begin
                _out_ready_cnt--;
                if( 0==_out_ready_cnt )
                    _st1.tready <= #1 '1;
            end
        end

    endtask;



    task write_data;
        input logic [nb-1:0]    data;
        input int               pause;  // 0 - tvalid still high
    begin
        _st0.tdata  <= #1 data;
        _st0.tvalid <= #1 '1;

        for( int ii=0; ii<n; ii++ )
            _q_data.push_front( data[ii*8+:8]);


        @(posedge _st0.clk iff _st0.tvalid & _st0.tready);
        _cnt_wr++;
        if( _cnt_wr<16 ) begin
            $display( "input: %s  (%h)", data, data );
        end

        if( pause>0 ) begin
            _st0.tvalid <= #1 '0;
            _st0.tdata  <= #1 '0;
            for( int ii=0; ii<pause; ii++ )
                @(posedge _st0.clk);
        end

    end endtask


    task tb_02_init;

        _st0.tvalid = 0; 
        _st1.tready = 1;

    endtask

    task tb_02_prepare;

        fork 
            rise_out_tready();
        join_none

    endtask

    task tb_02_seq_direct;

        #500;
        @(posedge _st0.clk);
        write_data( "ABCDE", 0 );

        write_data( "FGHIJ", 2 );


        write_data( "KLMON", 0 );
        set_outready_cnt(4);
        write_data( "PQRST", 0 );
        write_data( "UVWXY", 0 );
        write_data( "Zabcd", 0 );
        
        
        set_outready_cnt(1);
        write_data( "efghi", 1 );
        write_data( "jklmo", 1 );
        set_outready_cnt(4);

        #100;

        write_data( "ABCDE", 0 );
        write_data( "FGHIJ", 0 );
        write_data( "KLMON", 1 ); // pause>0 is need before delay

        #100;

        write_data( "PQRST", 0 );
        write_data( "UVWXY", 0 );
        write_data( "Zabcd", 1 ); // pause>0 is need before delay

        #500;
        _wr_done=1;
    endtask

    task tb_02_seq_randomize;

        automatic logic [7:0]  data_out=8'h41;
        automatic logic [nb*2-1:0]  val;
        automatic int pause;
    
        while(1) begin
            for( int jj=0; jj<500; jj++ ) begin
    
            pause = $urandom_range( 0, 3 );
    
            for( int ii=0; ii<n*2; ii++ ) begin
                val[ii*8+:8] = data_out;
                data_out++;
                if( 8'h5B==data_out )
                data_out=8'h41;
    
            end
            write_data( val, pause );
            end 
            if( 100==$get_coverage())
                break;
        end
    
        write_data( 0, 1 );
    
        #500;

        _wr_done=1;
    
    endtask


    
    task tb_02_out_tready_randomize;


        automatic int cnt_high;
        automatic int cnt_low;

        while(1) begin

            cnt_high = $urandom_range( 0, 6 );
            cnt_low  = $urandom_range( 1, 6 );

            @(posedge _st1.clk iff _st1.tready);

            if( _wr_done )
                break;

            if( cnt_high ) begin
                repeat(cnt_high) @(posedge _st1.clk);
            end
            set_outready_cnt( cnt_low );

        end
  
    endtask

endpackage    