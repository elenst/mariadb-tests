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
    my $summary= `cat /tmp/$mdev.summary`;
    $summary=~ s/.*\"summary\":\"?([^\"\}]+)\"?.*/$1/;
    my $resolution= `cat /tmp/$mdev.resolution`;
    $resolution=~ s/.*\"resolution\":\"?([^\"\}]+)\"?.*/$1/;
    print "$mdev: $summary\n";
    print "RESOLUTION: $resolution\n";
  }
}


__DATA__

MDEV-14864: in mysql_prepare_create_table
MDEV-14833: [Draft] Failing assertion: trx->error_state == DB_SUCCESS in file /home/travis/src/storage/innobase/que/que0que.cc line [0-9]+
MDEV-13103: fil0pagecompress.cc:[0-9]+: void fil_decompress_page
MDEV-14829: protocol.cc:587: void Protocol::end_statement
MDEV-15036: sql_error.cc:335: void Diagnostics_area::set_ok_status
MDEV-14695: n < m_size
MDEV-13699: == new_field->field_name.length
MDEV-15103: virtual ha_rows ha_partition::part_records
MDEV-14715: table->read_set, field_index
MDEV-14995: in ha_partition::update_create_info
MDEV-14932: in ha_partition::update_create_info
MDEV-14762: has_stronger_or_equal_type
MDEV-10130: share->in_trans == 0
MDEV-14825: col->ord_part
MDEV-14994: join->best_read < double
MDEV-15130: table->s->null_bytes == 0
MDEV-15117: in is_temporary_table
MDEV-15149: table_share->tmp_table != NO_TMP_TABLE
MDEV-15149: table->in_use == _current_thd
MDEV-15149: tables->table->pos_in_table_list == tables