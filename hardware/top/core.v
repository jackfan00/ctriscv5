module core (
clk, cpurst, boot_addr, interrupt,
instr_fromsram,
dsram_rdata,

isram_cs,
isram_adr,
dsram_addr,
dsram_cs,
dsram_we,
dsram_ben,
dsram_wdata
);

input clk, cpurst;
input [31:0] boot_addr;
input interrupt;
input [63:0] instr_fromsram;
input [31:0] dsram_rdata;

output isram_cs;
output [31:3] isram_adr;
output [31:0] dsram_addr ;
output  dsram_cs   ;
output  dsram_we   ;
output [3:0] dsram_ben  ;
output [31:0] dsram_wdata;

//
wire [31:0] rv32_instr_todec;
wire [31:0] fetch_pc;
wire [31:0] r_x1, rs1v, rs2v, rs3v;
wire [4:0] rs3_addr;
wire branch_predict_err;
wire [31:0] de2fe_branch_target;             
wire [31:0] mtvec, mepc;
wire [31:0] mcause;
wire mem2wb_exp_ffout;

fetch fetch_u( 
.clk                 (clk),
.cpurst              (cpurst), 
.fet_stall           (fet_stall),
.boot_addr           (boot_addr),
.r_x1                (r_x1),
.rs3v                (rs3v),
.dec_is_x1           (de2ex_rd_is_x1),
.exe_is_x1           (ex2mem_rd_is_x1),
.mem_is_x1           (mem2wb_rd_is_x1),
.wb_is_x1            (wb2regfile_rd_is_x1 ),
.dec_is_xn           (de2ex_rd_is_xn),
.exe_is_xn           (ex2mem_rd_is_xn),
.mem_is_xn           (mem2wb_rd_is_xn),
.wb_is_xn            (wb2regfile_rd_is_xn),
.dec_regfile_wen     (de2ex_wr_reg),
.exe_regfile_wen     (ex2mem_wr_reg),
.mem_regfile_wen     (mem2wb_wr_reg),
.wb_regfile_wen      (wb2regfile_wr_reg),
.instr_fromsram      (instr_fromsram), 
.branch_predict_err  (branch_predict_err),
.de2fe_branch_target (de2fe_branch_target),
.wb2csrfile_int_ffout(interrupt       ),
.wb2csrfile_exp_ffout(mem2wb_exp_ffout),
.mtvec               (mtvec                  ),
.mepc                (mepc                   ),
.mcause              (mcause[4:0]            ),

// output port
.isram_cs            (isram_cs), 
.isram_adr           (isram_adr), 
.rv32_instr_todec    (rv32_instr_todec), 
.fetch_pc            (fetch_pc),
.fet_is_x1           (fet_is_x1),
.fet_is_xn           (fet_is_xn),
.fetch_rs3n          (rs3_addr),
.predict_bxxtaken    (predict_bxxtaken),
.fe2de_rv16          (fe2de_rv16),
.fet_flush           (fet_flush)

);

//
wire [31:0] fe2de_pc_ffout, fe2de_ir_ffout;
ft_de ft_de_u(
.clk                          (clk), 
.cpurst                       (cpurst),
.fet_flush                    (fet_flush),
.de_stall                     (de_stall), 
.exe_store_load_conflict      (exe_store_load_conflict), 
.readram_stall                (readram_stall),
.mem_stall                    (mem_stall), 
.mult_stall                   (mult_stall),
.fetch_pc                     (fetch_pc), 
.rv32_instr_todec             (rv32_instr_todec),
.fet_is_x1                    (fet_is_x1), 
.fet_is_xn                    (fet_is_xn),
.predict_bxxtaken             (predict_bxxtaken),
.fe2de_rv16                   (fe2de_rv16),
.mem2wb_exp_ffout             (mem2wb_exp_ffout             ),
.interrupt                    (interrupt                    ),
.branch_predict_err           (branch_predict_err),
// output port                
.fe2de_pc_ffout               (fe2de_pc_ffout), 
.fe2de_instr_ffout            (fe2de_ir_ffout),
.fet_is_x1_ffout              (fet_is_x1_ffout ), 
.fet_is_xn_ffout              (fet_is_xn_ffout ),
.fe2de_predict_bxxtaken_ffout (fe2de_predict_bxxtaken_ffout),
.fe2de_rv16_ffout             (fe2de_rv16_ffout),
.fet_stall                    (fet_stall)
);
//

wire [4:0] de2ex_wr_regindex_ffout;
wire [31:0] de2ex_wr_memwdata, de2ex_wr_memwdata_ffout;
wire [31:0] de2ex_rd_oprand1, de2ex_rd_oprand1_ffout;
wire [31:0] de2ex_rd_oprand2, de2ex_rd_oprand2_ffout;
wire [2:0] de2ex_aluop ;
wire [6:0] de2ex_aluop_sub ;
wire [4:0] de2ex_wr_regindex ;
wire de2ex_inst_valid ;

