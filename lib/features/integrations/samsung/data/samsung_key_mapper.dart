import '../../../devices/tv/domain/tv_remote_command.dart';

/// Maps [TvRemoteCommand] to Samsung KEY_* string codes.
const Map<TvRemoteCommand, String> samsungKeyMap = {
  TvRemoteCommand.powerOff: 'KEY_POWER',
  TvRemoteCommand.powerOn: 'KEY_POWER',
  TvRemoteCommand.volumeUp: 'KEY_VOLUP',
  TvRemoteCommand.volumeDown: 'KEY_VOLDOWN',
  TvRemoteCommand.mute: 'KEY_MUTE',
  TvRemoteCommand.up: 'KEY_UP',
  TvRemoteCommand.down: 'KEY_DOWN',
  TvRemoteCommand.left: 'KEY_LEFT',
  TvRemoteCommand.right: 'KEY_RIGHT',
  TvRemoteCommand.enter: 'KEY_ENTER',
  TvRemoteCommand.back: 'KEY_RETURN',
  TvRemoteCommand.home: 'KEY_HOME',
  TvRemoteCommand.menu: 'KEY_MENU',
  TvRemoteCommand.source: 'KEY_SOURCE',
  TvRemoteCommand.channelUp: 'KEY_CHUP',
  TvRemoteCommand.channelDown: 'KEY_CHDOWN',
};

/// Resolves the Samsung KEY_* code for a given command.
String samsungKeyFor(TvRemoteCommand cmd) => samsungKeyMap[cmd] ?? 'KEY_ENTER';
