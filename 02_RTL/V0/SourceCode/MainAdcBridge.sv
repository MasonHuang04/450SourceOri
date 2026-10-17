// Validated ADC driver plus a stable-word toggle crossing into the main clock.
// Raw packet decimation is separate from the full-rate FFT tap.
module MainAdcBridge #(parameter integer RAW_CAPACITY=131072)(
 input logic iClk,iRst,iSamplingEn,input logic [15:0] iDownSampleRate,
 input logic iADSDO,iADDRdy,
 output wire oADRstz,oADCSz,oADSClk,oADSDI,oADStart,oADClk,
 output logic [23:0] oDataCnt,output logic oNewData,output logic [15:0] oValue,
 output logic oFftValid,output logic [15:0] oFftValue,
 output logic oOverflow,oClipped);
 logic [2:0] divide_count=0;logic adc_clock=0;
 always_ff @(posedge iClk)begin
  if(divide_count==2)adc_clock<=1;
  if(divide_count==5)begin adc_clock<=0;divide_count<=0;end
  else divide_count<=divide_count+1'b1;
 end
 (* altera_attribute="-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS" *) logic [1:0] adc_reset_sync=3;
 always_ff @(posedge adc_clock)adc_reset_sync<={adc_reset_sync[0],iRst};
 wire adc_rst=adc_reset_sync[1];wire valid,initialized;wire signed [15:0] sample;
 ScopeAdc27m5 adc(.clk(adc_clock),.rst(adc_rst),.sdo(iADSDO),.drdy(iADDRdy),
 .reset_n(oADRstz),.cs_n(oADCSz),.sclk(oADSClk),.sdi(oADSDI),.start(oADStart),
 .initialized(initialized),.valid(valid),.sample(sample));
 assign oADClk=adc_clock;
 logic word_toggle=0;logic [15:0] held_sample=0;
 always_ff @(posedge adc_clock)begin
  if(adc_rst)begin word_toggle<=0;held_sample<=0;end
  else if(valid)begin held_sample<=sample;word_toggle<=~word_toggle;end
 end
 (* altera_attribute="-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS" *) logic [1:0] word_sync;
 logic seen,enabled_last,pending;
 logic [15:0] skip,skip_limit;
 always_ff @(posedge iClk)begin
  oNewData<=0;oFftValid<=0;
  if(iRst)begin
   word_sync<=0;seen<=0;enabled_last<=0;pending<=0;
   skip<=0;skip_limit<=0;oDataCnt<=0;oValue<=16'h8000;oFftValue<=0;oOverflow<=0;oClipped<=0;
  end else begin
   word_sync<={word_sync[0],word_toggle};enabled_last<=iSamplingEn;
   if(word_sync[1]!=seen)begin seen<=word_sync[1];pending<=1;end
   if(!iSamplingEn)begin pending<=0;skip<=0;end
   if(iSamplingEn&&!enabled_last)begin
    skip_limit<=iDownSampleRate;skip<=0;oDataCnt<=0;oOverflow<=0;oClipped<=0;pending<=0;
   end else if(pending&&iSamplingEn)begin
    pending<=0;oFftValue<=held_sample;oFftValid<=1;
    if(held_sample==16'h7fff||held_sample==16'h8000)oClipped<=1;
    if(skip==skip_limit)begin
     skip<=0;
     if(oDataCnt<RAW_CAPACITY)begin
      oValue<=held_sample^16'h8000;oNewData<=1;oDataCnt<=oDataCnt+1'b1;
     end else oOverflow<=1;
    end else skip<=skip+1'b1;
   end
  end
 end
endmodule
