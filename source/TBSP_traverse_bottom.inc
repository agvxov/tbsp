                    default: { ; } break;
        }

        if (ts_node_child_count(tbnode)
        &&  tbcurrent_cases == PREFIX(enter_cases)) {
            ts_tree_cursor_goto_first_child(&tbcursor);
            continue;
        }

      tblogic:
        if (!ts_node_is_null(ts_node_next_sibling(tbnode))) {
            if (tbcurrent_cases == PREFIX(enter_cases)) {
                tbcurrent_cases = PREFIX(leave_cases);
                continue;
            } else {
                ts_tree_cursor_goto_next_sibling(&tbcursor);
                tbcurrent_cases = PREFIX(enter_cases);
                continue;
            }
        }

        if (tbcurrent_cases == PREFIX(enter_cases)) {
            tbcurrent_cases = PREFIX(leave_cases);
            continue;
        }

        if (ts_tree_cursor_goto_parent(&tbcursor)) {
            tbcurrent_cases = PREFIX(enter_cases);
            goto tblogic;
        }

        break;
    }

    // deinit
    ts_tree_delete(tbtree);
    ts_parser_delete(tbparser);
    ts_tree_cursor_delete(&tbcursor);

    return 0;
}