wire [2:0] de2ex_csrop;
wire [31:0] de2ex_pc;
wire [4:0] rs1_addr, rs2_addr;
wire [2:0] de2ex_mem_op;
wire [11:0] de2ex_csr_index, de2ex_csr_index_ffout;
wire [31:0] csr_rdat;

inst_decode inst_decode_u(
.fe2de_pc_ffout               (fe2de_pc_ffout),
.fe2de_ir_ffout               (fe2de_ir_ffout),
.fe2de_predict_bxxtaken_ffout (fe2de_predict_bxxtaken_ffout),
.fe2de_rv16_ffout             (fe2de_rv16_ffout),
.rs1v                         (rs1v), 
.rs2v                         (rs2v),
.de2ex_load_ffout             (de2ex_load_ffout),
.de2ex_wr_regindex_ffout      (de2ex_wr_regindex_ffout),
.csr_rdat                     (csr_rdat),
// output port                
.branch_predict_err           (branch_predict_err),
.de2fe_branch_target          (de2fe_branch_target),
.de2ex_wr_mem                 (de2ex_wr_mem),
.de2ex_mem_op                 (de2ex_mem_op),
.de2ex_wr_memwdata            (de2ex_wr_memwdata),
.de2ex_mem_en                 (de2ex_mem_en),
.de2ex_load                   (de2ex_load),
.de2ex_store                  (de2ex_store),
.de2ex_rd_csrreg              (de2ex_rd_csrreg),
.de2ex_wr_csrreg              (de2ex_wr_csrreg),
.de2ex_MD_OP                  (de2ex_MD_OP),
.de2ex_rd_oprand1             (de2ex_rd_oprand1),
.de2ex_rd_oprand2             (de2ex_rd_oprand2),
.de2ex_aluop                  (de2ex_aluop),
.de2ex_aluop_sub              (de2ex_aluop_sub),
.de2ex_wr_reg                 (de2ex_wr_reg),
.de2ex_wr_regindex            (de2ex_wr_regindex),
.de2ex_inst_valid             (de2ex_inst_valid),
.de2ex_csrop                  (de2ex_csrop),
.de2ex_pc                     (de2ex_pc),
.de_stall                     (de_stall),
.rs1_addr                     (rs1_addr), 
.rs2_addr                     (rs2_addr),
.de2ex_rd_is_x1               (de2ex_rd_is_x1),
.de2ex_rd_is_xn               (de2ex_rd_is_xn),
.de2ex_exp                    (de2ex_exp                    ), 
.de2ex_mret                   (de2ex_mret                   ),
.de2ex_csr_index              (de2ex_csr_index              )
);


wire [31:0] de2ex_pc_ffout;
wire de2ex_wr_mem_ffout ;
wire [2:0] de2ex_mem_op_ffout ;
//wire [31:0] de2ex_wr_memwdata_ffout ;
wire de2ex_mem_en_ffout ;
//wire de2ex_load_ffout ;
wire de2ex_rd_csrreg_ffout ;
wire de2ex_wr_csrreg_ffout ;
wire de2ex_MD_OP_ffout ;
//wire [31:0] de2ex_rd_oprand1_ffout ;
//wire [31:0] de2ex_rd_oprand2_ffout ;
wire [2:0] de2ex_aluop_ffout ;
wire [6:0] de2ex_aluop_sub_ffout ;
wire de2ex_wr_reg_ffout ;
//wire [4:0] de2ex_wr_regindex_ffout ;
wire de2ex_inst_valid_ffout ;
wire [2:0] de2ex_csrop_ffout;
wire de2ex_rd_is_x1_ffout;
wire [4:0] de2ex_rs1addr_ffout, de2ex_rs2addr_ffout;

