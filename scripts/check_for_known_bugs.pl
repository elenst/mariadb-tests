#!/usr/bin/perl

use strict;

while (<DATA>) {
  next unless /^\s*(MDEV-\d+):\s*(.*)/;
  my ($mdev, $pattern)= ($1, $2);
  chomp $pattern;
  system("grep -h -E \"$pattern\" @ARGV > /dev/null 2>&1");
  unless ($?) {
    unless (-e "/tmp/$mdev.resolution") {
      system("wget https://jira.mariadb.org//rest/api/2/issue/$mdev?fields=resolution -O /tmp/$mdev.resolution -o /dev/null");
    }
    unless (-e "/tmp/$mdev.summary") {
      system("wget https://jira.mariadb.org//rest/api/2/issue/$mdev?fields=summary -O /tmp/$mdev.summary -o /dev/null");
    }
    unless (-e "/tmp/$mdev.fixVersions") {
      system("wget https://jira.mariadb.org//rest/api/2/issue/$mdev?fields=fixVersions -O /tmp/$mdev.fixVersions -o /dev/null");
    }
    unless (-e "/tmp/$mdev.affectsVersions") {
      system("wget https://jira.mariadb.org//rest/api/2/issue/$mdev?fields=versions -O /tmp/$mdev.affectsVersions -o /dev/null");
    }

    my $summary= `cat /tmp/$mdev.summary`;
    if ($summary =~ /\{\"summary\":\"(.*?)\"\}/) {
      $summary= $1;
    }
    my $resolution= `cat /tmp/$mdev.resolution`;
    my $resolutiondate;
    if ($resolution=~ s/.*\"name\":\"([^\"]+)\".*/$1/) {
      unless (-e "/tmp/$mdev.resolutiondate") {
        system("wget https://jira.mariadb.org//rest/api/2/issue/$mdev?fields=resolutiondate -O /tmp/$mdev.resolutiondate -o /dev/null");
      }
      $resolutiondate= `cat /tmp/$mdev.resolutiondate`;
      unless ($resolutiondate=~ s/.*\"resolutiondate\":\"(\d\d\d\d-\d\d-\d\d).*/$1/) {
        $resolutiondate= '';
      }
    } else {
      $resolution= 'Unresolved';
    }
    my $fixVersions= `cat /tmp/$mdev.fixVersions`;
    my @versions = ($fixVersions =~ /\"name\":\"(.*?)\"/g);

    my $affectsVersions= `cat /tmp/$mdev.affectsVersions`;
    my @affected = ($affectsVersions =~ /\"name\":\"(.*?)\"/g);
    
    print "$mdev: $summary\n";
    print "RESOLUTION: $resolution". ($resolutiondate ? " ($resolutiondate)" : "") . "\n";
    print "Affects versions: @affected\n";
    print "Fix versions: @versions\n";
  }
}


__DATA__

MDEV-654: share->now_transactional
MDEV-4312: make_lock_and_pin
MDEV-5791:  in Field::is_real_null
MDEV-6453:  int handler::ha_rnd_init
MDEV-8203:  rgi->tables_to_lock
MDEV-10130: share->in_trans == 0
MDEV-10679: mysql_create_frm_image
MDEV-11071: thd->transaction.stmt.is_empty
MDEV-11071: mark_tmp_table_as_free_for_reuse
MDEV-11539: mi_open.c:67: test_if_reopen
MDEV-11779: void Diagnostics_area::set_ok_status
MDEV-12466: Open_tables_state::BACKUPS_AVAIL
MDEV-13024: in multi_delete::send_data
MDEV-13103: fil0pagecompress.cc:[0-9]+: void fil_decompress_page
MDEV-13202: ltime->neg == 0
MDEV-13231: in _ma_unique_hash
MDEV-13553: Open_tables_state::BACKUPS_AVAIL
MDEV-13644: prev != 0 && next != 0
MDEV-13699: == new_field->field_name.length
MDEV-13828: in handler::ha_index_or_rnd_end
MDEV-14040: in Field::is_real_null
MDEV-14041: in String::length
MDEV-14134: dberr_t row_upd_sec_index_entry
MDEV-14407: trx_undo_rec_copy
MDEV-14410: table->pos_in_locked_tables->table == table
MDEV-14472: is_current_stmt_binlog_format_row
MDEV-14551: Can't find record in
MDEV-14557: m_sp == __null
MDEV-14642: table->s->db_create_options == part_table->s->db_create_options
MDEV-14669: file->trn == trn
MDEV-14693: clust_index->online_log
MDEV-14695: n < m_size
MDEV-14697: in TABLE::mark_default_fields_for_write
MDEV-14711: fix_block->page.file_page_was_freed
MDEV-14762: has_stronger_or_equal_type
MDEV-14743: Item_func_match::init_search
MDEV-14815: in has_old_lock
MDEV-14825: col->ord_part
MDEV-14829: protocol.cc:588: void Protocol::end_statement
MDEV-14833: trx->error_state == DB_SUCCESS
MDEV-14836: m_status == DA_ERROR
MDEV-14846: prebuilt->trx, TRX_STATE_ACTIVE
MDEV-14846: state == TRX_STATE_FORCED_ROLLBACK
MDEV-14862: in add_key_equal_fields
MDEV-14864: in mysql_prepare_create_table
MDEV-14864: in mysql_prepare_alter_table
MDEV-14894: tdc_remove_table
MDEV-14894: table->in_use == thd
MDEV-14905: purge_sys->state == PURGE_STATE_INIT
MDEV-14906: index->is_instant
MDEV-14943: type == PAGECACHE_LSN_PAGE
MDEV-14994: join->best_read < double
MDEV-14995: in ha_partition::update_create_info
MDEV-14995: base_list_iterator::next
MDEV-14996: int ha_maria::external_lock
MDEV-14998: find_field_in_table_ref
MDEV-15013: trx->state == TRX_STATE_NOT_STARTED
MDEV-15060: row_log_table_apply_op
MDEV-15103: virtual ha_rows ha_partition::part_records
MDEV-15130: table->s->null_bytes == 0
MDEV-15130: static void PFS_engine_table::set_field_char_utf8
MDEV-15115: dict_tf2_is_valid
MDEV-15141: in Item::val_temporal_packed
MDEV-15161: in get_addon_fields
MDEV-15164: ikey_.type == kTypeValue
MDEV-15175: Item_temporal_hybrid_func::val_str_ascii
MDEV-15216: m_can_overwrite_status
MDEV-15217: transaction.xid_state.xid.is_null
MDEV-15226: Could not get index information for Index Number
MDEV-15243: in Field_blob::pack
MDEV-15245: myrocks::ha_rocksdb::position
MDEV-15255: m_lock_type == 2
MDEV-15255: sequence_insert
MDEV-15308: ha_alter_info->alter_info->drop_list.elements > 0
MDEV-15319: myrocks::ha_rocksdb::convert_record_from_storage_format
MDEV-15329: in dict_table_check_for_dup_indexes
MDEV-15330: table->insert_values
MDEV-15336: ha_partition::print_error
MDEV-15338: table->read_set, field_index
MDEV-15347: in fill_schema_table_by_open
MDEV-15374: trx_undo_rec_copy
MDEV-15380: is corrupt; try to repair it
MDEV-15391: join->best_read < double
MDEV-15401: Item_direct_view_ref::used_tables
MDEV-15456: in get_part_name_from_elem
MDEV-15456: in ha_partition::create_handler_file
MDEV-15464: in TrxUndoRsegsIterator::set_next
MDEV-15465: Item_func_match::cleanup
MDEV-15468: table_events_waits_common::make_row 
MDEV-15470: TABLE::mark_columns_used_by_index_no_reset
MDEV-15471: new_clustered == ctx->need_rebuild
MDEV-15481: I_P_List_null_counter, I_P_List_fast_push_back
MDEV-15482: Type_std_attributes::set
MDEV-15484: element->m_flush_tickets.is_empty
MDEV-15485: read_sep_field
MDEV-15486: String::needs_conversion
MDEV-15490: in trx_update_mod_tables_timestamp
MDEV-15493: lock_trx_table_locks_remove
MDEV-15533: log->blobs
MDEV-15537: in mysql_prepare_alter_table
MDEV-15551: share->last_version
MDEV-15576: item->null_value
MDEV-15626: old_part_id == m_last_part
MDEV-15657: file->inited == handler::NONE
MDEV-15658: expl_lock->trx == arg->impl_trx
MDEV-15729: in Field::make_field
MDEV-15729: Field::make_send_field
MDEV-15738: in my_strcasecmp_utf8
MDEV-15744: derived->table
MDEV-15742: m_lock_type == 1
MDEV-15797: thd->killed != 0
MDEV-15812: virtual handler::~handler
MDEV-15816: m_lock_rows == RDB_LOCK_WRITE
MDEV-15828: num_fts_index <= 1
MDEV-15970: m_status == DA_OK_BULK
MDEV-15970: Can't find record in
MDEV-16043: st_select_lex::fix_prepare_information
MDEV-16043: thd->Item_change_list::is_empty
MDEV-16078: in Item::delete_self
MDEV-16153: Apc_target::disable
MDEV-16169: space->referenced
MDEV-16170: Item_null_result::type_handler
