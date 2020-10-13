REPORT ztrcktrsr_multi_header_grid.


* two grids
* upper: multi rows title columns
* lower: data


PARAMETERS test.

CLASS my_grid DEFINITION INHERITING FROM cl_gui_alv_grid.
  PUBLIC SECTION.
    METHODS set_resize_cols_public
      IMPORTING
        res TYPE i.
    METHODS get_scroll_pos
      RETURNING
        value(es_col_info) TYPE lvc_s_col.
    METHODS set_scroll_pos
      IMPORTING
        is_col_info TYPE lvc_s_col.

ENDCLASS.

CLASS my_grid IMPLEMENTATION.
  METHOD set_resize_cols_public.
    set_resize_cols( res ).
  ENDMETHOD.

  METHOD get_scroll_pos.
    get_scroll_info_via_id( IMPORTING es_col_info = es_col_info ).
  ENDMETHOD.
  METHOD set_scroll_pos.
    set_scroll_info_via_id( is_col_info = is_col_info ).
  ENDMETHOD.

ENDCLASS.

CLASS multi_title_grid DEFINITION.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        container TYPE REF TO cl_gui_container.
    METHODS set_data.
    METHODS copy.

    METHODS set_title_for_column
      IMPORTING
        column TYPE lvc_fname
        text1  TYPE string
        text2  TYPE string OPTIONAL
        text3  TYPE string OPTIONAL.

    METHODS set_title_for_column_n
      IMPORTING
        column TYPE lvc_fname
        idx    TYPE i
        text   TYPE string.

    DATA grid_head TYPE REF TO my_grid.
    DATA grid_data TYPE REF TO my_grid.

  PROTECTED SECTION.
    DATA data TYPE STANDARD TABLE OF t005t.
    DATA head TYPE REF TO data.

    DATA splitter TYPE REF TO cl_gui_splitter_container.
    DATA container_head TYPE REF TO cl_gui_container.
    DATA container_data TYPE REF TO cl_gui_container.

    DATA fcat_head TYPE lvc_t_fcat.
    DATA fcat_data TYPE lvc_t_fcat.

    METHODS convert_table_to_header.

ENDCLASS.