de_ex de_ex_u(
.clk                     (clk), 
.cpurst                  (cpurst),
.de_stall                (de_stall), 
.exe_store_load_conflict (exe_store_load_conflict),
.mem_stall               (mem_stall), 
.readram_stall           (readram_stall), 
.mult_stall              (mult_stall),
.mem2wb_exp_ffout        (mem2wb_exp_ffout ),
.interrupt               (interrupt ),
.de2ex_pc                (de2ex_pc),
.de2ex_wr_mem            (de2ex_wr_mem),
.de2ex_mem_op            (de2ex_mem_op),
.de2ex_wr_memwdata       (de2ex_wr_memwdata),
.de2ex_mem_en            (de2ex_mem_en),
.de2ex_load              (de2ex_load),
.de2ex_store             (de2ex_store),
.de2ex_rd_csrreg         (de2ex_rd_csrreg),
.de2ex_wr_csrreg         (de2ex_wr_csrreg),
.de2ex_MD_OP             (de2ex_MD_OP),
.de2ex_rd_oprand1        (de2ex_rd_oprand1),
.de2ex_rd_oprand2        (de2ex_rd_oprand2),
.de2ex_aluop             (de2ex_aluop),
.de2ex_aluop_sub         (de2ex_aluop_sub),
.de2ex_wr_reg            (de2ex_wr_reg),
.de2ex_wr_regindex       (de2ex_wr_regindex),
.de2ex_inst_valid        (de2ex_inst_valid),
.de2ex_csrop             (de2ex_csrop),
.de2ex_rd_is_x1          (de2ex_rd_is_x1),
.de2ex_rd_is_xn          (de2ex_rd_is_xn),
.de2ex_exp               (de2ex_exp               ),
.de2ex_mret              (de2ex_mret              ),
.de2ex_csr_index         (de2ex_csr_index         ),
.de2ex_rs1addr           (rs1_addr           ), 
.de2ex_rs2addr           (rs2_addr           ),

// output port
.de2ex_pc_ffout          (de2ex_pc_ffout),
.de2ex_wr_mem_ffout      (de2ex_wr_mem_ffout),
.de2ex_mem_op_ffout      (de2ex_mem_op_ffout),
.de2ex_wr_memwdata_ffout (de2ex_wr_memwdata_ffout),
.de2ex_mem_en_ffout      (de2ex_mem_en_ffout),
.de2ex_load_ffout        (de2ex_load_ffout),
.de2ex_store_ffout       (de2ex_store_ffout),
.de2ex_rd_csrreg_ffout   (de2ex_rd_csrreg_ffout),
.de2ex_wr_csrreg_ffout   (de2ex_wr_csrreg_ffout),
.de2ex_MD_OP_ffout       (de2ex_MD_OP_ffout),
.de2ex_rd_oprand1_ffout  (de2ex_rd_oprand1_ffout),
.de2ex_rd_oprand2_ffout  (de2ex_rd_oprand2_ffout),
.de2ex_aluop_ffout       (de2ex_aluop_ffout),
.de2ex_aluop_sub_ffout   (de2ex_aluop_sub_ffout),
.de2ex_wr_reg_ffout      (de2ex_wr_reg_ffout),
.de2ex_wr_regindex_ffout (de2ex_wr_regindex_ffout),
.de2ex_inst_valid_ffout  (de2ex_inst_valid_ffout),
.de2ex_csrop_ffout       (de2ex_csrop_ffout),
.de2ex_rd_is_x1_ffout    (de2ex_rd_is_x1_ffout),
.de2ex_rd_is_xn_ffout    (de2ex_rd_is_xn_ffout),
.de2ex_exp_ffout         (de2ex_exp_ffout         ),
.de2ex_mret_ffout        (de2ex_mret_ffout        ),
.de2ex_csr_index_ffout   (de2ex_csr_index_ffout   ),
.de2ex_rs1addr_ffout     (de2ex_rs1addr_ffout     ), 
.de2ex_rs2addr_ffout     (de2ex_rs2addr_ffout     )

);

//
//regfile
//wire ex2mem_wr_reg;
wire [4:0] ex2mem_wr_regindex;
wire [31:0] ex2mem_wr_wdata;
//write mem
wire [31:0] ex2mem_memaddr;
wire ex2mem_wr_mem;
wire [31:0] ex2mem_wr_memwdata;
wire [2:0] ex2mem_mem_op;
wire ex2mem_mem_en;
//read mem
wire ex2readram_mem_en;
wire [31:0] ex2readram_addr;
wire [2:0] ex2readram_opmode;
// load command
wire ex2mem_load;
//wire exe_store_load_conflict;
//wire ex2mem_rd_is_x1, ex2mem_rd_is_xn;
wire [2:0] mem2ex_mem_op;
wire [31:0] mem2ex_memadr;
wire [11:0] ex2mem_wr_csrindex;
wire [31:0] ex2mem_wr_csrwdata;

