*&---------------------------------------------------------------------*
*& Include          ZSDC001_A_TOP
*&---------------------------------------------------------------------*
TABLES : sscrfields.

TYPE-POOLS: slis, icon.

DATA  : gt_exceldata TYPE TABLE OF alsmex_tabline,
        gs_exceldata LIKE LINE OF gt_exceldata,
        gt_return    TYPE TABLE OF bapiret2 WITH HEADER LINE,
        gt_header    TYPE TABLE OF bapisdhd1,
        gs_header    TYPE          bapisdhd1,
        gt_headerx   TYPE TABLE OF bapisdhd1x,
        gs_headerx   TYPE          bapisdhd1x,
        gt_item      TYPE TABLE OF bapisditm,
        gs_item      TYPE          bapisditm,
        gt_itemx     TYPE TABLE OF bapisditmx,
        gs_itemx     TYPE          bapisditmx,
        gt_schd      TYPE TABLE OF bapischdl,
        gs_schd      TYPE          bapischdl,
        gt_schdx     TYPE TABLE OF bapischdlx,
        gs_schdx     TYPE          bapischdlx,
        gt_cond      TYPE TABLE OF bapicond,
        gs_cond      TYPE          bapicond,
        gt_condx     TYPE TABLE OF bapicondx,
        gs_condx     TYPE          bapicondx,
        gt_partner   TYPE TABLE OF bapiparnr,
        gs_partner   TYPE          bapiparnr,
        salesdoc     TYPE bapivbeln-vbeln,
        collectno    TYPE bapisdhd1-collect_no,
        n_row        TYPE i VALUE 0.

TYPES : BEGIN OF ty_upload,
          ref_doc      TYPE char10,
          doc_type     TYPE char4,
          sales_org    TYPE char4,
          distr_chan   TYPE char2,
          division     TYPE char2,
          sales_off    TYPE char4,
          sales_grp    TYPE char3,
          ref_doc_l    TYPE char10,
          refdoc_cat   TYPE char1,
          sales_dist   TYPE char4,
          custom_1     TYPE char4,
          custom_2     TYPE char4,
          itm_number   TYPE char6,
          material     TYPE char14,
          plant        TYPE char4,
          target_qty   TYPE DZMENG,
          target_uom   TYPE char3,
          route        TYPE char6,
          req_qty      TYPE DZMENG,
          c_itm_number TYPE char6,
          cond_type    TYPE char4,
          cond_value   TYPE char6,
          currency     TYPE char3,
          proseg       TYPE fb_segment,
          matgr1       TYPE vbap-mvgr1,
          matgr2       TYPE vbap-mvgr2,
          matgr3       TYPE vbap-mvgr3,
          matgr4       TYPE vbap-mvgr4,
        END OF ty_upload,

        gtt_upload TYPE STANDARD TABLE OF ty_upload.

TYPES : BEGIN OF ty_template,
*          ref_doc      TYPE char10,
          order_type   TYPE char4,
          sales_org    TYPE char4,
          distr_chan   TYPE char2,
          division     TYPE char2,
*          sales_off    TYPE char4,
*          sales_grp    TYPE char3,
          ref_contrt   TYPE char10,
          ref_item     TYPE char6,
          ref_doc_cat  TYPE char1,
          sales_dist   TYPE char4,
          custom_1     TYPE char4,
          custom_2     TYPE char4,
          itm_number   TYPE char6,
          material     TYPE char14,
          plant        TYPE char4,
          qty          TYPE DZMENG,
          uom          TYPE char3,
          route        TYPE char6,
*          req_qty      TYPE char3,
*          c_itm_number TYPE char2,
          moth_vessel  TYPE char10,
