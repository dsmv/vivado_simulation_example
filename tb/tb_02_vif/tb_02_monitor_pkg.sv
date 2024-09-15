        
package tb_02_monitor_pkg;

import tb_02_pkg::*;

task tb_02_monitor
(
    virtual     axi_stream_if #( .bytes ( n ) )   st
);

    automatic logic [nb-1:0]    expect_tdata;
    automatic logic [nb-1:0]    out_tdata;

    for( ; ; ) begin

        @(posedge st.clk);

        if( 1==_wr_done && _cnt_wr==_cnt_rd ) 
            break;


        if( st.tvalid && st.tready ) begin
            
            out_tdata = st.tdata;
            for( int ii=0; ii<n; ii++) begin
                expect_tdata[ii*8+:8] = _q_data.pop_back();
            end
            
                if( expect_tdata==out_tdata ) begin
                _cnt_ok++;
            
                if( _cnt_ok<16 )
                    $display( "output: %s  (%h)  ok: %-5d error: %-5d  - Ok", out_tdata, out_tdata, _cnt_ok, _cnt_error );
                end else begin
                    _cnt_error++;
                if( _cnt_error<16 )
                    $display( "output: %s  (%h)  expect %s (%h) ok: %-5d error: %-5d  - Error", out_tdata, out_tdata, expect_tdata, expect_tdata, _cnt_ok, _cnt_error );
            
                end
            
                _cnt_rd++;
                            
        end
    end

endtask


endpackage    