inst_execute inst_execute_u(
.de2ex_wr_mem_ffout       (de2ex_wr_mem_ffout),
.de2ex_mem_op_ffout       (de2ex_mem_op_ffout),
.de2ex_wr_memwdata_ffout  (de2ex_wr_memwdata_ffout),
.de2ex_mem_en_ffout       (de2ex_mem_en_ffout),
.de2ex_load_ffout         (de2ex_load_ffout),
.de2ex_store_ffout        (de2ex_store_ffout),
.de2ex_rd_csrreg_ffout    (de2ex_rd_csrreg_ffout),
.de2ex_wr_csrreg_ffout    (de2ex_wr_csrreg_ffout),
.de2ex_MD_OP_ffout        (de2ex_MD_OP_ffout),
.de2ex_rd_oprand1_ffout   (de2ex_rd_oprand1_ffout),
.de2ex_rd_oprand2_ffout   (de2ex_rd_oprand2_ffout),
.de2ex_aluop_ffout        (de2ex_aluop_ffout),
.de2ex_aluop_sub_ffout    (de2ex_aluop_sub_ffout),
.de2ex_wr_reg_ffout       (de2ex_wr_reg_ffout),
.de2ex_wr_regindex_ffout  (de2ex_wr_regindex_ffout),
.de2ex_inst_valid_ffout   (de2ex_inst_valid_ffout),
.de2ex_csrop_ffout        (de2ex_csrop_ffout),
.de2ex_rd_is_x1_ffout     (de2ex_rd_is_x1_ffout),
.de2ex_rd_is_xn_ffout     (de2ex_rd_is_xn_ffout),
.mem2ex_mem_op            (mem2ex_mem_op),
.mem_misaligned_exxeption (mem_misaligned_exxeption),
.mem2ex_memadr            (mem2ex_memadr),
.ex2mem_store_ffout       (ex2mem_store_ffout        ),
.ex2mem_mem_en_ffout      (ex2mem_mem_en_ffout      ),
.de2ex_csr_index_ffout    (de2ex_csr_index_ffout    ),
.de2ex_exp_ffout          (de2ex_exp_ffout          ),
// output port            
.ex2mem_wr_reg            (ex2mem_wr_reg            ),
.ex2mem_wr_regindex       (ex2mem_wr_regindex       ),
.ex2mem_wr_wdata          (ex2mem_wr_wdata          ),
.ex2mem_memaddr           (ex2mem_memaddr           ),
.ex2mem_wr_mem            (ex2mem_wr_mem            ),
.ex2mem_wr_memwdata       (ex2mem_wr_memwdata       ),
.ex2mem_mem_op            (ex2mem_mem_op            ),
.ex2mem_mem_en            (ex2mem_mem_en            ),
.ex2readram_mem_en        (ex2readram_mem_en        ),
.ex2readram_addr          (ex2readram_addr          ),
.ex2readram_opmode        (ex2readram_opmode        ),
.ex2mem_load              (ex2mem_load              ),
.ex2mem_store             (ex2mem_store             ),
.exe_store_load_conflict  (exe_store_load_conflict  ),
.ex2mem_rd_is_x1          (ex2mem_rd_is_x1          ),
.ex2mem_rd_is_xn          (ex2mem_rd_is_xn          ),
.ex2mem_wr_csrreg         (ex2mem_wr_csrreg         ),
.ex2mem_wr_csrindex       (ex2mem_wr_csrindex       ),
.ex2mem_wr_csrwdata       (ex2mem_wr_csrwdata       ),
.ex2mem_exp               (ex2mem_exp               )

);

wire [31:0] multprod_LO_ffout, multprod_HI_ffout;
inst_mult inst_mult_u(
.clk                        (clk                        ), 
.cpurst                     (cpurst                     ),
.de2ex_inst_valid_ffout     (de2ex_inst_valid_ffout     ),
.de2ex_MD_OP_ffout          (de2ex_MD_OP_ffout          ),
.de2ex_MD_OP                (de2ex_MD_OP                ),
.de2ex_aluop_ffout          (de2ex_aluop_ffout          ),
.de2ex_aluop                (de2ex_aluop                ),
.de2ex_rd_oprand1_ffout     (de2ex_rd_oprand1_ffout     ),
.de2ex_rd_oprand1           (de2ex_rd_oprand1           ),
.de2ex_rd_oprand2_ffout     (de2ex_rd_oprand2_ffout     ),
.de2ex_rd_oprand2           (de2ex_rd_oprand2           ),
.de2ex_rs1addr_ffout        (de2ex_rs1addr_ffout        ), 
.de2ex_rs2addr_ffout        (de2ex_rs2addr_ffout        ), 
.de2ex_wr_regindex_ffout    (de2ex_wr_regindex_ffout    ),
.de2ex_rs1addr              (rs1_addr              ), 
.de2ex_rs2addr              (rs2_addr              ),
// output port              
.mul2mem_prod_complete_ffout(mul2mem_prod_complete_ffout),
.mul2mem_HI_ffout           (mul2mem_HI_ffout           ), 
.mul2mem_LO_ffout           (mul2mem_LO_ffout           ),
.multprod_LO_ffout          (multprod_LO_ffout          ), 
.multprod_HI_ffout          (multprod_HI_ffout          ),
.mult_stall                 (mult_stall                 )
);