*          cond_type    TYPE char4,
*          cond_value   TYPE char6,
*          currency     TYPE char3,
*          proseg       TYPE fb_segment,
          matgr1       TYPE vbap-mvgr1,
          matgr2       TYPE vbap-mvgr2,
          matgr3       TYPE vbap-mvgr3,
          matgr4       TYPE vbap-mvgr4,
          partner_func TYPE char50,
          parnter_no   TYPE char255,
          ID   TYPE char25,
        END OF ty_template,

        gtt_template TYPE STANDARD TABLE OF ty_template.

TYPES : BEGIN OF ty_alv,
          status       LIKE icon-id,
          message      TYPE char255,
          doc_no       TYPE vbak-vbeln,
          order_type   TYPE char4,
          sales_org    TYPE char4,
          distr_chan   TYPE char2,
          division     TYPE char2,
          ref_contrt   TYPE char10,
          ref_item     TYPE char6,
          ref_doc_cat  TYPE char1,
          sales_dist   TYPE char4,
          custom_1     TYPE char4,
          custom_2     TYPE char4,
          itm_number   TYPE char6,
          material     TYPE char14,
          plant        TYPE char4,
          qty          TYPE DZMENG,
          uom          TYPE char3,
          route        TYPE char6,
          moth_vessel  TYPE char10,
          matgr1       TYPE vbap-mvgr1,
          matgr2       TYPE vbap-mvgr2,
          matgr3       TYPE vbap-mvgr3,
          matgr4       TYPE vbap-mvgr4,
          partner_func TYPE char50,
          parnter_no   TYPE char255,
          ID   TYPE char25,
        END OF ty_alv,

        gtt_display TYPE STANDARD TABLE OF ty_alv.

DATA  : gt_data    TYPE gtt_template,
        gs_data    TYPE ty_template,

        gt_display TYPE gtt_display,
        gs_display TYPE ty_alv.

FIELD-SYMBOLS : <gt_data>       TYPE STANDARD TABLE .


"ALV Declare

DATA  : ok_code  TYPE sy-ucomm.

DATA  : i_layout    TYPE lvc_s_layo,
        i_variant   LIKE disvariant,
        i_print     TYPE lvc_s_prnt,
        r_ucomm     TYPE sy-ucomm,
        i_selfield  TYPE slis_selfield,
        i_save      VALUE 'A',
        i_events    TYPE slis_t_event,
        i_fieldcat  TYPE lvc_t_fcat,
        wa_fieldcat LIKE LINE OF i_fieldcat,
        i_list_top1 TYPE lvc_t_head,
        i_events1   TYPE lvc_t_evts.

DATA  : ob_custom TYPE REF TO cl_gui_docking_container,
        ob_grid   TYPE REF TO cl_gui_alv_grid.
DATA  : lt_exclude TYPE ui_functions.

DATA  : go_custom_container TYPE REF TO cl_gui_custom_container,
        go_alv              TYPE REF TO cl_gui_alv_grid,
        gs_layout           TYPE lvc_s_layo.

"AL11
DATA  : gv_sourcepath LIKE sapb-sappfad VALUE '/usr/sap/trans/RICEFW/D01/file_awal/Template - Upload SO v1.xlsx',
        gv_targetpath LIKE sapb-sappfad VALUE '/usr/sap/trans/RICEFW/D01/file_sukses/Template - Upload SO v1.xlsx'.

"Selection Screen

SELECTION-SCREEN BEGIN OF BLOCK search_block WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_bapi RADIOBUTTON GROUP rgb USER-COMMAND cmd_rd DEFAULT 'X',
             p_al11 RADIOBUTTON GROUP rgb.
SELECTION-SCREEN END OF BLOCK search_block.

SELECTION-SCREEN BEGIN OF BLOCK a01 WITH FRAME TITLE TEXT-002.
  PARAMETERS : p_excel TYPE rlgrap-filename LOWER CASE MODIF ID sc1.
  PARAMETERS : p_test AS CHECKBOX MODIF ID sc1 DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK a01.

SELECTION-SCREEN FUNCTION KEY 1.

INITIALIZATION.
  sscrfields-functxt_01 = 'Download Template'.
