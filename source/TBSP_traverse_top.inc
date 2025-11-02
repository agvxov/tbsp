int tbtraverse(const char * const tbcode) {
    // init
    TSParser * tbparser;
    TSTree * tbtree;
    TSTreeCursor tbcursor;
    TSNode tbnode;

    int tbcase;

    tbparser = ts_parser_new();

    ts_parser_set_language(tbparser, tblanguage_function());

    tbtree = ts_parser_parse_string(tbparser, NULL, tbcode, strlen(tbcode));
    tbcursor = ts_tree_cursor_new(ts_tree_root_node(tbtree));
    tbnode = ts_tree_root_node(tbtree);

    const tbcase_t * tbcurrent_cases = tbenter_cases;

    // meat
    while (true) {
        tbnode = ts_tree_cursor_current_node(&tbcursor);
      #if defined(TBDEBUG) && TBDEBUG == 1
        puts(ts_node_string(tbnode));
      #endif

        tbcase = tbdetermine_case(tbcurrent_cases, ts_node_type(tbnode));

        switch (tbcase) {
            // XXX INJECTION