wire ex2mem_wr_reg_ffout;
wire [4:0] ex2mem_wr_regindex_ffout;
wire [31:0] ex2mem_wr_wdata_ffout;
wire [31:0] ex2mem_memaddr_ffout;
wire ex2mem_wr_mem_ffout;
wire [31:0] ex2mem_wr_memwdata_ffout;
wire [2:0] ex2mem_mem_op_ffout;
//wire ex2mem_mem_en_ffout;
wire ex2readram_mem_en_ffout;
wire [31:0] ex2readram_addr_ffout;
wire [2:0] ex2readram_opmode_ffout;
//wire ex2mem_load_ffout;
wire ex2mem_rd_is_x1_ffout, ex2mem_rd_is_xn_ffout;
wire [11:0] ex2mem_wr_csrindex_ffout;
wire [31:0] ex2mem_wr_csrwdata_ffout;
wire [31:0] ex2mem_pc_ffout;

ex_mem ex_mem_u(
.clk                     (clk                     ), 
.cpurst                  (cpurst                  ),
.interrupt               (interrupt               ),
.exe_store_load_conflict (exe_store_load_conflict ),
.mult_stall              (mult_stall              ), 
.mem_stall               (mem_stall               ), 
.readram_stall           (readram_stall           ),
.ex2mem_wr_reg           (ex2mem_wr_reg           ),
.ex2mem_wr_regindex      (ex2mem_wr_regindex      ),
.ex2mem_wr_wdata         (ex2mem_wr_wdata         ),
.ex2mem_memaddr          (ex2mem_memaddr          ),
.ex2mem_wr_mem           (ex2mem_wr_mem           ),
.ex2mem_wr_memwdata      (ex2mem_wr_memwdata      ),
.ex2mem_mem_op           (ex2mem_mem_op           ),
.ex2mem_mem_en           (ex2mem_mem_en           ),
.ex2readram_mem_en       (ex2readram_mem_en       ),
.ex2readram_addr         (ex2readram_addr         ),
.ex2readram_opmode       (ex2readram_opmode       ),
.ex2mem_load             (ex2mem_load             ),
.ex2mem_store            (ex2mem_store             ),
.ex2mem_rd_is_x1         (ex2mem_rd_is_x1          ),
.ex2mem_rd_is_xn         (ex2mem_rd_is_xn          ),
.ex2mem_exp              (ex2mem_exp               ),
.ex2mem_pc               (de2ex_pc_ffout           ),
.ex2mem_wr_csrreg        (ex2mem_wr_csrreg         ),
.ex2mem_wr_csrindex      (ex2mem_wr_csrindex       ),
.ex2mem_wr_csrwdata      (ex2mem_wr_csrwdata       ),
.mem2wb_exp_ffout        (mem2wb_exp_ffout         ),
.ex2mem_mret             (de2ex_mret_ffout         ),
//output port 
.ex2mem_wr_reg_ffout     (ex2mem_wr_reg_ffout     ),
.ex2mem_wr_regindex_ffout(ex2mem_wr_regindex_ffout),
.ex2mem_wr_wdata_ffout   (ex2mem_wr_wdata_ffout   ),
.ex2mem_memaddr_ffout    (ex2mem_memaddr_ffout    ),
.ex2mem_wr_mem_ffout     (ex2mem_wr_mem_ffout     ),
.ex2mem_wr_memwdata_ffout(ex2mem_wr_memwdata_ffout),
.ex2mem_mem_op_ffout     (ex2mem_mem_op_ffout     ),
.ex2mem_mem_en_ffout     (ex2mem_mem_en_ffout     ),
.ex2readram_mem_en_ffout (ex2readram_mem_en_ffout ),
.ex2readram_addr_ffout   (ex2readram_addr_ffout   ),
.ex2readram_opmode_ffout (ex2readram_opmode_ffout ),
.ex2mem_load_ffout       (ex2mem_load_ffout       ),
.ex2mem_store_ffout      (ex2mem_store_ffout      ),
.ex2mem_rd_is_x1_ffout   (ex2mem_rd_is_x1_ffout   ),
.ex2mem_rd_is_xn_ffout   (ex2mem_rd_is_xn_ffout   ),
.ex2mem_exp_ffout        (ex2mem_exp_ffout        ),
.ex2mem_pc_ffout         (ex2mem_pc_ffout         ),
.ex2mem_wr_csrreg_ffout  (ex2mem_wr_csrreg_ffout  ),
.ex2mem_wr_csrindex_ffout(ex2mem_wr_csrindex_ffout),
.ex2mem_wr_csrwdata_ffout(ex2mem_wr_csrwdata_ffout),
.ex2mem_mret_ffout       (ex2mem_mret_ffout       )

);

