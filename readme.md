## 修改内存起始地址
```
--- a/thinpad_top.srcs/sources_1/new/inst_rom.v
+++ b/thinpad_top.srcs/sources_1/new/inst_rom.v
@@ -14,7 +14,7 @@ always @ (*) begin
        if (ce == `Disable) begin
                inst <= `ZeroWord;
        end else begin
-               inst <= inst_mem[addr[`InstMemNumLog2:2]];
+               inst <= inst_mem[addr[`InstMemNumLog2:2]-30'h20000000];
        end
 end

--- a/thinpad_top.srcs/sources_1/new/PC.v
+++ b/thinpad_top.srcs/sources_1/new/PC.v
@@ -60,7 +60,7 @@ module PC(
        end*/
        always @ (posedge clk_i) begin
         if (ce_o == 1'b0) begin
-                pc_o <= 32'h00000000;
+                pc_o <= 32'h80000000;
         end else if(stall_i[0] == 1'b0) begin
                   if(branch_flag_i == `Branch) begin
                         pc_o <= branch_target_address_i;
```
