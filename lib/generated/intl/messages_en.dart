// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static m0(hours) => "${hours}h";

  static m1(minutes) => " ${minutes}m Left";

  static m2(position) => "What’s the ${position} word of your account key?";

  static m3(position) => "Please fill in the ${position} mnemonic";

  static m4(number) => "Withdrawal amount can\'t be greater than the inactive  ${number} CELO";

  static m5(number) => "Withdrawal amount can\'t be greater than the unactivated ${number} CELO";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "account_no_hint" : MessageLookupByLibrary.simpleMessage("A voting address must be created on the smart contract so you can vote. continue?"),
    "account_num" : MessageLookupByLibrary.simpleMessage("Receive Amount"),
    "accumulated_earnings" : MessageLookupByLibrary.simpleMessage("Total Rewards"),
    "activate_remaining_time_one" : m0,
    "activate_remaining_time_two" : m1,
    "activation" : MessageLookupByLibrary.simpleMessage("Activate"),
    "add_address" : MessageLookupByLibrary.simpleMessage("Add Address"),
    "address" : MessageLookupByLibrary.simpleMessage("Address"),
    "address_administration" : MessageLookupByLibrary.simpleMessage("Addresses"),
    "address_asset" : MessageLookupByLibrary.simpleMessage("Assets"),
    "address_create" : MessageLookupByLibrary.simpleMessage("Create Address"),
    "address_create_err" : MessageLookupByLibrary.simpleMessage("Address creation failed"),
    "address_create_hint_one" : MessageLookupByLibrary.simpleMessage("The following is your mnemonic phrase. Please find a safe and private place to write it down."),
    "address_create_hint_three" : MessageLookupByLibrary.simpleMessage("Click here after backing up"),
    "address_create_hint_two" : MessageLookupByLibrary.simpleMessage("The mnemonic phrase is randomly generated by the system, CeloDance will not keep it. If you lose the mnemonic phrase, you will be at risk of losing the assets in the address."),
    "address_equality_hint" : MessageLookupByLibrary.simpleMessage("Receive and send can not be the same address"),
    "address_import_err" : MessageLookupByLibrary.simpleMessage("Address import failed, please check the mnemonic"),
    "aging" : MessageLookupByLibrary.simpleMessage("Yields"),
    "all" : MessageLookupByLibrary.simpleMessage("All"),
    "all_activate_hint" : MessageLookupByLibrary.simpleMessage("All unvalidated votes will be activated，continue?"),
    "all_backups" : MessageLookupByLibrary.simpleMessage("I\'ve written it down"),
    "all_delete" : MessageLookupByLibrary.simpleMessage("Delete All"),
    "all_recap_hint" : MessageLookupByLibrary.simpleMessage("All unlocked Celo will be withdrawn, continue? "),
    "app_name" : MessageLookupByLibrary.simpleMessage("CeloDance"),
    "apr" : MessageLookupByLibrary.simpleMessage("APR"),
    "asset_administration" : MessageLookupByLibrary.simpleMessage("Currency"),
    "asset_statistics" : MessageLookupByLibrary.simpleMessage("PNL"),
    "available" : MessageLookupByLibrary.simpleMessage("Available"),
    "backup_doc" : MessageLookupByLibrary.simpleMessage("Back up keys"),
    "backup_doc_hint_seven" : m2,
    "backup_doc_no_equality" : MessageLookupByLibrary.simpleMessage("Please check the keys you typed"),
    "balance" : MessageLookupByLibrary.simpleMessage("Value"),
    "been_completed" : MessageLookupByLibrary.simpleMessage("Completed"),
    "cancel" : MessageLookupByLibrary.simpleMessage("Cancel"),
    "cancel_inactive_votes" : MessageLookupByLibrary.simpleMessage("Pending Vote Revoked"),
    "celo_asset_states" : MessageLookupByLibrary.simpleMessage("Lock & Vote"),
    "coin_type_dialog_title" : MessageLookupByLibrary.simpleMessage("Choose coin"),
    "collection_address" : MessageLookupByLibrary.simpleMessage("Recipient Address"),
    "collection_num" : MessageLookupByLibrary.simpleMessage("Amount"),
    "confirm" : MessageLookupByLibrary.simpleMessage("Confirm"),
    "confirm_delete" : MessageLookupByLibrary.simpleMessage("Are you sure to delete？"),
    "confirmation" : MessageLookupByLibrary.simpleMessage("Comfirming"),
    "copy_success" : MessageLookupByLibrary.simpleMessage("copied"),
    "current_node" : MessageLookupByLibrary.simpleMessage("Elected Node"),
    "custom_node" : MessageLookupByLibrary.simpleMessage("Add a New RPC URL"),
    "delete" : MessageLookupByLibrary.simpleMessage("Delete"),
    "delete_failed" : MessageLookupByLibrary.simpleMessage("Deletion failed"),
    "denunciate" : MessageLookupByLibrary.simpleMessage("Alias"),
    "details" : MessageLookupByLibrary.simpleMessage("Details"),
    "done" : MessageLookupByLibrary.simpleMessage("Done"),
    "earnings_group" : MessageLookupByLibrary.simpleMessage("Group Share"),
    "earnings_group_two" : MessageLookupByLibrary.simpleMessage("Group Share"),
    "earnings_note" : MessageLookupByLibrary.simpleMessage("Validator Attestation Rewards"),
    "earnings_note_two" : MessageLookupByLibrary.simpleMessage("Validator Attestation Rewards"),
    "earnings_person" : MessageLookupByLibrary.simpleMessage("Validator Reward"),
    "earnings_person_two" : MessageLookupByLibrary.simpleMessage("Validator Reward"),
    "earnings_record" : MessageLookupByLibrary.simpleMessage("Rewards"),
    "earnings_report" : MessageLookupByLibrary.simpleMessage("Slashing Report Rewards"),
    "earnings_report_two" : MessageLookupByLibrary.simpleMessage("Slashing Report Rewards"),
    "earnings_valora" : MessageLookupByLibrary.simpleMessage("Saving cUSD & Earn"),
    "earnings_valora_two" : MessageLookupByLibrary.simpleMessage("Saving cUSD & Earn"),
    "earnings_vote" : MessageLookupByLibrary.simpleMessage("Lock&Vote Reward"),
    "earnings_vote_two" : MessageLookupByLibrary.simpleMessage("Lock&Vote Reward"),
    "earnings_yesterday" : MessageLookupByLibrary.simpleMessage("Yesterday Rewards"),
    "exit_app_hint" : MessageLookupByLibrary.simpleMessage("Tap again to exit"),
    "fail" : MessageLookupByLibrary.simpleMessage("Failed"),
    "gain_msg_fail" : MessageLookupByLibrary.simpleMessage("Failed to get address infor"),
    "guide_hint_one" : MessageLookupByLibrary.simpleMessage("Safe , convenient , comprehensive\nYour wiser choice"),
    "guide_hint_two" : MessageLookupByLibrary.simpleMessage("Do not touch user assets\nDisplay the public on-chain data\nManage your assets more efficiently"),
    "have_vote" : MessageLookupByLibrary.simpleMessage("My Votes"),
    "hint" : MessageLookupByLibrary.simpleMessage("Note"),
    "history" : MessageLookupByLibrary.simpleMessage("Transaction History"),
    "home_add_title" : MessageLookupByLibrary.simpleMessage("Add Address"),
    "http_are_err" : MessageLookupByLibrary.simpleMessage("RPC URL already exists"),
    "http_err" : MessageLookupByLibrary.simpleMessage("Unable to connect to the node, please check again"),
    "immediately_check" : MessageLookupByLibrary.simpleMessage("Next"),
    "immediately_experience" : MessageLookupByLibrary.simpleMessage("Start"),
    "immediately_import" : MessageLookupByLibrary.simpleMessage("Import"),
    "import_celo_address" : MessageLookupByLibrary.simpleMessage("Import CELO address"),
    "import_wallet" : MessageLookupByLibrary.simpleMessage("Import Address"),
    "import_wallet_hint" : m3,
    "input_address" : MessageLookupByLibrary.simpleMessage("Input address or long press to paste"),
    "input_mnemonic_word" : MessageLookupByLibrary.simpleMessage("Input mnemonic phrase"),
    "input_num_err_hint" : MessageLookupByLibrary.simpleMessage("The amount you entered cannot be greater than the account amount"),
    "input_num_hint" : MessageLookupByLibrary.simpleMessage("0"),
    "input_tag_hint" : MessageLookupByLibrary.simpleMessage("Check and fill in the memo carefully."),
    "jump" : MessageLookupByLibrary.simpleMessage("Okay"),
    "label" : MessageLookupByLibrary.simpleMessage("Memo"),
    "label_hint" : MessageLookupByLibrary.simpleMessage("Please fill in the tag carefully. If you miss the tag, it may leads to the loss of funds. Are you sure to continue ?"),
    "language_choice" : MessageLookupByLibrary.simpleMessage("Language"),
    "last_earnings" : MessageLookupByLibrary.simpleMessage("Last Time Rewards"),
    "last_time" : MessageLookupByLibrary.simpleMessage("Last Epoch"),
    "load_text" : MessageLookupByLibrary.simpleMessage("Loading"),
    "lock" : MessageLookupByLibrary.simpleMessage("Locked"),
    "lock_e" : MessageLookupByLibrary.simpleMessage("Lock"),
    "lock_no_vote" : MessageLookupByLibrary.simpleMessage("nonVoting"),
    "management" : MessageLookupByLibrary.simpleMessage("Manage"),
    "maximum" : MessageLookupByLibrary.simpleMessage("Avaliable"),
    "mine" : MessageLookupByLibrary.simpleMessage("Me"),
    "minimum_input_num_hint" : MessageLookupByLibrary.simpleMessage("The minimum input quantity is 0.00000001"),
    "mnemonic_ree" : MessageLookupByLibrary.simpleMessage("Wrong mnemonic, please check again."),
    "next_step" : MessageLookupByLibrary.simpleMessage("Next"),
    "no_coin_err_hint" : MessageLookupByLibrary.simpleMessage("This coin is temporarily unavailable "),
    "no_coin_trading_err" : MessageLookupByLibrary.simpleMessage("This coin cannot be traded now"),
    "no_deal_hint" : MessageLookupByLibrary.simpleMessage("Amount must be greater than 0"),
    "no_label" : MessageLookupByLibrary.simpleMessage("No need to fill in memo"),
    "no_record" : MessageLookupByLibrary.simpleMessage("No records for now"),
    "node_selection" : MessageLookupByLibrary.simpleMessage("Switch Node"),
    "number" : MessageLookupByLibrary.simpleMessage("Amount"),
    "observe_address" : MessageLookupByLibrary.simpleMessage("Track"),
    "observe_address_add" : MessageLookupByLibrary.simpleMessage("Track Address"),
    "observe_address_hint" : MessageLookupByLibrary.simpleMessage("Track address is a way to track your asset status and transaction history.track wallet doesn\'t have private key or password, and needs pairing with cold wallet to authorization to complete the transactions."),
    "observe_address_no_trading" : MessageLookupByLibrary.simpleMessage("Track address can\'t perform this operation"),
    "optional" : MessageLookupByLibrary.simpleMessage("Optional"),
    "paste_all" : MessageLookupByLibrary.simpleMessage("Paste All"),
    "paw_err_hint" : MessageLookupByLibrary.simpleMessage("Wrong pin code, please check again"),
    "pin_error_hint" : MessageLookupByLibrary.simpleMessage(" Inconsistent pin code, please reset"),
    "pin_simple_hint" : MessageLookupByLibrary.simpleMessage("Pin code is too simple, please reset"),
    "pin_title_one" : MessageLookupByLibrary.simpleMessage("Please enter your pin code"),
    "pin_title_three" : MessageLookupByLibrary.simpleMessage("Set your pin code"),
    "pin_title_two" : MessageLookupByLibrary.simpleMessage("Repeat pin code"),
    "poundage_insufficient_cusd_hint" : MessageLookupByLibrary.simpleMessage("In this operation, the amount of cUSD used for handling charge is insufficient."),
    "privacy_policy" : MessageLookupByLibrary.simpleMessage("Privacy Policy"),
    "receive" : MessageLookupByLibrary.simpleMessage("Receive"),
    "receive_address" : MessageLookupByLibrary.simpleMessage("To"),
    "receive_details" : MessageLookupByLibrary.simpleMessage("Details"),
    "refresh_completed" : MessageLookupByLibrary.simpleMessage("Refresh : Today "),
    "refresh_failure" : MessageLookupByLibrary.simpleMessage("Refresh failed"),
    "renamed_failure" : MessageLookupByLibrary.simpleMessage("Rename failed"),
    "revoke" : MessageLookupByLibrary.simpleMessage("Revoke"),
    "revoke_from" : MessageLookupByLibrary.simpleMessage("Revoke From"),
    "roll_out" : MessageLookupByLibrary.simpleMessage("Send"),
    "roll_out_address" : MessageLookupByLibrary.simpleMessage("Received from"),
    "rpc_url_delete_hint" : MessageLookupByLibrary.simpleMessage("Are you sure to delete?"),
    "save_address_err_hint" : MessageLookupByLibrary.simpleMessage("Failed to save address"),
    "save_address_err_one" : MessageLookupByLibrary.simpleMessage("Address already exists"),
    "save_failed" : MessageLookupByLibrary.simpleMessage("failed"),
    "save_success" : MessageLookupByLibrary.simpleMessage("Saved"),
    "save_to_album" : MessageLookupByLibrary.simpleMessage("Save To Album"),
    "scan" : MessageLookupByLibrary.simpleMessage("Scan"),
    "scan_hint" : MessageLookupByLibrary.simpleMessage("Please point your camera at the QR code, it\'ll automatically scan"),
    "scan_permissions_hint" : MessageLookupByLibrary.simpleMessage("Please jump to the settings and agree to the camera permission for QR code scanning"),
    "select_address" : MessageLookupByLibrary.simpleMessage("Choose Address"),
    "select_validation_group" : MessageLookupByLibrary.simpleMessage("Select Validator Group"),
    "send" : MessageLookupByLibrary.simpleMessage("Send"),
    "send_address_err" : MessageLookupByLibrary.simpleMessage("Address wrong"),
    "send_details" : MessageLookupByLibrary.simpleMessage("Details"),
    "service_charge" : MessageLookupByLibrary.simpleMessage("Fee"),
    "setting" : MessageLookupByLibrary.simpleMessage("Setting"),
    "shut_down" : MessageLookupByLibrary.simpleMessage("Close"),
    "skip" : MessageLookupByLibrary.simpleMessage("Skip"),
    "start_donors_hint" : MessageLookupByLibrary.simpleMessage("Bi23 Labs @2021"),
    "start_hint" : MessageLookupByLibrary.simpleMessage("Grants by Celo Foundation"),
    "state" : MessageLookupByLibrary.simpleMessage("Status"),
    "storage_permissions_hint" : MessageLookupByLibrary.simpleMessage("Please jump to the settings to agree to the storage permission, so as to save the QR code image"),
    "success_rate" : MessageLookupByLibrary.simpleMessage("Completed"),
    "tips" : MessageLookupByLibrary.simpleMessage("Note"),
    "total_asset_valuation" : MessageLookupByLibrary.simpleMessage("History"),
    "total_assets" : MessageLookupByLibrary.simpleMessage("Total Value"),
    "total_assets_title" : MessageLookupByLibrary.simpleMessage("Total Value"),
    "total_vote" : MessageLookupByLibrary.simpleMessage("Total Votes"),
    "trading_hours" : MessageLookupByLibrary.simpleMessage("Date"),
    "type" : MessageLookupByLibrary.simpleMessage("Type"),
    "undetermined" : MessageLookupByLibrary.simpleMessage("Withdrawl Pending"),
    "unknown_earnings" : MessageLookupByLibrary.simpleMessage("Other Rewards"),
    "unlock" : MessageLookupByLibrary.simpleMessage("Unlock"),
    "unnamed" : MessageLookupByLibrary.simpleMessage("Unnamed"),
    "update_address_hint" : MessageLookupByLibrary.simpleMessage("This address already exists\nDo you want to update information ?"),
    "valora_authorization" : MessageLookupByLibrary.simpleMessage("Connect to Valora"),
    "valora_no_installation" : MessageLookupByLibrary.simpleMessage("Valora is not installed\nDo you want to install?"),
    "vote" : MessageLookupByLibrary.simpleMessage("Vote"),
    "vote_activated" : MessageLookupByLibrary.simpleMessage("Pending Voting"),
    "vote_sort_one" : MessageLookupByLibrary.simpleMessage("Rank By Total Votes"),
    "vote_sort_two" : MessageLookupByLibrary.simpleMessage("Rank By My Votes"),
    "vote_to" : MessageLookupByLibrary.simpleMessage("Vote To"),
    "voting" : MessageLookupByLibrary.simpleMessage("Voting"),
    "week_earnings" : MessageLookupByLibrary.simpleMessage("Last Week Rewards"),
    "withdraw" : MessageLookupByLibrary.simpleMessage("Withdraw"),
    "withdraw_money_err_one" : m4,
    "withdraw_money_err_two" : m5,
    "yesterday_profit" : MessageLookupByLibrary.simpleMessage("Rewards Yesterday")
  };
}