//
wire [4:0] mem2wb_wr_regindex;
wire [31:0] mem2wb_wr_wdata;
//wire mem2wb_wr_reg;
wire [31:0] mem2wb_memaddr;  //to sram write addr
wire [3:0] mem2wb_mem_byteen;  //to sram byte enable
wire mem2wb_mem_en;   // to sram cs for write, sram cs for read is ex2mem_mem_en
wire mem2wb_wr_mem;  // to sram write enable
wire [31:0] mem2wb_mem_wdata;
//wire mem2wb_rd_is_x1;
//wire mem2wb_rd_is_xn;
//wire mem_stall;
wire [31:0] readram_addr;
wire [31:0] readram_rdata;

inst_memacc inst_memacc_u(
.clk                        (clk                        ), 
.cpurst                     (cpurst                     ),
.ex2mem_wr_reg_ffout        (ex2mem_wr_reg_ffout        ),
.ex2mem_wr_regindex_ffout   (ex2mem_wr_regindex_ffout   ),
.ex2mem_wr_wdata_ffout      (ex2mem_wr_wdata_ffout      ),
.ex2mem_memaddr_ffout       (ex2mem_memaddr_ffout       ),
.ex2mem_wr_mem_ffout        (ex2mem_wr_mem_ffout        ),
.ex2mem_wr_memwdata_ffout   (ex2mem_wr_memwdata_ffout   ),
.ex2mem_mem_op_ffout        (ex2mem_mem_op_ffout        ),
.ex2mem_mem_en              (ex2mem_mem_en              ),
.ex2mem_mem_en_ffout        (ex2mem_mem_en_ffout        ),
.ex2mem_load_ffout          (ex2mem_load_ffout          ),
.ex2mem_store_ffout         (ex2mem_store_ffout         ),
.ex2mem_rd_is_x1_ffout      (ex2mem_rd_is_x1_ffout      ),
.ex2mem_rd_is_xn_ffout      (ex2mem_rd_is_xn_ffout      ),
.readram_addr               (readram_addr               ),
.readram_rdata              (readram_rdata              ),
.mul2mem_LO_ffout           (mul2mem_LO_ffout           ),
.mul2mem_HI_ffout           (mul2mem_HI_ffout           ),
.mul2mem_prod_complete_ffout(mul2mem_prod_complete_ffout),
.multprod_LO_ffout          (multprod_LO_ffout          ),
.multprod_HI_ffout          (multprod_HI_ffout          ),
.load_misaligned_exxeption  (load_misaligned_exxeption  ),
.ex2mem_exp_ffout           (ex2mem_exp_ffout           ),

//output port              
.mem2ex_mem_op              (mem2ex_mem_op              ),
.mem2ex_memadr              (mem2ex_memadr              ),
.mem2wb_wr_regindex         (mem2wb_wr_regindex         ),
.mem2wb_wr_wdata            (mem2wb_wr_wdata            ),
.mem2wb_wr_reg              (mem2wb_wr_reg              ),
.mem2wb_memaddr             (mem2wb_memaddr             ),
.mem2wb_mem_byteen          (mem2wb_mem_byteen          ),
.mem2wb_mem_en              (mem2wb_mem_en              ),
.mem2wb_wr_mem              (mem2wb_wr_mem              ),
.mem2wb_mem_wdata           (mem2wb_mem_wdata           ),
.mem2wb_rd_is_x1            (mem2wb_rd_is_x1            ),
.mem2wb_rd_is_xn            (mem2wb_rd_is_xn            ),
.mem_stall                  (mem_stall                  ),
.dsram_addr                 (dsram_addr                 ),
.dsram_cs                   (dsram_cs                   ),
.dsram_we                   (dsram_we                   ),
.dsram_ben                  (dsram_ben                  ),
.dsram_wdata                (dsram_wdata                ),
.mem2wb_exp                 (mem2wb_exp                 ),
.mem_misaligned_exxeption   (mem_misaligned_exxeption   )

);

//wire [31:0] readram_addr;  // to sram read addr

readram readram_u(
.clk                       (clk                       ), 
.cpurst                    (cpurst                    ),
.ex2readram_opmode_ffout   (ex2readram_opmode_ffout   ),
.ex2readram_addr           (ex2readram_addr           ),
.ex2readram_addr_ffout     (ex2readram_addr_ffout     ),
.memrdata                  (dsram_rdata               ),
.ex2readram_mem_en_ffout   (ex2readram_mem_en_ffout   ),  
.ex2mem_load_ffout         (ex2mem_load_ffout         ),
//output port                                         
.readram_addr              (readram_addr              ),
.load_misaligned_exxeption (load_misaligned_exxeption ),
.readram_rdata             (readram_rdata             ),
.readram_stall             (readram_stall             )

);