CLASS multi_title_grid IMPLEMENTATION.
  METHOD constructor.

    convert_table_to_header( ).

    splitter = NEW #( parent = container rows = 2 columns = 1 ).
    splitter->set_row_sash(
          EXPORTING
          id                = 1
          type              = cl_gui_splitter_container=>type_sashvisible
          value             = cl_gui_splitter_container=>false ).

    splitter->set_row_mode( mode = cl_gui_splitter_container=>mode_absolute ).

    splitter->set_row_height( id = 1 height = 80 ).


    container_head = splitter->get_container(
                       row    = 1
                       column = 1 ).

    container_data = splitter->get_container(
                       row    = 2
                       column = 1 ).

    grid_head = NEW #( i_parent = container_head ).

    FIELD-SYMBOLS <head> TYPE ANY TABLE.

    ASSIGN head->* TO <head>.

    grid_head->set_table_for_first_display(
      EXPORTING
         i_default                     = space
         is_layout                     = VALUE lvc_s_layo( no_toolbar = abap_true
                                                           no_headers = abap_false
                                                           no_hgridln = abap_true )
      CHANGING
        it_outtab                      = <head>
        it_fieldcatalog                = fcat_head
      EXCEPTIONS
        invalid_parameter_combination  = 1
       program_error                   = 2
        too_many_lines                 = 3
        OTHERS                         = 4  ).



    grid_data = NEW #( i_parent = container_data ).
    grid_data->set_table_for_first_display(
      EXPORTING
         i_default                     = space
         is_layout                     = VALUE lvc_s_layo( no_toolbar = abap_true
                                                           no_headers = abap_true )
      CHANGING
        it_outtab                      = data
        it_fieldcatalog                = fcat_data
      EXCEPTIONS
        invalid_parameter_combination  = 1
       program_error                   = 2
        too_many_lines                 = 3
        OTHERS                         = 4  ).


    grid_data->set_resize_cols_public( 0 ).


  ENDMETHOD.

  METHOD convert_table_to_header.

    DATA strdef_header TYPE REF TO cl_abap_structdescr.
    DATA tabdef_header TYPE REF TO cl_abap_tabledescr.

    DATA components_head TYPE cl_abap_structdescr=>component_table.


    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_buffer_active        = 'X'
        i_structure_name       = 'T005T'
      CHANGING
        ct_fieldcat            = fcat_data        " Field Catalog with Field Descriptions
      EXCEPTIONS
        inconsistent_interface = 1                  " Call parameter combination error
        program_error          = 2                  " Program Errors
        OTHERS                 = 3.
    IF sy-subrc = 0.

      LOOP AT fcat_data ASSIGNING FIELD-SYMBOL(<field_data>).
        APPEND INITIAL LINE TO fcat_head ASSIGNING FIELD-SYMBOL(<field_head>).
        <field_head> = <field_data>.
        <field_head>-rollname  = 'TEXT40'.
        <field_head>-domname   = 'TEXT40'.
        <field_head>-inttype   = 'C'.
        <field_head>-datatype  = 'CHAR'.
        <field_head>-ref_field = space.
        <field_head>-ref_table = space.
        <field_head>-edit_mask = space.
        <field_head>-convexit  = space.
        IF <field_head>-key = abap_true.
          <field_head>-emphasize = 'C310'.
        ELSE.
          <field_head>-emphasize = 'C300'.
        ENDIF.
        APPEND VALUE #(
          name = <field_data>-fieldname
          type = CAST cl_abap_datadescr( cl_abap_elemdescr=>describe_by_name( 'TEXT40' ) )
          ) TO components_head.
      ENDLOOP.
    ENDIF.

    TRY.
        strdef_header = cl_abap_structdescr=>create(
                          p_components = components_head ).
        tabdef_header = cl_abap_tabledescr=>create(
                          p_line_type  = strdef_header
                          p_table_kind = cl_abap_tabledescr=>tablekind_std  ).
        CREATE DATA head TYPE HANDLE tabdef_header.

        LOOP AT fcat_head
        ASSIGNING <field_head>.
          set_title_for_column(
            column = <field_head>-fieldname
            text1  = CONV #( <field_head>-scrtext_s )
            text2  = CONV #( <field_head>-scrtext_m )
            text3  = CONV #( <field_head>-reptext ) ).
        ENDLOOP.

      CATCH cx_sy_table_creation.
      CATCH cx_sy_struct_creation.
    ENDTRY.

  ENDMETHOD.

  METHOD set_title_for_column.

    set_title_for_column_n(
      column = column
      idx    = 1
      text   = text1 ).

    set_title_for_column_n(
      column = column
      idx    = 2
      text   = text2 ).

    set_title_for_column_n(
      column = column
      idx    = 3
      text   = text3 ).

  ENDMETHOD.

  METHOD set_title_for_column_n.

    FIELD-SYMBOLS <head> TYPE STANDARD TABLE.
    ASSIGN head->* TO <head>.

    READ TABLE <head> INDEX idx ASSIGNING FIELD-SYMBOL(<head_line>).
    IF sy-subrc > 0.
      APPEND INITIAL LINE TO <head> ASSIGNING <head_line>.
    ENDIF.

    ASSIGN COMPONENT column OF STRUCTURE <head_line> TO FIELD-SYMBOL(<text>).
    CHECK sy-subrc = 0.

    <text> = text.


  ENDMETHOD.

  METHOD set_data.

    SELECT * FROM t005t
      INTO TABLE @data
     WHERE spras = @sy-langu.

    grid_data->refresh_table_display( ).

  ENDMETHOD.

  METHOD copy.

    grid_head->get_frontend_fieldcatalog(
      IMPORTING
        et_fieldcatalog = DATA(fcat_head) ).

    grid_data->get_frontend_fieldcatalog(
      IMPORTING
        et_fieldcatalog = DATA(fcat_data) ).

    LOOP AT fcat_head INTO DATA(field_head).
      fcat_data[ fieldname = field_head-fieldname ]-outputlen = field_head-outputlen.
    ENDLOOP.

    grid_data->set_frontend_fieldcatalog( fcat_data ).

    grid_data->set_scroll_pos( is_col_info = grid_head->get_scroll_pos( ) ).

    grid_data->refresh_table_display(
      i_soft_refresh = abap_true
      is_stable = VALUE #(
        col = abap_true
        row = abap_true ) ).

    "eliminate marks
    grid_head->refresh_table_display(
      i_soft_refresh = abap_true
      is_stable = VALUE #(
        col = abap_true
        row = abap_true ) ).

  ENDMETHOD.

ENDCLASS.



INITIALIZATION.

  DATA(docker) = NEW cl_gui_docking_container( side = cl_gui_docking_container=>dock_at_bottom ratio = 90 ).
  DATA(demo) = NEW multi_title_grid( container = docker ).
  demo->set_data( ).


AT SELECTION-SCREEN.
  demo->copy( ).
