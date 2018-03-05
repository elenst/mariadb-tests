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
    
    print "$mdev: $summary\n";
    print "RESOLUTION: $resolution". ($resolutiondate ? " ($resolutiondate)" : "") . "\n";
    print "Fix versions: @versions\n";
  }
}


__DATA__

MDEV-5791:  in Field::is_real_null
MDEV-6453:  int handler::ha_rnd_init
MDEV-10130: share->in_trans == 0
MDEV-11071: thd->transaction.stmt.is_empty
MDEV-11539: mi_open.c:67: test_if_reopen
MDEV-11779: void Diagnostics_area::set_ok_status
MDEV-12466: Open_tables_state::BACKUPS_AVAIL
MDEV-13024: in multi_delete::send_data
MDEV-13103: fil0pagecompress.cc:[0-9]+: void fil_decompress_page
MDEV-13231: in _ma_unique_hash
MDEV-13553: Open_tables_state::BACKUPS_AVAIL
MDEV-13699: == new_field->field_name.length
MDEV-14040: in Field::is_real_null
MDEV-14041: in String::length
MDEV-14134: dberr_t row_upd_sec_index_entry
MDEV-14407: trx_undo_rec_copy
MDEV-14472: is_current_stmt_binlog_format_row
MDEV-14551: Can't find record in
MDEV-14642: table->s->db_create_options == part_table->s->db_create_options
MDEV-14669: file->trn == trn
MDEV-14693: clust_index->online_log
MDEV-14695: n < m_size
MDEV-14697: in TABLE::mark_default_fields_for_write
MDEV-14711: fix_block->page.file_page_was_freed
MDEV-14715: table->read_set, field_index
MDEV-14762: has_stronger_or_equal_type
MDEV-14743: Item_func_match::init_search
MDEV-14825: col->ord_part
MDEV-14829: protocol.cc:588: void Protocol::end_statement
MDEV-14831: Can't find record in
MDEV-14833: [Draft] Failing assertion: trx->error_state == DB_SUCCESS in file /home/travis/src/storage/innobase/que/que0que.cc line [0-9]+
MDEV-14836: m_status == DA_ERROR
MDEV-14862: in add_key_equal_fields
MDEV-14864: in mysql_prepare_create_table
MDEV-14864: in mysql_prepare_alter_table
MDEV-14905: purge_sys->state == PURGE_STATE_INIT
MDEV-14906: index->is_instant
MDEV-14932: in ha_partition::update_create_info
MDEV-14994: join->best_read < double
MDEV-14995: in ha_partition::update_create_info
MDEV-14996: int ha_maria::external_lock
MDEV-14998: find_field_in_table_ref
MDEV-15060: row_log_table_apply_op
MDEV-15103: virtual ha_rows ha_partition::part_records
MDEV-15130: table->s->null_bytes == 0
MDEV-15130: static void PFS_engine_table::set_field_char_utf8
MDEV-15115: dict_tf2_is_valid
MDEV-15117: sequence_insert
MDEV-15117: in is_temporary_table
MDEV-15141: in Item::val_temporal_packed
MDEV-15149: table_share->tmp_table != NO_TMP_TABLE
MDEV-15149: table->in_use == _current_thd
MDEV-15149: tables->table->pos_in_table_list == tables
MDEV-15149: sequence_insert
MDEV-15161: in get_addon_fields
MDEV-15164: ikey_.type == kTypeValue
MDEV-15167: in THD::binlog_write_row
MDEV-15175: Item_temporal_hybrid_func::val_str_ascii
MDEV-15216: m_can_overwrite_status
MDEV-15217: transaction.xid_state.xid.is_null
MDEV-15226: Could not get index information for Index Number
MDEV-15245: myrocks::ha_rocksdb::position
MDEV-15255: m_lock_type == 2
MDEV-15255: sequence_insert
MDEV-15308: ha_alter_info->alter_info->drop_list.elements > 0
MDEV-15319: myrocks::ha_rocksdb::convert_record_from_storage_format
MDEV-15330: table->insert_values
MDEV-15336: ha_partition::print_error
MDEV-15338: table->read_set, field_index
MDEV-15347: in fill_schema_table_by_open
MDEV-15380: is corrupt; try to repair it
MDEV-15456: in get_part_name_from_elem
MDEV-15456: in ha_partition::create_handler_file
MDEV-15464: in TrxUndoRsegsIterator::set_next
MDEV-15465: Item_func_match::cleanup
MDEV-15468: table_events_waits_common::make_row 
MDEV-15470: TABLE::mark_columns_used_by_index_no_reset
MDEV-15471: new_clustered == ctx->need_rebuild
MDEV-15472: void Diagnostics_area::set_ok_status