wire mem2wb_wr_reg_ffout;
wire [4:0] mem2wb_wr_regindex_ffout;
wire [31:0] mem2wb_wr_wdata_ffout;
wire mem2wb_rd_is_x1_ffout;
wire mem2wb_rd_is_xn_ffout;
wire [31:0] mem2wb_pc_ffout;
wire [11:0] mem2wb_wr_csrindex_ffout;
wire [31:0] mem2wb_wr_csrwdata_ffout;

wire [31:0] mem2wb_wr_csrwdata = ex2mem_wr_csrwdata_ffout;

mem_wb mem_wb_u(
.clk                     (clk                     ), 
.cpurst                  (cpurst                  ),
.mem_stall               (mem_stall               ),
.readram_stall           (readram_stall           ),
.exe_store_load_conflict (exe_store_load_conflict ), 
.interrupt               (interrupt               ),
.mem2wb_rd_is_x1         (mem2wb_rd_is_x1         ),
.mem2wb_rd_is_xn         (mem2wb_rd_is_xn         ),
.mem2wb_wr_reg           (mem2wb_wr_reg           ),
.mem2wb_wr_regindex      (mem2wb_wr_regindex      ),
.mem2wb_wr_wdata         (mem2wb_wr_wdata         ),
.mem2wb_pc               (ex2mem_pc_ffout         ),
.mem2wb_exp              (ex2mem_exp_ffout        ),
.mem2wb_wr_csrreg        (ex2mem_wr_csrreg_ffout  ),
.mem2wb_wr_csrindex      (ex2mem_wr_csrindex_ffout),
.mem2wb_wr_csrwdata      (ex2mem_wr_csrwdata_ffout),
.mem2wb_mret             (ex2mem_mret_ffout       ),

//output port
.mem2wb_rd_is_x1_ffout   (mem2wb_rd_is_x1_ffout   ),
.mem2wb_rd_is_xn_ffout   (mem2wb_rd_is_xn_ffout   ),
.mem2wb_wr_reg_ffout     (mem2wb_wr_reg_ffout     ),
.mem2wb_wr_regindex_ffout(mem2wb_wr_regindex_ffout),
.mem2wb_wr_wdata_ffout   (mem2wb_wr_wdata_ffout   ),
.mem2wb_pc_ffout         (mem2wb_pc_ffout         ),
.mem2wb_exp_ffout        (mem2wb_exp_ffout        ),
.mem2wb_wr_csrreg_ffout  (mem2wb_wr_csrreg_ffout  ),
.mem2wb_wr_csrindex_ffout(mem2wb_wr_csrindex_ffout),
.mem2wb_wr_csrwdata_ffout(mem2wb_wr_csrwdata_ffout),
.mem2wb_mret_ffout       (mem2wb_mret_ffout       )

);


wire [4:0] wb2regfile_wr_regindex;
//wire wb2regfile_wr_reg;
wire [31:0] wb2regfile_wr_wdata;
//wire wb2regfile_rd_is_x1;
//wire wb2regfile_rd_is_xn;
wire [11:0] wb2csrfile_wr_regindex; 
wire [31:0] wb2csrfile_wr_wdata    ;


inst_wb inst_wb_u(
.mem2wb_rd_is_x1_ffout   (mem2wb_rd_is_x1_ffout   ),
.mem2wb_rd_is_xn_ffout   (mem2wb_rd_is_xn_ffout   ),
.mem2wb_wr_regindex_ffout(mem2wb_wr_regindex_ffout),
.mem2wb_wr_reg_ffout     (mem2wb_wr_reg_ffout     ),
.mem2wb_wr_wdata_ffout   (mem2wb_wr_wdata_ffout   ),
.mem2wb_wr_csrreg_ffout  (mem2wb_wr_csrreg_ffout  ),
.mem2wb_wr_csrindex_ffout(mem2wb_wr_csrindex_ffout),
.mem2wb_wr_csrwdata_ffout(mem2wb_wr_csrwdata_ffout), 
.mem2wb_exp_ffout        (mem2wb_exp_ffout        ),
.interrupt               (interrupt               ),
//output port
.wb2regfile_rd_is_x1     (wb2regfile_rd_is_x1     ),
.wb2regfile_rd_is_xn     (wb2regfile_rd_is_xn     ),
.wb2regfile_wr_regindex  (wb2regfile_wr_regindex  ),
.wb2regfile_wr_reg       (wb2regfile_wr_reg       ),
.wb2regfile_wr_wdata     (wb2regfile_wr_wdata     ),
.wb2csrfile_wr_reg       (wb2csrfile_wr_reg       ),
.wb2csrfile_wr_regindex  (wb2csrfile_wr_regindex  ),
.wb2csrfile_wr_wdata     (wb2csrfile_wr_wdata     )
);


regfile regfile_u(
.clk                     (clk                     ),
.cpurst                  (cpurst                  ),
.ex2mem_wr_regindex      (ex2mem_wr_regindex      ), 
.ex2mem_wr_regindex_ffout(ex2mem_wr_regindex_ffout), 
.mem2wb_wr_regindex_ffout(mem2wb_wr_regindex_ffout),
.rs1_addr                (rs1_addr                ), 
.rs2_addr                (rs2_addr                ), 
.rs3_addr                (rs3_addr                ), 
.wb2regfile_wr_regindex  (wb2regfile_wr_regindex  ),
.ex2mem_wr_reg           (ex2mem_wr_reg           ), 
.mem2wb_wr_reg           (mem2wb_wr_reg           ), 
.mem2wb_wr_reg_ffout     (mem2wb_wr_reg_ffout     ), 
.wb2regfile_wr_reg       (wb2regfile_wr_reg       ),
.ex2mem_wr_wdata         (ex2mem_wr_wdata         ), 
.mem2wb_wr_wdata         (mem2wb_wr_wdata         ), 
.mem2wb_wr_wdata_ffout   (mem2wb_wr_wdata_ffout   ), 
.wb2regfile_wr_wdata     (wb2regfile_wr_wdata     ),
//output port
.rs1v                    (rs1v                    ),
.rs2v                    (rs2v                    ), 
.rs3v                    (rs3v                    ),
.r_x1                    (r_x1                    )
);

wire [31:0] mstatus ; 
wire [31:0] mie     ;
//wire [31:0] mtvec   ;
//wire [31:0] mepc    ;
//wire [31:0] mcause  ;
wire [31:0] mtval   ;
wire [31:0] mip     ;

wire [31:0] mem2wb_instr_ffout;
csrfile csrfile_u(
.clk                    (clk                    ), 
.cpurst                 (cpurst                 ),
.wb2csrfile_exp         (mem2wb_exp_ffout       ),
.wb2csrfile_int         (interrupt              ),
.wb2csrfile_mret        (mem2wb_mret_ffout        ),
.csr_r_index            (de2ex_csr_index        ),
.ex2mem_wr_csrindex     (ex2mem_wr_csrindex     ), 
.ex2mem_wr_csrindex_ffout(ex2mem_wr_csrindex_ffout), 
.mem2wb_wr_csrindex_ffout(mem2wb_wr_csrindex_ffout),
.wb2csrfile_wr_reg      (wb2csrfile_wr_reg      ),
.ex2mem_wr_csrreg       (ex2mem_wr_csrreg       ), 
.mem2wb_wr_csrreg       (mem2wb_wr_csrreg       ), 
.mem2wb_wr_csrreg_ffout (mem2wb_wr_csrreg_ffout ),
.wb2csrfile_wr_regindex (wb2csrfile_wr_regindex ),
.wb2csrfile_wr_wdata    (wb2csrfile_wr_wdata    ),
.ex2mem_wr_csrwdata     (ex2mem_wr_csrwdata     ), 
.mem2wb_wr_csrwdata     (mem2wb_wr_csrwdata     ), 
.mem2wb_wr_csrwdata_ffout(mem2wb_wr_csrwdata_ffout),
.wb2csrfile_i_ms        (wb2csrfile_i_ms        ),
.wb2csrfile_i_mt        (wb2csrfile_i_mt        ),
.wb2csrfile_i_me        (wb2csrfile_i_me        ),
.wb2csrfile_e_iam       (wb2csrfile_e_iam       ),
.wb2csrfile_e_ii        (wb2csrfile_e_ii        ),
.wb2csrfile_e_bk        (wb2csrfile_e_bk        ),
.wb2csrfile_e_lam       (wb2csrfile_e_lam       ),
.wb2csrfile_e_ecfm      (wb2csrfile_e_ecfm      ),
.mem2wb_instr_ffout     (mem2wb_instr_ffout     ),
.mem2wb_pc_ffout        (mem2wb_pc_ffout        ),
.ex2mem_pc_ffout        (ex2mem_pc_ffout        ),
//                        
.mstatus                (mstatus                ),
.mie                    (mie                    ),
.mtvec                  (mtvec                  ),
.mepc                   (mepc                   ),
.mcause                 (mcause                 ),
.mtval                  (mtval                  ),
.mip                    (mip                    ),
.csr_rdat               (csr_rdat               )

);

endmodule
